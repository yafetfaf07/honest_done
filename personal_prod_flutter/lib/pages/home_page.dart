import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:personal_prod/components/custom_circular_progress.dart';
import 'package:personal_prod/components/tasks_list.dart';
import 'package:personal_prod/pages/analytics_page.dart';
import 'package:personal_prod/pages/goals_page.dart';
import 'package:personal_prod/pages/profile_page.dart';
import 'package:personal_prod/pages/timer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final List<Icon> _icons = [
  Icon(Icons.home),
  Icon(Icons.track_changes),
  Icon(Icons.timer_sharp),
  Icon(Icons.bar_chart),
  Icon(Icons.person_outline),
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
    return Scaffold(
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _icons.length,
        tabBuilder: (index, isActive) {
          return Icon(
            _icons[index].icon,
            color: isActive ? Colors.green : Colors.grey,
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
                  // Handle edit action
                  break;
                case 'delete':
                  // Handle delete action
                  break;
                case 'share':
                  // Handle share action
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
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red, size: 20),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
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
    return SingleChildScrollView(
      key: const ValueKey('home-dashboard'),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'WELCOME BACK',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Focus Score',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "You're in the top 5% of deep workers today!",
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                CustomCircularProgress(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.grey.shade50,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
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
                  SizedBox(width: 8),
                  Text('Start Focus Session'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TODAY'S TASKS",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return const TasksList();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
