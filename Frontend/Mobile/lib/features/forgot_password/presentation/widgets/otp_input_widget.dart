import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_theme.dart';

class OtpInputWidget extends StatefulWidget {
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
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();

    controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );

    focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );

    _syncWithValue(widget.value);
  }

  @override
  void didUpdateWidget(covariant OtpInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _syncWithValue(widget.value);
    }
  }

  void _syncWithValue(String value) {
    for (int i = 0; i < widget.length; i++) {
      controllers[i].text = i < value.length ? value[i] : '';
    }
  }

  @override
  void dispose() {
    for (var c in controllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(int index, String val) {
    // Handle paste (multiple digits)
    if (val.length > 1) {
      final digits = val.replaceAll(RegExp(r'\D'), '');
      if (digits.length == widget.length) {
        widget.onChanged(digits);
        widget.onCompleted(digits);
        return;
      }
    }

    if (val.isNotEmpty) {
      final newOtp = _buildOtp(index, val);
      widget.onChanged(newOtp);

      if (index < widget.length - 1) {
        focusNodes[index + 1].requestFocus();
      }

      if (newOtp.length == widget.length) {
        widget.onCompleted(newOtp);
      }
    } else {
      final newOtp = widget.value.substring(0, index);
      widget.onChanged(newOtp);
    }
  }

  String _buildOtp(int index, String val) {
    final current = widget.value.padRight(widget.length);

    return current.substring(0, index) +
        val +
        current.substring(index + 1).trim();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < widget.length - 1 ? 10 : 0),
          child: SizedBox(
            width: 48,
            height: 56,
            child: TextFormField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: palette.surface,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: palette.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: palette.primary,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (val) => _onChanged(index, val),
              onTap: () {
                controllers[index].selection = TextSelection.fromPosition(
                  TextPosition(offset: controllers[index].text.length),
                );
              },
              onFieldSubmitted: (_) {
                if (index < widget.length - 1) {
                  focusNodes[index + 1].requestFocus();
                }
              },
              onEditingComplete: () {},
              onSaved: (_) {},
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
            ),
          ),
        );
      }),
    );
  }
}