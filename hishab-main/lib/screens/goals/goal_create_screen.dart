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
    final isEditMode = widget.goalToEdit != null;
    const primaryColor = Color(0xFFF16725);
    final selectedDisplayColor = _parseColor(_selectedColor) ?? primaryColor;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Goal' : 'Create New Goal'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.1),
              backgroundColor,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEditMode ? Icons.edit_note : Icons.add_circle_outline,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditMode ? 'Edit Your Goal' : 'Set a New Goal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEditMode 
                                ? 'Update your savings target' 
                                : 'Start saving for what matters',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Goal Title
              _buildFieldLabel('Goal Title', Icons.flag, primaryColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'e.g., Dream Vacation, New Laptop',
                  prefixIcon: Icon(Icons.title, color: primaryColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              
              // Target Amount
              _buildFieldLabel('Target Amount', Icons.payments, primaryColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _targetAmountController,
                decoration: InputDecoration(
                  labelText: 'How much do you need?',
                  prefixIcon: Icon(Icons.monetization_on, color: primaryColor),
                  prefixText: '৳ ',
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(v!) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Monthly Allocation
              _buildFieldLabel('Monthly Allocation', Icons.calendar_month, primaryColor),
              const SizedBox(height: 8),
              TextFormField(
                controller: _monthlyAllocationController,
                decoration: InputDecoration(
                  labelText: 'How much can you save monthly?',
                  helperText: 'Optional - helps track your progress',
                  helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
                  prefixIcon: Icon(Icons.account_balance_wallet, color: primaryColor),
                  prefixText: '৳ ',
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isNotEmpty ?? false) {
                    if (double.tryParse(v!) == null) return 'Invalid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Target Date
              _buildFieldLabel('Target Date', Icons.event, primaryColor),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _targetDate == null 
                          ? (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300)
                          : primaryColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.calendar_today, color: primaryColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'When do you want to achieve this?',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _targetDate == null
                                  ? 'Tap to select date'
                                  : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _targetDate == null ? Colors.grey[400] : primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Color Selection
              _buildFieldLabel('Choose a Color', Icons.palette, selectedDisplayColor),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _colorOptions.map((color) {
                    final hex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                    final isSelected = _selectedColor == hex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = hex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? (isDarkMode ? Colors.white : Colors.black)
                                : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300),
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 28,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              
              // Notifications
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                ),
                child: SwitchListTile(
                  title: Row(
                    children: [
                      Icon(Icons.notifications_active, color: primaryColor, size: 22),
                      const SizedBox(width: 12),
                      const Text(
                        'Milestone Notifications',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(left: 34, top: 4),
                    child: Text(
                      'Get notified at 25%, 50%, 75%, 100% completion',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  value: _notifyOnMilestone,
                  activeThumbColor: primaryColor,
                  onChanged: (v) => setState(() => _notifyOnMilestone = v),
                ),
              ),
              const SizedBox(height: 32),
              
              // Save Button
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: primaryColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isEditMode ? Icons.check_circle : Icons.save, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      isEditMode ? 'Update Goal' : 'Create Goal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color? _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return null;
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }
}
