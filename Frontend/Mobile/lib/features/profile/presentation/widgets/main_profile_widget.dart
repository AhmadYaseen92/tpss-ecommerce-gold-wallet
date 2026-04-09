import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/di/injection_container.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/data/datasources/profile_remote_datasource.dart';

class MainProfileWidget extends StatelessWidget {
  MainProfileWidget({super.key});

  final ProfileRemoteDataSource _remoteDataSource = ProfileRemoteDataSource(InjectionContainer.dio());

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return FutureBuilder<ProfileRemoteModel>(
      future: _remoteDataSource.getProfile(),
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

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: palette.surfaceMuted,
                backgroundImage: profile.profilePhotoUrl.isNotEmpty ? NetworkImage(profile.profilePhotoUrl) : null,
                child: profile.profilePhotoUrl.isEmpty ? Icon(Icons.person, size: 42, color: palette.textSecondary) : null,
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
}
