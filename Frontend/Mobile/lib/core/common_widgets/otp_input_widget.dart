import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

class OtpInputWidget extends StatelessWidget {

  final int length;
  final String value;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String> onChanged;

  const OtpInputWidget({
    super.key,
    this.length = 6,
    this.value = '',
    required this.onCompleted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: palette.border,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: palette.primary,
        width: 1.5,
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        length: length,
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length),
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        defaultPinTheme: defaultPinTheme,
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: defaultPinTheme,
        separatorBuilder: (index) => const SizedBox(width: 10),
        mainAxisAlignment: MainAxisAlignment.center,
        pinputAutovalidateMode: PinputAutovalidateMode.disabled,
        showCursor: true,
        onChanged: onChanged,
        onCompleted: onCompleted,
        closeKeyboardWhenCompleted: true,
      ),
    );
  }
}