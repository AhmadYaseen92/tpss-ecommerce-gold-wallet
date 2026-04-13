import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/form_header.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final cubit = BlocProvider.of<ProfileCubit>(context);
          final palette = context.appPalette;
          final hasMethods = cubit.paymentMethods.isNotEmpty;
          final selectedMethod = hasMethods
              ? cubit.paymentMethods[cubit.selectedPaymentIndex]
              : const ProfileOption(
                  name: 'No payment methods yet',
                  subtitle: 'Tap Add Method to create one',
                  icon: Icons.credit_card,
                  fields: [ProfileField('Masked Number', Icons.credit_card)],
                );

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Payment Methods',
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
            body: SafeArea(
              child: SingleChildScrollView(
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
                        title: 'Payment Method Selection',
                        subtitle:
                            'Choose method, then edit only its own fields.',
                      ),
                      const SizedBox(height: 16),
                      const FormSectionLabel(label: 'SELECT PAYMENT METHOD'),
                      const SizedBox(height: 10),
                      if (cubit.isEditing)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: cubit.addPaymentMethod,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Method'),
                          ),
                        ),
                      SizedBox(
                        height: 44,
                        child: hasMethods
                            ? ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: cubit.paymentMethods.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final method = cubit.paymentMethods[index];
                                  final selected = index == cubit.selectedPaymentIndex;
                                  return ChoiceChip(
                                    label: Text(method.name),
                                    selected: selected,
                                    showCheckmark: false,
                                    avatar: Icon(
                                      method.icon,
                                      size: 18,
                                      color: selected ? palette.primary : palette.textSecondary,
                                    ),
                                    onSelected: (_) => cubit.selectPaymentMethod(index),
                                    selectedColor: palette.surfaceMuted,
                                    side: BorderSide(
                                      color: selected ? palette.primary : palette.border,
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  'No methods from server',
                                  style: TextStyle(color: palette.textSecondary),
                                ),
                              ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: palette.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: palette.border),
                        ),
                        child: Text(
                          '${selectedMethod.name} • ${selectedMethod.subtitle}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const FormSectionLabel(label: 'METHOD FIELDS'),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Column(
                          key: ValueKey(selectedMethod.name),
                          children: List.generate(
                            selectedMethod.fields.length,
                            (index) {
                              final field = selectedMethod.fields[index];
                              return AppTextField(
                                label: field.label,
                                hint: field.label,
                                prefixIcon: field.icon,
                                keyboardType: field.keyboardType,
                                controller: cubit.paymentControllers[index],
                                enabled: cubit.isEditing,
                              );
                            },
                          ),
                        ),
                      ),
                      if (cubit.isEditing && hasMethods) ...[
                        const SizedBox(height: 16),
                        AppButton(
                          cubit: cubit,
                          label: 'Save Changes',
                          onPressed: () {
                            cubit.savePaymentMethod();
                            AppModalAlert.show(
                              context,
                              title: 'Saved',
                              message: '${selectedMethod.name} saved successfully',
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
