import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/core/constants/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/presentation/cubit/transfer_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/core/common_widgets/app_modal_alert.dart';
import 'package:tpss_ecommerce_gold_wallet/features/transfer/presentation/widgets/transfer_widget.dart';

class TransferGiftPage extends StatelessWidget {
  const TransferGiftPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = TransferCubit();
        cubit.load();
        return cubit;
      },
      child: BlocConsumer<TransferCubit, TransferState>(
        listener: (context, state) {
          if (state is TransferSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.lightGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.green,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gift Sent!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your gold has been successfully transferred to the recipient.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyShade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); 
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: AppColors.luxuryIvory,
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is TransferError) {
            AppModalAlert.show(
              context,
              title: 'Transfer Error',
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          final cubit = BlocProvider.of<TransferCubit>(context);

          final appBar = AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            centerTitle: true,
            title: Text(
              'Transfer / Gift',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
            ),
          );

          if (state is TransferInitial || state is TransferLoading) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: appBar,
              body: const Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: AppColors.darkGold,
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: appBar,
            body: TransferWidget(cubit: cubit),
          );
        },
      ),
    );
  }
}
