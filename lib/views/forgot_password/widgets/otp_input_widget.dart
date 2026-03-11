import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';

/// Allows typing over an existing digit by always keeping the last entered char.
class _OtpDigitFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final char = digits[digits.length - 1];
    return TextEditingValue(
      text: char,
      selection: const TextSelection.collapsed(offset: 1),
    );
  }
}

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < length - 1 ? 10 : 0),
          child: SizedBox(
            width: 48,
            height: 56,
            child: Focus(
              onKeyEvent: (node, event) {
                // Backspace on an empty box: move to previous and trim the OTP
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    index >= value.length &&
                    index > 0) {
                  FocusScope.of(context).previousFocus();
                  if (value.isNotEmpty) {
                    onChanged(value.substring(0, value.length - 1));
                  }
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: TextFormField(
                key: ValueKey('otp_$index'),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [_OtpDigitFormatter()],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textColor,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: AppColors.greyBorder, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: AppColors.greyBorder, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    // Replace digit at this position or append sequentially
                    final String newOtp;
                    if (index < value.length) {
                      newOtp = value.substring(0, index) +
                          val +
                          value.substring(index + 1);
                    } else {
                      newOtp = value + val;
                    }
                    onChanged(newOtp);
                    if (index < length - 1) {
                      FocusScope.of(context).nextFocus();
                    }
                    if (newOtp.length == length) {
                      onCompleted(newOtp);
                    }
                  } else {
                    // Digit cleared: truncate OTP from this position onwards
                    if (index < value.length) {
                      onChanged(value.substring(0, index));
                    }
                  }
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
