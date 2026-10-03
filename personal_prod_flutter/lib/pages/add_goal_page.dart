import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _goalTitleController = TextEditingController();
  final TextEditingController _resourcesController = TextEditingController();
  final TextEditingController _plansController = TextEditingController();
  final TextEditingController _targetDateController = TextEditingController();

  int _stepIndex = 0;
  String? _selectedResourceFile;

  static const double _stepOneProgress = 0.40;
  static const double _stepTwoProgress = 0.70;
  static const double _stepThreeProgress = 1.0;

  @override
  void dispose() {
    _goalTitleController.dispose();
    _resourcesController.dispose();
    _plansController.dispose();
    _targetDateController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final initialDate = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(initialDate.year, initialDate.month, initialDate.day),
      lastDate: DateTime(initialDate.year + 5),
    );

    if (pickedDate != null) {
      _targetDateController.text =
          '${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.year}';
    }
  }

  Future<void> _pickResourceFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (result != null && result.files.single.name.isNotEmpty) {
      setState(() {
        _selectedResourceFile = result.files.single.name;
      });
    }
  }

  void _goForward() {
    if (_stepIndex < 2) {
      setState(() {
        _stepIndex += 1;
      });
      return;
    }

    Navigator.of(context).pop();
  }

  void _goBack() {
    if (_stepIndex == 0) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _stepIndex -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final progress = switch (_stepIndex) {
      0 => _stepOneProgress,
      1 => _stepTwoProgress,
      _ => _stepThreeProgress,
    };

    final stepLabel = switch (_stepIndex) {
      0 => 'Step 1 of 3',
      1 => 'Step 2 of 3',
      _ => 'Step 3 of 3',
    };

    final completionLabel = switch (_stepIndex) {
      0 => '40% Complete',
      1 => '70% Complete',
      _ => '100% Complete',
    };

    final title = switch (_stepIndex) {
      0 => 'Set your destination',
      1 => 'Add your resources',
      _ => 'Map your plan',
    };

    final subtitle = switch (_stepIndex) {
      0 =>
        'Clear goals are the first step to massive momentum. What are we forging today?',
      1 =>
        'Paste a YouTube or website link, then upload a PDF or DOCX resource if you have one.',
      _ =>
        'Write down the plan and the actions you want to complete for this goal.',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Goal'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.accentSubtle, colors.bgSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.layoutMargin,
              AppSpacing.spaceMd,
              AppSpacing.layoutMargin,
              AppSpacing.spaceXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stepLabel,
                      style: TextStyle(
                        color: colors.accentText,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      completionLabel,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXl),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.45,
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceXl),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: switch (_stepIndex) {
                    0 => _StepOne(
                      key: const ValueKey('step-1'),
                      goalTitleController: _goalTitleController,
                      targetDateController: _targetDateController,
                      onPickDate: _pickTargetDate,
                    ),
                    1 => _StepTwo(
                      key: const ValueKey('step-2'),
                      resourcesController: _resourcesController,
                      selectedFileName: _selectedResourceFile,
                      onPickFile: _pickResourceFile,
                    ),
                    _ => _StepThree(
                      key: const ValueKey('step-3'),
                      plansController: _plansController,
                    ),
                  },
                ),
                const SizedBox(height: AppSpacing.spaceXl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceLg),
                      elevation: 0,
                    ),
                    onPressed: _goForward,
                    child: Text(
                      _stepIndex == 0
                          ? 'Continue to Resources'
                          : _stepIndex == 1
                          ? 'Continue to Plans'
                          : 'Save Goal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spaceMd),
                TextButton(
                  onPressed: _goBack,
                  child: Text(
                    _stepIndex == 0 ? 'Cancel' : 'Back',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepOne extends StatelessWidget {
  const _StepOne({
    super.key,
    required this.goalTitleController,
    required this.targetDateController,
    required this.onPickDate,
  });

  final TextEditingController goalTitleController;
  final TextEditingController targetDateController;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: goalTitleController,
          decoration: const InputDecoration(
            hintText: 'Goal Title',
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceLg,
              vertical: AppSpacing.spaceLg,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spaceMd),
        TextField(
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'How will you achieve this?',
            contentPadding: EdgeInsets.all(AppSpacing.spaceLg),
          ),
        ),
        const SizedBox(height: AppSpacing.spaceMd),
        GestureDetector(
          onTap: onPickDate,
          child: AbsorbPointer(
            child: TextField(
              controller: targetDateController,
              decoration: const InputDecoration(
                labelText: 'Target Date',
                hintText: 'mm / dd / yyyy',
                suffixIcon: Icon(Icons.calendar_month_outlined),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepTwo extends StatelessWidget {
  const _StepTwo({
    super.key,
    required this.resourcesController,
    required this.selectedFileName,
    required this.onPickFile,
  });

  final TextEditingController resourcesController;
  final String? selectedFileName;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: resourcesController,
          decoration: const InputDecoration(
            hintText: 'YouTube link or website link',
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceLg,
              vertical: AppSpacing.spaceLg,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spaceMd),
        OutlinedButton.icon(
          onPressed: onPickFile,
          icon: const Icon(Icons.upload_file),
          label: Text(
            selectedFileName == null
                ? 'Upload PDF or DOCX'
                : selectedFileName!,
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepThree extends StatelessWidget {
  const _StepThree({
    super.key,
    required this.plansController,
  });

  final TextEditingController plansController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: plansController,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText:
                'Tell us your plans and the things you want to achieve...',
            contentPadding: EdgeInsets.all(AppSpacing.spaceLg),
          ),
        ),
      ],
    );
  }
}