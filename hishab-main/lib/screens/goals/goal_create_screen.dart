import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/savings_goal.dart';

class GoalCreateScreen extends StatefulWidget {
  final SavingsGoal? goalToEdit;

  const GoalCreateScreen({super.key, this.goalToEdit});

  @override
  State<GoalCreateScreen> createState() => _GoalCreateScreenState();
}

class _GoalCreateScreenState extends State<GoalCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _targetAmountController;
  late TextEditingController _monthlyAllocationController;
  DateTime? _targetDate;
  bool _notifyOnMilestone = true;
  String? _selectedColor;

  final List<Color> _colorOptions = [
    const Color(0xFF4ECDC4),
    const Color(0xFFF16725),
    const Color(0xFF9C27B0),
    const Color(0xFF0066CC),
    const Color(0xFFFF6B6B),
    const Color(0xFFF7DC6F),
  ];

  @override
  void initState() {
    super.initState();
    final goal = widget.goalToEdit;
    _titleController = TextEditingController(text: goal?.title ?? '');
    _targetAmountController = TextEditingController(
      text: goal?.targetAmount.toString() ?? '',
    );
    _monthlyAllocationController = TextEditingController(
      text: goal?.monthlyAllocation != null && goal!.monthlyAllocation > 0
          ? goal.monthlyAllocation.toString()
          : '',
    );
    _targetDate = goal != null ? DateTime.parse(goal.targetDate) : null;
    _notifyOnMilestone = goal?.notifyOnMilestone ?? true;
    _selectedColor = goal?.colorHex;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _monthlyAllocationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate() || _targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final now = DateTime.now().toIso8601String();

    final goal = SavingsGoal(
      id: widget.goalToEdit?.id,
      title: _titleController.text.trim(),
      targetAmount: double.parse(_targetAmountController.text),
      currentAmount: widget.goalToEdit?.currentAmount ?? 0.0,
      monthlyAllocation: double.tryParse(_monthlyAllocationController.text) ?? 0.0,
      targetDate: _targetDate!.toIso8601String(),
      createdAt: widget.goalToEdit?.createdAt ?? now,
      updatedAt: now,
      notifyOnMilestone: _notifyOnMilestone,
      colorHex: _selectedColor,
    );

    if (widget.goalToEdit == null) {
      await provider.addGoal(goal);
    } else {
      await provider.updateGoal(goal);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goalToEdit == null ? 'Create Goal' : 'Edit Goal'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Goal Title',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetAmountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount (৳)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Required';
                if (double.tryParse(v!) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _monthlyAllocationController,
              decoration: const InputDecoration(
                labelText: 'Monthly Allocation (৳)',
                helperText: 'How much can you allocate monthly? (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isNotEmpty ?? false) {
                  if (double.tryParse(v!) == null) return 'Invalid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Target Date'),
              subtitle: Text(
                _targetDate == null
                    ? 'Not set'
                    : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: _colorOptions.map((color) {
                final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == hex
                            ? Colors.black
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Milestone Notifications'),
              subtitle: const Text('Get notified at 25%, 50%, 75%, 100%'),
              value: _notifyOnMilestone,
              onChanged: (v) => setState(() => _notifyOnMilestone = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: const Color(0xFF4ECDC4),
              ),
              child: Text(
                widget.goalToEdit == null ? 'Create Goal' : 'Update Goal',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
