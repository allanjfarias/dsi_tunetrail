import 'package:flutter/material.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:tunetrail/constants/colors.dart';
import 'package:tunetrail/constants/text_styles.dart';
import 'package:tunetrail/controller/event_controller.dart';
import 'package:tunetrail/models/event.dart';

class EventPopup extends StatelessWidget {
  final Event event;
  final EventController eventController;
  final PopupController popupController;

  const EventPopup({
    super.key,
    required this.event,
    required this.eventController,
    required this.popupController,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOwner = eventController.isOwner(event);

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        event.name,
                        style: AppTextStyles.headlineSmall().copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: popupController.hideAllPopups,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: AppTextStyles.bodyMedium().copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (isOwner) ...<Widget>[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit, color: AppColors.primaryColor),
                        onPressed: () {
                          popupController.hideAllPopups();
                          eventController.showEditEventDialog(context, event);
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete, color: AppColors.error),
                        onPressed: () async {
                          try {
                            await eventController.deleteEvent(event);
                            await eventController.loadEvents();
                            popupController.hideAllPopups();

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Evento excluído com sucesso'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao excluir evento: $e'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
