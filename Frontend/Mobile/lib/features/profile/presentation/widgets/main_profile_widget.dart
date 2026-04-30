import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tpss_ecommerce_gold_wallet/core/auth/auth_session_store.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_release_config.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/core/utils/server_url_resolver.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/data/datasources/profile_remote_datasource.dart';

class MainProfileWidget extends StatefulWidget {
  const MainProfileWidget({super.key});

  @override
  State<MainProfileWidget> createState() => _MainProfileWidgetState();
}

class _MainProfileWidgetState extends State<MainProfileWidget> {
  final Dio _dio = InjectionContainer.dio();
  late final ProfileRemoteDataSource _remoteDataSource = ProfileRemoteDataSource(_dio);
  final ImagePicker _imagePicker = ImagePicker();

  late Future<ProfileRemoteModel> _profileFuture;
  Uint8List? _selectedImageBytes;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _remoteDataSource.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return FutureBuilder<ProfileRemoteModel>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Failed to load profile data.', style: TextStyle(color: palette.textSecondary)),
          );
        }

        final profile = snapshot.data!;
        final avatarImage = _buildAvatarImage(profile);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: palette.surfaceMuted,
                    backgroundImage: avatarImage,
                    child: avatarImage == null ? Icon(Icons.person, size: 42, color: palette.textSecondary) : null,
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Material(
                      color: AppColors.green,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _isUploadingPhoto ? null : () => _showImageSourcePicker(profile),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _isUploadingPhoto
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.camera_alt_outlined, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      profile.fullName,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      border: Border.all(color: AppColors.green),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified, color: AppColors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(profile.email, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSecondary)),
              const SizedBox(height: 4),
              Text(profile.phoneNumber ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSecondary)),
            ],
          ),
        );
      },
    );
  }

  ImageProvider? _buildAvatarImage(ProfileRemoteModel profile) {
    if (_selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    }

    final profilePhoto = profile.profilePhotoUrl.trim();
    if (profilePhoto.isEmpty) return null;

    if (profilePhoto.startsWith('data:image')) {
      final commaIndex = profilePhoto.indexOf(',');
      if (commaIndex == -1) return null;
      final base64Data = profilePhoto.substring(commaIndex + 1);
      try {
        final bytes = base64Decode(base64Data);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }

    final resolvedPhotoUrl = resolveServerUrl(profilePhoto);
    final photoUri = Uri.tryParse(resolvedPhotoUrl);
    final hasValidPhotoUrl =
        photoUri != null && (photoUri.scheme == 'http' || photoUri.scheme == 'https') && photoUri.host.isNotEmpty;

    return hasValidPhotoUrl ? NetworkImage(resolvedPhotoUrl) : null;
  }

  Future<void> _showImageSourcePicker(ProfileRemoteModel profile) async {
    final source = await showModalBottomSheet<_ProfileImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.of(context).pop(_ProfileImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () => Navigator.of(context).pop(_ProfileImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: const Text('Upload from files'),
                  onTap: () => Navigator.of(context).pop(_ProfileImageSource.files),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    switch (source) {
      case _ProfileImageSource.camera:
        await _pickFromCamera(profile);
        break;
      case _ProfileImageSource.gallery:
        await _pickFromGallery(profile);
        break;
      case _ProfileImageSource.files:
        await _pickFromFiles(profile);
        break;
    }
  }

  Future<void> _pickFromCamera(ProfileRemoteModel profile) async {
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      await _updateProfilePhoto(profile: profile, bytes: bytes, fileName: picked.name);
    } catch (_) {
      _showError('Could not open camera. Please allow camera access and try again.');
    }
  }

  Future<void> _pickFromGallery(ProfileRemoteModel profile) async {
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      await _updateProfilePhoto(profile: profile, bytes: bytes, fileName: picked.name);
    } catch (_) {
      _showError('Could not open gallery. Please allow photo access and try again.');
    }
  }

  Future<void> _pickFromFiles(ProfileRemoteModel profile) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes ?? (file.path != null ? await File(file.path!).readAsBytes() : null);

      if (bytes == null) {
        _showError('Unable to read selected file. Please try another image.');
        return;
      }

      await _updateProfilePhoto(profile: profile, bytes: bytes, fileName: file.name);
    } catch (_) {
      _showError('Could not open files. Please check file permissions and try again.');
    }
  }

  Future<void> _updateProfilePhoto({
    required ProfileRemoteModel profile,
    required Uint8List bytes,
    required String fileName,
  }) async {
    setState(() {
      _isUploadingPhoto = true;
      _selectedImageBytes = bytes;
    });

    try {
      final mimeType = _resolveMimeType(fileName);
      final encoded = base64Encode(bytes);
      final dataUrl = 'data:$mimeType;base64,$encoded';

      await _uploadProfilePhotoWithOtpPolicy(profile: profile, dataUrl: dataUrl);

      if (!mounted) return;
      setState(() {
        _profileFuture = _remoteDataSource.getProfile();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated successfully.')),
      );
    } catch (_) {
      _showError('Failed to update profile photo. Please try again.');
      setState(() {
        _selectedImageBytes = null;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isUploadingPhoto = false;
      });
    }
  }


  Future<void> _uploadProfilePhotoWithOtpPolicy({
    required ProfileRemoteModel profile,
    required String dataUrl,
  }) async {
    try {
      await _remoteDataSource.updateProfilePhoto(profile: profile, profilePhotoUrl: dataUrl);
    } on DioException catch (error) {
      if (!_requiresOtpToken(error)) rethrow;

      final otpGrant = await _requestOtpGrantForProfilePhoto();
      if (otpGrant == null) {
        throw StateError('OTP verification is required to update your profile photo.');
      }

      await _remoteDataSource.updateProfilePhoto(
        profile: profile,
        profilePhotoUrl: dataUrl,
        otpVerificationToken: otpGrant.verificationToken,
        otpActionReferenceId: otpGrant.actionReferenceId,
      );
    }
  }

  Future<_OtpGrant?> _requestOtpGrantForProfilePhoto() async {
    if (!AppReleaseConfig.isOtpRequiredForAction('change_mobile_number')) {
      return null;
    }

    final userId = AuthSessionStore.userId;
    if (userId == null) {
      _showError('No logged-in user found. Please login again.');
      return null;
    }

    final actionReferenceId = 'profile:change_mobile_number:$userId';

    try {
      final requestResp = await _dio.post(
        '/otp/request',
        data: {
          'userId': userId,
          'actionType': 'change_mobile_number',
          'actionReferenceId': actionReferenceId,
        },
      );

      final requestData = (requestResp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      final otpRequestId = (requestData['otpRequestId'] ?? '').toString().trim();
      if (otpRequestId.isEmpty) {
        throw StateError('OTP request failed.');
      }

      final otpCode = await _showOtpInputDialog();
      if (!mounted || otpCode == null || otpCode.length < 6) return null;

      final verifyResp = await _dio.post(
        '/otp/verify',
        data: {
          'userId': userId,
          'otpRequestId': otpRequestId,
          'otpCode': otpCode,
        },
      );

      final verifyData = (verifyResp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>? ?? {};
      final verificationToken = (verifyData['verificationToken'] ?? '').toString().trim();
      final verifiedRef = (verifyData['actionReferenceId'] ?? '').toString().trim();

      if (verificationToken.isEmpty) {
        throw StateError('OTP verification failed.');
      }

      return _OtpGrant(
        verificationToken: verificationToken,
        actionReferenceId: verifiedRef.isEmpty ? actionReferenceId : verifiedRef,
      );
    } catch (error) {
      _showError(_extractDisplayErrorMessage(error));
      return null;
    }
  }

  Future<String?> _showOtpInputDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm OTP'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(labelText: 'OTP Code'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  bool _requiresOtpToken(DioException error) {
    final message = _extractDisplayErrorMessage(error).toLowerCase();
    return message.contains('otp verification token is required');
  }

  String _extractDisplayErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = (data['message'] ?? data['error'] ?? '').toString().trim();
        if (message.isNotEmpty) return message;
        final nested = data['data'];
        if (nested is Map) {
          final nestedMessage = (nested['message'] ?? nested['error'] ?? '').toString().trim();
          if (nestedMessage.isNotEmpty) return nestedMessage;
        }
      }
      if (data is String && data.trim().isNotEmpty) return data.trim();
      if ((error.message ?? '').trim().isNotEmpty) return error.message!.trim();
    }
    return 'Something went wrong. Please try again.';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _resolveMimeType(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.png')) return 'image/png';
    if (lowerName.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}

enum _ProfileImageSource { camera, gallery, files }


class _OtpGrant {
  const _OtpGrant({required this.verificationToken, required this.actionReferenceId});

  final String verificationToken;
  final String actionReferenceId;
}
