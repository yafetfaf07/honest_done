import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:personal_prod/components/add_task_sheet.dart';
import 'package:personal_prod/components/custom_circular_progress.dart';
import 'package:personal_prod/components/state_views.dart';
import 'package:personal_prod/components/task_actions.dart';
import 'package:personal_prod/components/tasks_list.dart';
import 'package:personal_prod/models/models.dart';
import 'package:personal_prod/pages/analytics_page.dart';
import 'package:personal_prod/pages/goals_page.dart';
import 'package:personal_prod/pages/profile_page.dart';
import 'package:personal_prod/pages/tasks_page.dart';
import 'package:personal_prod/pages/timer_page.dart';
import 'package:personal_prod/state/auth_provider.dart';
import 'package:personal_prod/state/goals_provider.dart';
import 'package:personal_prod/state/tasks_provider.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';
import 'package:personal_prod/theme/surfaces.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final List<IconData> _icons = [
  Icons.home,
  Icons.track_changes,
  Icons.timer_sharp,
  Icons.bar_chart,
  Icons.person_outline,
];

final List<String> _pageTitles = [
  'Home',
  'Goals',
  'Timer',
  'Analytics',
  'Profile',
];

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    _HomeDashboard(
      onOpenTimer: () => setState(() => _selectedIndex = 2),
      onOpenTasks: () => _openAllTasks(),
    ),
    const GoalsPage(),
    const TimerPage(),
    const AnalyticsPage(),
    const ProfilePage(),
  ];

  Future<void> _openAllTasks() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TasksPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _icons.length,
        tabBuilder: (index, isActive) {
          return Icon(
            _icons[index],
            color: isActive ? colors.accentSolid : colors.textMuted,
          );
        },
        activeIndex: _selectedIndex,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.verySmoothEdge,

        leftCornerRadius: 32,
        rightCornerRadius: 32,
        elevation: 10,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        leading: const Icon(Icons.menu),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              switch (value) {
                case 'edit':
                  break;
                case 'delete':
                  break;
                case 'share':
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, size: 20),
                    title: Text('Edit widget'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share, size: 20),
                    title: Text('Share'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, size: 20, color: colors.dangerText),
                    title: Text(
                      'Delete',
                      style: TextStyle(color: colors.dangerText),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_selectedIndex],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({required this.onOpenTimer, required this.onOpenTasks});

  final VoidCallback onOpenTimer;
  final VoidCallback onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tasks = context.watch<TasksProvider>();
    final user = context.watch<AuthProvider>().user;
    final today = _tasksForToday(tasks.upcoming);

    return SingleChildScrollView(
      key: const ValueKey('home-dashboard'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.layoutMargin,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.spaceXl),
            Text(
              _greeting(user?.name),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Container(
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceMd,
                vertical: AppSpacing.spaceSm,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadii.lgAll,
                color: colors.bgSurface,
                boxShadow: AppShadows.cardBorder(context),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Focus Score',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spaceXs),
                        Text(
                          "You're in the top 5% of deep workers today!",
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  const CustomCircularProgress(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceXl),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsetsDirectional.only(
                  start: AppSpacing.spaceLg - 2,
                  end: AppSpacing.spaceLg,
                  top: AppSpacing.spaceMd,
                  bottom: AppSpacing.spaceMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.mdAll,
                ),
              ),
              onPressed: onOpenTimer,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer),
                  SizedBox(width: AppSpacing.spaceSm),
                  Text('Start Focus Session'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "TODAY'S TASKS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.textSecondary,
                  ),
                ),
                TextButton(
                  onPressed: onOpenTasks,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            _TodayTasks(tasks: today),
          ],
        ),
      ),
    );
  }

  /// Greeting line. The dashboard used to always read "WELCOME BACK" with no
  /// name, so there was nothing tying it to the signed-in account.
  static String _greeting(String? name) {
    final first = (name ?? '').trim().split(RegExp(r'\s+')).first;
    if (first.isEmpty) return 'WELCOME BACK';
    return 'WELCOME BACK, ${first.toUpperCase()}';
  }

  /// Only tasks scheduled for today, capped so the dashboard does not grow
  /// without bound.
  static List<Task> _tasksForToday(List<Task> upcoming) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return upcoming.where((t) {
      final at = t.scheduleTime.toLocal();
      return !at.isBefore(today) && at.isBefore(tomorrow);
    }).take(5).toList(growable: false);
  }
}

/// The dashboard's task strip.
///
/// The four `TasksList()` widgets that stood here were the same hardcoded row
/// repeated, so the count and content never changed.
class _TodayTasks extends StatelessWidget {
  const _TodayTasks({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TasksProvider>();

    if (provider.isInitialLoad) return const LoadingView();

    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spaceLg,
          vertical: AppSpacing.spaceXl,
        ),
        decoration: BoxDecoration(
          color: context.colors.bgSurface,
          borderRadius: AppRadii.lgAll,
          boxShadow: AppShadows.cardBorder(context),
        ),
        child: Column(
          children: [
            Text(
              'Nothing scheduled for today.',
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
            TextButton(
              onPressed: () => _addTask(context),
              child: const Text('Add a task'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final task in tasks)
          TaskTile(
            task: task,
            pending: provider.isPending(task.id),
            onToggle: (completed) => toggleTask(context, task, completed),
            onDelete: () => deleteTask(context, task),
          ),
        const SizedBox(height: AppSpacing.spaceSm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _addTask(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add a task'),
          ),
        ),
      ],
    );
  }

  /// Task creation needs a goal, since the backend keys tasks by goal id.
  static Future<void> _addTask(BuildContext context) async {
    if (context.read<GoalsProvider>().goals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a goal first, then add tasks to it.')),
      );
      return;
    }

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddTaskSheet(),
    );
    if (created == true && context.mounted) {
      await context.read<GoalsProvider>().refresh();
    }
  }
}