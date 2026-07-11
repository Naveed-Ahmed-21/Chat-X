import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String fieldName;
  final RxString editingField;
  final bool editable;
  final RxBool hasChanges;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
    required this.fieldName,
    required this.editingField,
    this.editable = true,
    required this.hasChanges,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isEditing = editingField.value == fieldName;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Icon(icon),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),

                  const SizedBox(height: 5),

                  isEditing
                      ? TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  )
                      : Text(
                    controller.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            if (editable)
              IconButton(
                onPressed: () {
                  editingField.value = fieldName;
                },
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
      );
    });
  }
}