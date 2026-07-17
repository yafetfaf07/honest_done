import 'package:flutter/material.dart';

class TasksList extends StatefulWidget {
  const TasksList({super.key});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  // Track whether this specific task is selected/completed
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Tweaked slightly for radio alignment
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Substituted your static Container icon with a functional Radio button
          Radio<bool>(
            value: true, 
            groupValue: isSelected, 
            activeColor: const Color(0xFF2ED36B), // The green from your original design
            toggleable: true, // Allows unchecking by tapping it again
            onChanged: (bool? value) {
              setState(() {
                // If it's already true, uncheck it (set to false). Otherwise, check it.
                isSelected = value ?? false;
              });
            },
          ),
          const SizedBox(width: 4), // Adjusted spacing slightly to balance out Radio margins
          const Expanded(
            child: Text(
              'Brand Identity Design',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2430),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '14:00',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF596272),
            ),
          ),
        ],
      ),
    );
  }
}