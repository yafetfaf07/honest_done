import 'package:flutter/material.dart';
import 'package:personal_prod/components/custom_circular_progress.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _showAddGoalSheet() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (BuildContext sheetContext) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setSheetState) {
              Future<void> pickDate() async {
                final DateTime now = DateTime.now();
                final DateTime initialDate =
                    selectedDate ?? DateTime(now.year, now.month, now.day);
                final DateTime? pickedDate = await showDatePicker(
                  context: sheetContext,
                  initialDate: initialDate,
                  firstDate: DateTime(now.year - 10),
                  lastDate: DateTime(now.year + 10),
                );

                if (pickedDate != null) {
                  setSheetState(() {
                    selectedDate = pickedDate;
                  });
                }
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Add Goal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        readOnly: true,
                        onTap: pickDate,
                        decoration: InputDecoration(
                          labelText: 'Date',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: pickDate,
                          ),
                          hintText: selectedDate == null
                              ? 'Select a date'
                              : MaterialLocalizations.of(
                                  sheetContext,
                                ).formatMediumDate(selectedDate!),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                        },
                        child: const Text('Save Goal'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      descriptionController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
        actions: [
          PopupMenuButton<String>(
            // This defines the icon that triggers the menu (replaces the IconButton)
            icon: const Icon(Icons.more_vert),

            // What happens when an option is selected
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

            // This builds the actual list of options
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, size: 20),
                    title: Text('Edit widget'),
                    contentPadding:
                        EdgeInsets.zero, // Cleans up internal spacing
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
                const PopupMenuDivider(), // Optional: adds a thin separating line
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
      body: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: const Text(
              "WELCOME BACK",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                SizedBox(
                  child: Column(
                    children: [
                      Text(
                        "Focus Score",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("You're in the top 5% of deep workers today!"),
                    ],
                  ),
                ),
                CustomCircularProgress(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
