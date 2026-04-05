import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpss_ecommerce_gold_wallet/constant/app_colors.dart';
import 'package:tpss_ecommerce_gold_wallet/features/convert/presentation/cubit/convert_cubit.dart';
import 'package:tpss_ecommerce_gold_wallet/views/convert/widgets/convert_widget.dart';

class ConvertPage extends StatelessWidget {
  const ConvertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ConvertCubit();
        cubit.loadConvertData();
        return cubit;
      },
      child: BlocBuilder<ConvertCubit, ConvertState>(
        builder: (context, state) {
          if (state is ConvertInitial || state is ConvertLoading) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                centerTitle: true,
                title: Text(
                  'Convert',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                ),
              ),
              body: const Center(
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: AppColors.darkGold,
                ),
              ),
            );
          } else if (state is ConvertDataChanged) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                centerTitle: true,
                title: Text(
                  'Convert',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                ),
              ),
              body: ConvertWidget(
                convertCubit: BlocProvider.of<ConvertCubit>(context),
              ),
            );
          } else if (state is ConvertError) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                centerTitle: true,
                title: Text(
                  'Convert',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                ),
              ),
              body: Center(child: Text(state.message)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
