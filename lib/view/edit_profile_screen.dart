import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tunetrail/models/user.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../controller/auth_controller.dart';
import '../models/profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController _authController = AuthController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  
  Profile? _userProfile;
  bool _isLoading = true;
  bool _isSaving = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final User? user = _authController.usuarioLogado;
      if (user != null) {
        final Profile? profile = await _authController.profileRepository.readOne(user.id);
        if (profile != null) {
          setState(() {
            _userProfile = profile;
            _nameController.text = profile.nome;
            _selectedDate = profile.dataNasc;
            _birthDateController.text = DateFormat('dd/MM/yyyy').format(profile.dataNasc);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar perfil: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.card,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome não pode estar vazio')),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data de nascimento é obrigatória')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final Profile updatedProfile = Profile(
        id: _userProfile!.id,
        nome: _nameController.text.trim(),
        dataNasc: _selectedDate!,
        genero: _userProfile!.genero,
        fotoUrl: _userProfile!.fotoUrl,
        tipo: _userProfile!.tipo,
      );

      await _authController.profileRepository.update(_userProfile!.id!, updatedProfile);

      setState(() {
        _userProfile = updatedProfile;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar perfil: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          'Editar perfil',
          style: AppTextStyles.headlineMedium(color: AppColors.primaryColor),
        ),
        actions: <Widget>[
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Salvar',
                style: AppTextStyles.button(color: AppColors.primaryColor),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 24),
                  
                  // Nome Field
                  Text(
                    'Nome',
                    style: AppTextStyles.subtitleMedium(),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: AppTextStyles.inputText(),
                    decoration: InputDecoration(
                      hintText: 'Digite seu nome',
                      hintStyle: AppTextStyles.hintText(),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Data de Nascimento Field
                  Text(
                    'Data de nascimento',
                    style: AppTextStyles.subtitleMedium(),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _birthDateController,
                    style: AppTextStyles.inputText(),
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: InputDecoration(
                      hintText: 'Selecione sua data de nascimento',
                      hintStyle: AppTextStyles.hintText(),
                      filled: true,
                      fillColor: AppColors.card,
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: AppColors.primaryColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor: AppColors.textDisabled,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.textPrimary,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Salvar alterações',
                              style: AppTextStyles.button().copyWith(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }
}

