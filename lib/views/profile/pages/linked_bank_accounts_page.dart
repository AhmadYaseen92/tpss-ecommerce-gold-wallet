import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/view_models/profile_cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/views/common/widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/views/signup/widgets/signup_header_widget.dart';

class LinkedBankAccountsPage extends StatelessWidget {
  const LinkedBankAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          final selectedBank = cubit.bankAccounts[state.selectedBankIndex];

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: AppColors.backgroundColor,
              title: Text(
                'Linked Bank Accounts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: cubit.toggleEdit,
                  icon: Icon(state.isEditing ? Icons.close : Icons.edit),
                  label: Text(state.isEditing ? 'Cancel' : 'Edit'),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SignupHeader(
                      title: 'Bank Information',
                      subtitle: 'Select bank account then edit its fields.',
                    ),
                    const SizedBox(height: 20),
                    const SignupSectionLabel(label: 'SELECT BANK ACCOUNT'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: state.selectedBankIndex,
                      items: List.generate(
                        cubit.bankAccounts.length,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text(cubit.bankAccounts[index].name),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          cubit.selectBankAccount(value);
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SignupSectionLabel(label: 'ACCOUNT FIELDS'),
                    ...List.generate(selectedBank.fields.length, (index) {
                      final field = selectedBank.fields[index];
                      return AppTextField(
                        label: field.label,
                        hint: field.label,
                        prefixIcon: field.icon,
                        keyboardType: field.keyboardType,
                        controller: cubit.bankControllers[index],
                        enabled: state.isEditing,
                      );
                    }),
                    if (state.isEditing) ...[
                      const SizedBox(height: 16),
                      AppButton(
                        cubit: cubit,
                        label: 'Save Changes',
                        onPressed: () {
                          cubit.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bank account details saved successfully'),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
