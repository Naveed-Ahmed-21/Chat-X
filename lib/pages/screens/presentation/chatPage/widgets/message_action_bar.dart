import 'package:flutter/material.dart';

class MessageActionBar extends StatelessWidget {
  final VoidCallback onReply;
  final VoidCallback onCopy;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  final bool showEdit;

  const MessageActionBar({
    super.key,
    required this.onReply,
    required this.onCopy,
    required this.onDelete,
    required this.showEdit,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            _ActionButton(
              icon: Icons.reply_rounded,
              text: "Reply",
              onTap: onReply,
            ),

            _ActionButton(
              icon: Icons.copy_rounded,
              text: "Copy",
              onTap: onCopy,
            ),

            if (showEdit)
              _ActionButton(
                icon: Icons.edit_rounded,
                text: "Edit",
                onTap: onEdit!,
              ),

            _ActionButton(
              icon: Icons.delete_outline_rounded,
              text: "Delete",
              color: Colors.red,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.text,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Icon(
              icon,
              color: c,
              size: 28,
            ),

            const SizedBox(height: 4),

            Text(
              text,
              style: TextStyle(
                color: c,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),

          ],
        ),
      ),
    );
  }
}