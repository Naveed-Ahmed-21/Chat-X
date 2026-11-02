import 'dart:ui';
import 'package:chatx_app/model/message_model.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/floating_reaction_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'message_preview_bubble.dart';

class MessageOverlay {
  static OverlayEntry? _overlay;

  static void hide({VoidCallback? onDismiss}) {
    _overlay?.remove();
    _overlay = null;

    onDismiss?.call();
  }

  static void show({
    required BuildContext context,
    required BuildContext messageContext,
    required MessageModel message,
    required bool isComing,
    required VoidCallback onDismiss,
    required VoidCallback onShow,
    MessageModel? repliedMessage,
    String repliedSenderName = "",
    required Function(String emoji) onReaction,
    required VoidCallback onReply,
    required VoidCallback onCopy,
    required VoidCallback onForward,
    VoidCallback? onInfo,
    VoidCallback? onEdit,
    required VoidCallback onDelete,
    bool showEdit = false,
  }) {
    hide();
    onShow();
    HapticFeedback.mediumImpact();

    final RenderBox bubble = messageContext.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset bubblePosition = bubble.localToGlobal(Offset.zero, ancestor: overlay);
    // final Size bubbleSize = bubble.size;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    _overlay = OverlayEntry(
      builder: (_) {
        bool showReactionsAbove = bubblePosition.dy > 100;

        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              /// Dark Blurred background - Global Dismiss
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => hide(onDismiss: onDismiss),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    width: screenWidth,
                    height: screenHeight,
                    color: Colors.black.withValues(alpha: .4),
                  ),
                ),
              ),

              /// Content Area
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: Column(
                      crossAxisAlignment: isComing ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                      children: [
                        // Top Spacer
                        SizedBox(height: (bubblePosition.dy - (showReactionsAbove ? 70 : 0)).clamp(0, screenHeight)),

                        if (showReactionsAbove) ...[
                          GestureDetector(
                            onTap: () {}, // Prevent dismissal when tapping reactions
                            child: FloatingReactionPicker(
                              onSelected: (emoji) async {
                                hide(onDismiss: onDismiss);
                                await onReaction(emoji);
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // The Message
                        GestureDetector(
                          onTap: () {}, // Prevent dismissal when tapping bubble
                          child: MessagePreviewBubble(
                            message: message,
                            isComing: isComing,
                            repliedMessage: repliedMessage,
                            repliedSenderName: repliedSenderName,
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (!showReactionsAbove) ...[
                          GestureDetector(
                            onTap: () {}, // Prevent dismissal when tapping reactions
                            child: FloatingReactionPicker(
                              onSelected: (emoji) async {
                                hide(onDismiss: onDismiss);
                                await onReaction(emoji);
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // The Menu
                        GestureDetector(
                          onTap: () {}, // Prevent dismissal when tapping menu
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildMenuItem(context, "Reply", Icons.reply, () {
                                    hide(onDismiss: onDismiss);
                                    onReply();
                                  }),
                                  const Divider(height: 1, thickness: 0.5),
                                  _buildMenuItem(context, "Copy", Icons.copy, () {
                                    hide(onDismiss: onDismiss);
                                    onCopy();
                                  }),
                                  const Divider(height: 1, thickness: 0.5),
                                  _buildMenuItem(context, "Forward", Icons.shortcut_rounded, () {
                                    hide(onDismiss: onDismiss);
                                    onForward();
                                  }),
                                  if (onInfo != null) ...[
                                    const Divider(height: 1, thickness: 0.5),
                                    _buildMenuItem(context, "Info", Icons.info_outline, () {
                                      hide(onDismiss: onDismiss);
                                      onInfo();
                                    }),
                                  ],
                                  if (showEdit) ...[
                                    const Divider(height: 1, thickness: 0.5),
                                    _buildMenuItem(context, "Edit", Icons.edit, () {
                                      hide(onDismiss: onDismiss);
                                      onEdit?.call();
                                    }),
                                  ],
                                  const Divider(height: 1, thickness: 0.5),
                                  _buildMenuItem(context, "Delete", Icons.delete_outline, () {
                                    hide(onDismiss: onDismiss);
                                    onDelete();
                                  }, color: Colors.red),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
  }

  static Widget _buildMenuItem(BuildContext context, String title, IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: color ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(icon, size: 20, color: color ?? Theme.of(context).colorScheme.onSurface),
          ],
        ),
      ),
    );
  }
}
