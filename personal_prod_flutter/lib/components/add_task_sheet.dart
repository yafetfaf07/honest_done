import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:personal_prod/state/goals_provider.dart';
import 'package:personal_prod/state/tasks_provider.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';

/// Creates a task for a goal.
///
/// Tasks are always owned by a goal on the server (`POST /task/create/:goalId`),
/// so the goal is chosen here rather than being inferred.
class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key, this.initialGoalId});

  final String? initialGoalId;

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  late String? _goalId = widget.initialGoalId;
  DateTime _scheduleTime = DateTime.now().add(const Duration(hours: 1));
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduleTime,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (picked == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduleTime),
    );
    if (pickedTime == null) return;

    setState(() {
      _scheduleTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final goals = context.read<GoalsProvider>();
    final goalId = _goalId ?? (goals.goals.isNotEmpty ? goals.goals.first.id : null);
    if (goalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a goal first.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final provider = context.read<TasksProvider>();
    final ok = await provider.create(
      goalId: goalId,
      title: _titleController.text,
      scheduleTime: _scheduleTime,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.error ?? 'Could not create that task.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final goals = context.watch<GoalsProvider>().goals;

    return Padding(
      // Lift the sheet above the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.layoutMargin),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'New task',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXl),
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    hintText: 'Draft the project outline',
                    prefixIcon: Icon(Icons.task_alt),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return 'Name the task.';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spaceLg),
                if (goals.length > 1)
                  DropdownButtonFormField<String>(
                    initialValue: _goalId ?? goals.first.id,
                    decoration: const InputDecoration(labelText: 'Goal'),
                    items: [
                      for (final goal in goals)
                        DropdownMenuItem(
                          value: goal.id,
                          child: Text(
                            goal.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) => setState(() => _goalId = value),
                  ),
                const SizedBox(height: AppSpacing.spaceLg),
                InkWell(
                  onTap: _submitting ? null : _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Scheduled for',
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    child: Text(
                      _formatWhen(_scheduleTime),
                      style: TextStyle(color: colors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXl),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add task'),
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                TextButton(
                  onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatWhen(DateTime time) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '${months[time.month - 1]} ${time.day} · $hour:${time.minute.toString().padLeft(2, '0')} $suffix';
  }
}