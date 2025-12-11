import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../models/savings_goal.dart';
import 'goal_create_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  final int goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  void _showUpdateProgressDialog(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (ctx) => _UpdateProgressDialog(
        goalId: widget.goalId,
        currentAmount: goal.currentAmount,
      ),
    );
  }

  void _deleteGoal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final provider = Provider.of<FinanceProvider>(context, listen: false);
              await provider.deleteGoal(widget.goalId);
              if (mounted) {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteGoal,
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          final goal = provider.goals.where((g) => g.id == widget.goalId).firstOrNull;

          if (goal == null) {
            return const Center(child: Text('Goal not found'));
          }

          final progress = goal.progressPercent;
          final color = _parseColor(goal.colorHex) ?? const Color(0xFF4ECDC4);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Goal header card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(progress * 100).toInt()}% Complete',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '৳${NumberFormat('#,##0').format(goal.currentAmount)} of '
                      '৳${NumberFormat('#,##0').format(goal.targetAmount)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Info cards
              _buildInfoCard(
                'Remaining',
                '৳${NumberFormat('#,##0').format(goal.remainingAmount)}',
                Icons.money_off,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Target Date',
                DateFormat.yMMMd().format(DateTime.parse(goal.targetDate)),
                Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              if (goal.monthlyAllocation > 0) ...[
                _buildInfoCard(
                  'Monthly Allocation',
                  '৳${NumberFormat('#,##0').format(goal.monthlyAllocation)}',
                  Icons.account_balance_wallet,
                ),
                const SizedBox(height: 12),
                _buildProjectionCard(goal),
              ],
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showUpdateProgressDialog(goal),
                      icon: const Icon(Icons.edit_note, color: Colors.white),
                      label: const Text('Update Progress', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color(0xFF4ECDC4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => GoalCreateScreen(goalToEdit: goal),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),

              if (goal.isCompleted) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.celebration, color: Colors.green, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Congratulations! Goal completed! 🎉',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: const Color(0xFF4ECDC4)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionCard(SavingsGoal goal) {
    final isOnTrack = goal.isOnTrack;
    final projectedDate = goal.projectedCompletionDate;
    final monthsNeeded = goal.monthsToReachGoal;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOnTrack ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnTrack ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOnTrack ? Icons.check_circle : Icons.warning,
                color: isOnTrack ? Colors.green : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isOnTrack ? 'On Track!' : 'Behind Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isOnTrack ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            monthsNeeded < 999
                ? 'At your current allocation of ৳${NumberFormat('#,##0').format(goal.monthlyAllocation)}/month, '
                    'you will reach this goal in $monthsNeeded months (${DateFormat.yMMMd().format(projectedDate)}).'
                : 'Set a monthly allocation to see your projected completion date.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          if (!isOnTrack && monthsNeeded < 999) ...[
            const SizedBox(height: 8),
            Text(
              'Tip: Increase your monthly allocation to ${NumberFormat('#,##0').format(goal.remainingAmount / goal.monthsToReachGoal)}৳/month to reach your target on time.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
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

// Separate dialog widget with proper lifecycle management
class _UpdateProgressDialog extends StatefulWidget {
  final int goalId;
  final double currentAmount;

  const _UpdateProgressDialog({
    required this.goalId,
    required this.currentAmount,
  });

  @override
  State<_UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<_UpdateProgressDialog> {
  late final TextEditingController _controller;
  bool _isAddMode = true; // true = add (default), false = replace

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Current: ৳${NumberFormat('#,##0').format(widget.currentAmount)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isAddMode 
                ? 'Enter the amount to add to your current progress:'
                : 'Enter the new total amount:',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _isAddMode ? 'Amount to Add (৳)' : 'New Total (৳)',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(_isAddMode ? Icons.add : Icons.edit),
            ),
            autofocus: true,
            onChanged: (value) {
              setState(() {});
            },
          ),
          if (_controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _isAddMode
                    ? 'New total will be: ৳${NumberFormat('#,##0').format(widget.currentAmount + (double.tryParse(_controller.text) ?? 0))}'
                    : 'Change: ${(double.tryParse(_controller.text) ?? 0) >= widget.currentAmount ? "+" : ""}৳${NumberFormat('#,##0').format((double.tryParse(_controller.text) ?? 0) - widget.currentAmount)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Add Amount'),
                  selected: _isAddMode,
                  onSelected: (selected) {
                    setState(() {
                      _isAddMode = true;
                      _controller.text = '';
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Set Total'),
                  selected: !_isAddMode,
                  onSelected: (selected) {
                    setState(() {
                      _isAddMode = false;
                      _controller.text = widget.currentAmount.toStringAsFixed(0);
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final inputAmount = double.tryParse(_controller.text);
            if (inputAmount != null && inputAmount >= 0) {
              final finalAmount = _isAddMode 
                  ? widget.currentAmount + inputAmount 
                  : inputAmount;
              
              final provider = Provider.of<FinanceProvider>(context, listen: false);
              await provider.updateGoalProgress(widget.goalId, finalAmount);
              if (mounted) Navigator.of(context).pop();
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
