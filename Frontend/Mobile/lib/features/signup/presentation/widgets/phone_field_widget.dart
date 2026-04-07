import 'package:flutter/material.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';

class PhoneField extends StatelessWidget {
  final String selectedCode;
  final ValueChanged<String> onCodeChanged;
  final ValueChanged<String> onPhoneChanged;
  final String initialPhone;
  final String? Function(String?)? validator;

  const PhoneField({
    super.key,
    required this.selectedCode,
    required this.onCodeChanged,
    required this.onPhoneChanged,
    this.initialPhone = '',
    this.validator,
  });

  static const List<Map<String, String>> countryCodes = [
    {'code': '+962', 'flag': '🇯🇴', 'country': 'Jordan'},
    {'code': '+971', 'flag': '🇦🇪', 'country': 'UAE'},
    {'code': '+970', 'flag': '🇵🇸', 'country': 'Palestine'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyBorder, width: 1),
          ),
          child: DropdownButton<String>(
            borderRadius: BorderRadius.circular(12),
            dropdownColor: AppColors.white,
            underline: const SizedBox(),
            value: selectedCode,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.greyShade500,
              size: 18,
            ),
            items: countryCodes.map((e) {
              return DropdownMenuItem<String>(
                value: e['code'],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${e['flag']} ${e['code']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onCodeChanged(value);
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            initialValue: initialPhone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onChanged: onPhoneChanged,
            validator: validator,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              hintStyle: TextStyle(
                color: AppColors.greyShade400,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.greyBorder, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.greyBorder, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.red, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}