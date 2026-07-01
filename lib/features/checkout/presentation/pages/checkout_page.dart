import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/payment_cubit.dart';
import '../screens/checkout_screen.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key, required this.cart});

  final CartEntity cart;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CheckoutCubit>()),
        // Screen-level PaymentCubit drives the initiate call + loading overlay.
        // (The Moment sheet still creates its own instance when shown later.)
        BlocProvider(create: (_) => getIt<PaymentCubit>()),
      ],
      child: CheckoutScreen(cart: cart),
    );
  }
}
