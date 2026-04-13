import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/form_header.dart';

class LinkedBankAccountsPage extends StatelessWidget {
  const LinkedBankAccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = BlocProvider.of<ProfileCubit>(context);
          final palette = context.appPalette;
          final hasBanks = cubit.bankAccounts.isNotEmpty;
          final selectedBank = hasBanks
              ? cubit.bankAccounts[cubit.selectedBankIndex]
              : const ProfileOption(
                  name: 'No linked banks yet',
                  subtitle: 'Tap Add Account to create one',
                  icon: Icons.account_balance_outlined,
                  fields: [
                    ProfileField('Account Holder Name', Icons.person_outline),
                    ProfileField('Bank Name', Icons.account_balance_outlined),
                    ProfileField('Account Number', Icons.numbers_outlined),
                    ProfileField('IBAN', Icons.credit_card_outlined),
                    ProfileField('SWIFT/BIC', Icons.verified_user_outlined),
                    ProfileField('Branch Name', Icons.store_outlined),
                    ProfileField('Branch Address', Icons.location_on_outlined),
                    ProfileField('Country', Icons.flag_outlined),
                    ProfileField('City', Icons.location_city_outlined),
                    ProfileField('Currency', Icons.currency_exchange_outlined),
                  ],
                );

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Linked Bank Accounts',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: palette.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: cubit.toggleEdit,
                  icon: Icon(cubit.isEditing ? Icons.close : Icons.edit),
                  label: Text(cubit.isEditing ? 'Cancel' : 'Edit'),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormHeader(
                      title: 'Bank Information',
                      subtitle: 'Select bank account then edit its fields.',
                    ),
                    const SizedBox(height: 20),
                    const FormSectionLabel(label: 'SELECT BANK ACCOUNT'),
                    const SizedBox(height: 8),
                    if (cubit.isEditing)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: cubit.addBankAccount,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Account'),
                        ),
                      ),
                    DropdownButtonFormField<int>(
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: palette.surface,
                      value: hasBanks ? cubit.selectedBankIndex : null,
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
                        fillColor: palette.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: palette.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: palette.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const FormSectionLabel(label: 'ACCOUNT FIELDS'),
                    ...List.generate(selectedBank.fields.length, (index) {
                      final field = selectedBank.fields[index];
                      return AppTextField(
                        label: field.label,
                        hint: field.label,
                        prefixIcon: field.icon,
                        keyboardType: field.keyboardType,
                        controller: cubit.bankControllers[index],
                        enabled: cubit.isEditing,
                      );
                    }),
                    if (cubit.isEditing && hasBanks) ...[
                      const SizedBox(height: 16),
                      AppButton(
                        cubit: cubit,
                        label: 'Save Changes',
                        onPressed: () {
                          cubit.saveLinkedBank();
                          AppModalAlert.show(
                            context,
                            title: 'Saved',
                            message: 'Bank account details saved successfully',
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
