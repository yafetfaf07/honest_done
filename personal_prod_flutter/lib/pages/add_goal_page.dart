import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:personal_prod/state/goals_provider.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';

/// Creates a goal.
///
/// The three-step wizard collected resources and a free-form plan, but
/// `POST /api/v1/goal/create` only accepts a name, description, and target date,
/// so the extra steps were write-only: the file and links were never sent
/// anywhere. Collapsed to the three fields the endpoint actually stores.
class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _targetDate;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? today,
      firstDate: today,
      lastDate: DateTime(now.year + 5, 12, 31),
      helpText: 'When do you want to be done?',
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a target date.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final goals = context.read<GoalsProvider>();
    final ok = await goals.create(
      name: _nameController.text,
      description: _descriptionController.text,
      targetDate: _targetDate!,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(goals.error ?? 'Could not create that goal.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppBar(title: const Text('New goal')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.layoutMargin),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Set your destination',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceSm),
                    Text(
                      'A goal needs a name, what you want out of it, and a date to be done by.',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.spaceXl),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Goal title',
                        hintText: 'Become a Golang backend engineer',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Give the goal a name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'What does success look like?',
                        hintText: 'How will you achieve this?',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spaceLg),
                    InkWell(
                      onTap: _submitting ? null : _pickTargetDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Target date',
                          prefixIcon: const Icon(Icons.calendar_month_outlined),
                          suffixIcon: const Icon(Icons.expand_more),
                          errorText: _targetDate == null && _submitting
                              ? 'Pick a target date.'
                              : null,
                        ),
                        child: Text(
                          _targetDate == null ? 'Select a date' : _formatDate(_targetDate!),
                          style: TextStyle(
                            color: _targetDate == null
                                ? colors.textMuted
                                : colors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space2xl),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.spaceLg,
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Create goal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}