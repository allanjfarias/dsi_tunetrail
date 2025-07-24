import 'package:flutter/material.dart';
import 'package:tunetrail/constants/colors.dart';
import 'package:tunetrail/constants/text_styles.dart';
import 'package:tunetrail/models/event.dart';

class EventDialog extends StatelessWidget {
  final String title;
  final Event? event;
  final Function(String, String) onSubmit;

  const EventDialog({
    super.key,
    required this.title,
    this.event,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(text: event?.name ?? '');
    final TextEditingController descController = TextEditingController(text: event?.description ?? '');

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.headlineSmall().copyWith(
                    color: event == null 
                        ? AppColors.primaryColor 
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: nameController,
                  label: 'Nome do evento',
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: descController,
                  label: 'Descrição',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                _buildActionButtons(context, nameController, descController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      style: AppTextStyles.bodyLarge(),
      maxLines: maxLines,
      minLines: 1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController descController,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancelar',
            style: AppTextStyles.bodyMedium(color: AppColors.error),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('O nome do evento é obrigatório'),
                  backgroundColor: AppColors.card,
                ),
              );
              return;
            }
            onSubmit(nameController.text, descController.text);
            Navigator.pop(context);
          },
          child: Text(
            event == null ? 'Criar' : 'Salvar',
            style: AppTextStyles.bodyMedium(color: Colors.white),
          ),
        ),
      ],
    );
  }
}