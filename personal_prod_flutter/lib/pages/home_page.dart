import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:personal_prod/components/custom_circular_progress.dart';
import 'package:personal_prod/components/tasks_list.dart';
import 'package:personal_prod/pages/analytics_page.dart';
import 'package:personal_prod/pages/goals_page.dart';
import 'package:personal_prod/pages/profile_page.dart';
import 'package:personal_prod/pages/timer_page.dart';
import 'package:personal_prod/theme/colors.dart';
import 'package:personal_prod/theme/spacing.dart';

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
    const _HomeDashboard(),
    const GoalsPage(),
    const TimerPage(),
    const AnalyticsPage(),
    const ProfilePage(),
  ];

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
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              'WELCOME BACK',
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
                borderRadius: BorderRadius.circular(8),
                color: colors.bgSurface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                  ),
                ],
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
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.spaceMd,
                  horizontal: AppSpacing.spaceLg,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
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
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            const Column(
              children: [
                TasksList(),
                TasksList(),
                TasksList(),
                TasksList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}