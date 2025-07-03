import 'package:flutter/material.dart';
import 'package:tunetrail/controller/auth_controller.dart';
import 'package:tunetrail/controller/event_controller.dart';
import 'package:tunetrail/models/event.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

class EventDetailsPopup extends StatelessWidget {
  final Event event;
  final EventController eventController;
  final AuthController authController;

  const EventDetailsPopup({
    super.key,
    required this.event,
    required this.eventController,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    style: AppTextStyles.headlineSmall(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event.description,
              style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}