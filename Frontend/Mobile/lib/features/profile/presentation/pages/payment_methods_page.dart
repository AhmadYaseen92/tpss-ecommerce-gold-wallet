import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';
import 'package:tpss_ecommerce_gold_wallet/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_button.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_text_field.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/form_header.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  String _selectedFilter = 'All';

  static const _filters = ['All', 'Cards', 'Wallets', 'Bank'];

  List<_PaymentFlowGuide> get _allGuides => const [
    _PaymentFlowGuide(
      name: 'Visa / MasterCard',
      group: 'Cards',
      icon: Icons.credit_card_outlined,
      overview: 'PCI-compliant card flow with 3DS and OTP challenge.',
      steps: [
        'Forward request to gateway',
        '3DS user authentication via OTP',
        'Receive authorization result',
        'Update internal payment status',
        'Return immediate success/failure',
      ],
      tags: ['Real-time authorization', 'SCA', 'Instant result'],
    ),
    _PaymentFlowGuide(
      name: 'Apple Pay',
      group: 'Cards',
      icon: Icons.phone_iphone,
      overview: 'Tokenized card payment with Face ID / Touch ID / passcode.',
      steps: [
        'Validate device and Apple Pay availability',
        'Display Apple Pay confirmation sheet',
        'User authorizes with biometric/passcode',
        'Secure token sent to gateway',
        'Gateway confirms transaction and order completes',
      ],
      tags: ['Tokenized', 'Biometric auth', 'No card data sharing'],
    ),
    _PaymentFlowGuide(
      name: 'ZainCash',
      group: 'Wallets',
      icon: Icons.account_balance_wallet_outlined,
      overview: 'Wallet OTP authorization and provider callback confirmation.',
      steps: [
        'Send payment request to ZainCash',
        'User confirms using OTP',
        'Provider callback confirms payment',
        'Status updates and result returned',
      ],
    ),
    _PaymentFlowGuide(
      name: 'Orange Money',
      group: 'Wallets',
      icon: Icons.account_balance_wallet_outlined,
      overview: 'OTP-based wallet approval with backend callback update.',
      steps: [
        'Initiate request with Orange Money',
        'User confirms via OTP',
        'Callback received from provider',
        'System finalizes and notifies user',
      ],
    ),
    _PaymentFlowGuide(
      name: 'Dinarak',
      group: 'Wallets',
      icon: Icons.account_balance_wallet_outlined,
      overview: 'Wallet app confirmation then callback reconciliation.',
      steps: [
        'Initiate request with Dinarak',
        'User confirms in Dinarak wallet',
        'Callback updates transaction state',
        'User receives final status',
      ],
    ),
    _PaymentFlowGuide(
      name: 'CliQ',
      group: 'Bank',
      icon: Icons.account_balance_outlined,
      overview: 'Instant account-to-account bank transfer with app confirmation.',
      steps: [
        'Initiate CliQ request via bank integration',
        'User receives request in bank app',
        'User confirms in bank app',
        'Bank sends instant confirmation',
        'System updates status and returns result',
      ],
      tags: ['Near real-time settlement', 'High trust', 'Bank-controlled auth'],
    ),
  ];

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
          final guides = _selectedFilter == 'All'
              ? _allGuides
              : _allGuides.where((guide) => guide.group == _selectedFilter).toList();

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
                        subtitle: 'Choose by type, review flow, then save your preferred method.',
                      ),
                      const SizedBox(height: 16),
                      const FormSectionLabel(label: 'FILTER BY METHOD TYPE'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _filters
                            .map(
                              (filter) => ChoiceChip(
                                label: Text(filter),
                                selected: _selectedFilter == filter,
                                onSelected: (_) => setState(() => _selectedFilter = filter),
                                selectedColor: palette.surfaceMuted,
                                side: BorderSide(
                                  color: _selectedFilter == filter ? palette.primary : palette.border,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      const FormSectionLabel(label: 'AVAILABLE INTEGRATION FLOWS'),
                      const SizedBox(height: 8),
                      ...guides.map(
                        (guide) => Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: palette.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: palette.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(guide.icon, color: palette.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      guide.name,
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Text(
                                    guide.group,
                                    style: TextStyle(color: palette.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(guide.overview),
                              const SizedBox(height: 8),
                              ...guide.steps.asMap().entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text('${entry.key + 1}. ${entry.value}'),
                                ),
                              ),
                              if (guide.tags.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: guide.tags
                                      .map(
                                        (tag) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(999),
                                            border: Border.all(color: palette.border),
                                          ),
                                          child: Text(tag, style: const TextStyle(fontSize: 12)),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const FormSectionLabel(label: 'SAVED USER METHODS (VIEW / ADD / UPDATE)'),
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

class _PaymentFlowGuide {
  const _PaymentFlowGuide({
    required this.name,
    required this.group,
    required this.icon,
    required this.overview,
    required this.steps,
    this.tags = const [],
  });

  final String name;
  final String group;
  final IconData icon;
  final String overview;
  final List<String> steps;
  final List<String> tags;
}
