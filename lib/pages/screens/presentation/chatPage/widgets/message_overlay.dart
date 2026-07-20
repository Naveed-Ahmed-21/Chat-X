import 'package:chatx_app/model/message_model.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/floating_reaction_picker.dart';
import 'package:chatx_app/pages/screens/presentation/chatPage/widgets/message_action_bar.dart';
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
    VoidCallback? onEdit,
    required VoidCallback onDelete,

    bool showEdit = false,
  }) {
    hide();

    onShow();

    HapticFeedback.mediumImpact();

    final RenderBox bubble =
        messageContext.findRenderObject() as RenderBox;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset bubblePosition = bubble.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );

    final Size bubbleSize = bubble.size;

    const pickerWidth = 320.0;
    const pickerHeight = 56.0;
    const margin = 12.0;

    double pickerLeft = bubblePosition.dx;

    if (pickerLeft + pickerWidth > overlay.size.width - margin) {
      pickerLeft = overlay.size.width - pickerWidth - margin;
    }

    if (pickerLeft < margin) {
      pickerLeft = margin;
    }

    double pickerTop = bubblePosition.dy - pickerHeight - 8;

    if (pickerTop < margin) {
      pickerTop = bubblePosition.dy + bubbleSize.height + 8;
    }

    _overlay = OverlayEntry(
      builder: (_) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              /// Dark background
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  hide(onDismiss: onDismiss);
                },
                child: Container(color: Colors.black.withValues(alpha: .45)),
              ),

              /// Message Preview Bubble
              Positioned(
                left: bubblePosition.dx,
                top: bubblePosition.dy,
                child: AnimatedScale(
                  scale: 1,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: MessagePreviewBubble(
                    message: message,
                    isComing: isComing,
                    repliedMessage: repliedMessage,
                    repliedSenderName: repliedSenderName,
                  ),
                ),
              ),

              /// Reaction Picker
              Positioned(
                left: pickerLeft,
                top: pickerTop,
                child: FloatingReactionPicker(
                  onSelected: (emoji) async {
                    hide(onDismiss: onDismiss);

                    await onReaction(emoji);
                  },
                ),
              ),

              /// Bottom Action Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 15,
                child: MessageActionBar(
                  showEdit: showEdit,

                  onReply: () {
                    hide(onDismiss: onDismiss);
                    onReply();
                  },

                  onCopy: () {
                    hide(onDismiss: onDismiss);
                    onCopy();
                  },

                  onEdit: showEdit
                      ? () {
                          hide(onDismiss: onDismiss);
                          onEdit?.call();
                        }
                      : null,

                  onDelete: () {
                    hide(onDismiss: onDismiss);
                    onDelete();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
  }
}
