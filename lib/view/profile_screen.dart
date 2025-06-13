import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tunetrail/models/user.dart';
import 'dart:io';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../controller/auth_controller.dart';
import '../models/profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 2;
  final AuthController _authController = AuthController();
  final ImagePicker _imagePicker = ImagePicker();
  Profile? _userProfile;
  bool _isLoading = true;

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
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserType(String newType) async {
    if (_userProfile != null) {
      try {
        final Profile updatedProfile = Profile(
          id: _userProfile!.id,
          nome: _userProfile!.nome,
          dataNasc: _userProfile!.dataNasc,
          genero: _userProfile!.genero,
          fotoUrl: _userProfile!.fotoUrl,
          tipo: newType,
        );
        
        await _authController.profileRepository.update(_userProfile!.id!, updatedProfile);
        
        setState(() {
          _userProfile = updatedProfile;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar tipo de usuário: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      if (_userProfile != null) {
        setState(() {
          _isLoading = true;
        });

        if (_userProfile!.fotoUrl != null && _userProfile!.fotoUrl!.isNotEmpty) {
          try {
            final String oldImagePath = _userProfile!.fotoUrl!.split('/').last;
            await _authController.supaClient.storage
                .from('profile-images')
                .remove(<String>[oldImagePath]);
          } catch (e) {
            //
          }
        }

        final String fileName = '${_userProfile!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File imageFile = File(pickedFile.path);
        
        await _authController.supaClient.storage
            .from('profile-images')
            .upload(fileName, imageFile);

        final String imageUrl = _authController.supaClient.storage
            .from('profile-images')
            .getPublicUrl(fileName);

        final Profile updatedProfile = Profile(
          id: _userProfile!.id,
          nome: _userProfile!.nome,
          dataNasc: _userProfile!.dataNasc,
          genero: _userProfile!.genero,
          fotoUrl: imageUrl,
          tipo: _userProfile!.tipo,
        );

        await _authController.profileRepository.update(_userProfile!.id!, updatedProfile);

        setState(() {
          _userProfile = updatedProfile;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada com sucesso!')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar foto de perfil: $e')),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Sair',
            style: AppTextStyles.headlineSmall(),
          ),
          content: Text(
            'Tem certeza que deseja sair?',
            style: AppTextStyles.bodyMedium(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: AppTextStyles.button(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                _authController.logout();
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text(
                'Sair',
                style: AppTextStyles.button(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'lib/assets/tunetrail_banner.png',
            width: 32,
            height: 32,
          ),
        ),
        title: Text(
          'Perfil',
          style: AppTextStyles.headlineMedium(color: AppColors.primaryColor),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(
              Icons.logout,
              color: AppColors.textPrimary,
              size: 28,
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
                children: <Widget>[
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        shape: BoxShape.circle,
                        image: _userProfile?.fotoUrl != null && _userProfile!.fotoUrl!.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_userProfile!.fotoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _userProfile?.fotoUrl == null || _userProfile!.fotoUrl!.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.textPrimary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    _userProfile?.nome ?? 'Nome do usuário',
                    style: AppTextStyles.headlineMedium(),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildActionButton('Editar perfil', () {
                    Navigator.pushNamed(context, 
                      '/edit_profile').then((_) {
                      _loadUserProfile();
                    });
                  }),
                  const SizedBox(height: 16),
                  _buildActionButton('Minhas playlists', () {
                    Navigator.pushNamed(context, '/my_playlists');
                  }),
                  const SizedBox(height: 16),
                  _buildActionButton('Favoritos', () {
                    // TODO: Implementar tela de favoritos
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                    );
                  }),
                  const SizedBox(height: 16),
                  _buildActionButton('Criar playlist', () {
                    Navigator.pushNamed(context, '/create_playlist');
                  }),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Quem você é por aqui?',
                    style: AppTextStyles.headlineSmall(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecione abaixo como deseja usar o app',
                    style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildUserTypeCard(
                          'Artista',
                          Icons.mic,
                          _userProfile?.tipo == 'Artista',
                          () => _updateUserType('Artista'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildUserTypeCard(
                          'Usuário',
                          Icons.person,
                          _userProfile?.tipo == 'Usuário' || _userProfile?.tipo == null,
                          () => _updateUserType('Usuário'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: 2,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: 'Eventos'),
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home_screen');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/buscar_screen');
              break;
            case 2:
              break;
            case 3:
              // Eventos
              break;
          }
        },
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.button().copyWith(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard(String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primaryColor, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : AppColors.inputBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.subtitleMedium(
                color: isSelected ? AppColors.primaryColor : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
