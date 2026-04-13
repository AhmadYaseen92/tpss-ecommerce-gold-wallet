import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/form_header.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/cubit/profile_cubit.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) async {
          if (state is ProfileSaved) {
            await AppModalAlert.show(
              context,
              title: 'Saved',
              message: 'Payment method saved successfully',
            );
          }
          if (state is ProfileError) {
            await AppModalAlert.show(
              context,
              title: 'Validation Error',
              message: state.message,
              variant: AppModalAlertVariant.failed,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          final palette = context.appPalette;
          final hasMethods = cubit.paymentMethods.isNotEmpty;
          final isOnlyUnsavedMethod =
              hasMethods && cubit.paymentMethods.length == 1 && cubit.paymentMethods.first.remoteId == null;
          final selectedMethod = hasMethods
              ? cubit.paymentMethods[cubit.selectedPaymentIndex]
              : const ProfileOption(
                  name: 'No payment methods yet',
                  subtitle: 'Tap Add Method to create one',
                  icon: Icons.credit_card,
                  fields: [ProfileField('Card Number', Icons.credit_card)],
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FormHeader(
                          title: 'Payment Method',
                          subtitle: 'Select a method to view details, edit, or add a new one.',
                        ),
                        const SizedBox(height: 20),
                        const FormSectionLabel(label: 'SELECT PAYMENT METHOD'),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: cubit.addPaymentMethod,
                            icon: const Icon(Icons.add),
                            label: Text(hasMethods ? 'Add Method' : 'Add First Method'),
                          ),
                        ),
                        if (!hasMethods)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'No payment methods yet. Tap Add First Method to create one.',
                              style: TextStyle(color: palette.textSecondary),
                            ),
                          ),
                        if (hasMethods && !isOnlyUnsavedMethod) ...[
                          DropdownButtonFormField<int>(
                            borderRadius: BorderRadius.circular(12),
                            dropdownColor: palette.surface,
                            value: cubit.selectedPaymentIndex,
                            items: List.generate(
                              cubit.paymentMethods.length,
                              (index) => DropdownMenuItem(
                                value: index,
                                child: Text(cubit.paymentMethods[index].name),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                cubit.selectPaymentMethod(value);
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
                        ],
                        if (!hasMethods) ...[
                          const SizedBox(height: 8),
                        ] else ...[
                        const FormSectionLabel(label: 'PAYMENT TYPE'),
                        const SizedBox(height: 8),
                        if (selectedMethod.remoteId == null)
                          DropdownButtonFormField<String>(
                            value: selectedMethod.name,
                            items: cubit.availablePaymentTypes
                                .map(
                                  (type) => DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                            onChanged: cubit.isEditing
                                ? (value) {
                                    if (value != null) {
                                      cubit.updateSelectedPaymentType(value);
                                    }
                                  }
                                : null,
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
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: palette.border),
                              color: palette.surface,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.category_outlined, color: palette.textSecondary),
                                const SizedBox(width: 10),
                                Expanded(child: Text(selectedMethod.name)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        const FormSectionLabel(label: 'METHOD FIELDS'),
                        ...List.generate(selectedMethod.fields.length, (index) {
                          final field = selectedMethod.fields[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AppTextField(
                              label: field.label,
                              hint: field.label,
                              prefixIcon: field.icon,
                              keyboardType: field.keyboardType,
                              controller: cubit.paymentControllers[index],
                              enabled: cubit.isEditing,
                              requiredField: true,
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty) ? 'Required field' : null,
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          value: selectedMethod.isDefault,
                          onChanged: cubit.isEditing ? cubit.toggleSelectedPaymentDefault : null,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Set as default payment method'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedMethod.subtitle,
                          style: TextStyle(color: palette.textSecondary),
                        ),
                        if (cubit.isEditing && hasMethods) ...[
                          const SizedBox(height: 16),
                          AppButton(
                            cubit: cubit,
                            label: 'Save Changes',
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                cubit.savePaymentMethod();
                              }
                            },
                          ),
                        ],
                      ],
                    ),
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
