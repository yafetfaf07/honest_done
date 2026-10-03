import 'package:flutter/material.dart';

import 'package:personal_prod/models/models.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';

/// Runs the questions attached to a task.
///
/// `GET /api/v1/question/getQuestion/:taskId` returns the quiz for a task, which
/// was previously unreachable from the UI.
class QuizSheet extends StatefulWidget {
  const QuizSheet({super.key, required this.questions});

  final List<Question> questions;

  @override
  State<QuizSheet> createState() => _QuizSheetState();
}

class _QuizSheetState extends State<QuizSheet> {
  /// Chosen option id per question, keyed by question id.
  final Map<String, String> _answers = <String, String>{};
  bool _revealed = false;

  int get _correctCount {
    var correct = 0;
    for (final question in widget.questions) {
      final picked = _answers[question.id];
      if (picked == null) continue;
      if (question.options.any((o) => o.id == picked && o.isCorrect)) correct++;
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.layoutMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Quick check',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spaceMd),
              for (final question in widget.questions)
                _QuestionCard(
                  question: question,
                  selected: _answers[question.id],
                  revealed: _revealed,
                  onSelect: (optionId) => setState(() {
                    _answers[question.id] = optionId;
                  }),
                ),
              const SizedBox(height: AppSpacing.spaceLg),
              if (_revealed)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.spaceMd),
                  child: Text(
                    '$_correctCount of ${widget.questions.length} correct.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: () {
                  if (!_revealed) {
                    setState(() => _revealed = true);
                    return;
                  }
                  Navigator.of(context).pop();
                },
                child: Text(_revealed ? 'Done' : 'Check answers'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.selected,
    required this.revealed,
    required this.onSelect,
  });

  final Question question;
  final String? selected;
  final bool revealed;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          for (final option in question.options)
            _OptionRow(
              option: option,
              selected: option.id == selected,
              revealed: revealed,
              onTap: revealed ? null : () => onSelect(option.id),
            ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.revealed,
    required this.onTap,
  });

  final QuestionOption option;
  final bool selected;
  final bool revealed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Before revealing, the server's is_correct flag must not leak through the
    // styling, or the answer becomes visible just by looking at the list.
    final bool isRight;
    final bool isWrong;
    if (revealed) {
      isRight = option.isCorrect;
      isWrong = selected && !option.isCorrect;
    } else {
      isRight = false;
      isWrong = false;
    }

    final Color background;
    final Color border;
    if (isRight) {
      background = colors.successSubtle;
      border = colors.successSolid;
    } else if (isWrong) {
      background = colors.dangerSubtle;
      border = colors.dangerSolid;
    } else if (selected) {
      background = colors.accentSubtle;
      border = colors.accentSolid;
    } else {
      background = colors.bgSurface;
      border = colors.borderDefault;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spaceXs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spaceMd,
            vertical: AppSpacing.spaceMd,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(
                revealed && isRight
                    ? Icons.check_circle
                    : revealed && isWrong
                    ? Icons.cancel
                    : selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: isRight
                    ? colors.successText
                    : isWrong
                    ? colors.dangerText
                    : colors.textMuted,
              ),
              const SizedBox(width: AppSpacing.spaceMd),
              Expanded(
                child: Text(
                  option.text,
                  style: TextStyle(color: colors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}