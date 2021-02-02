import 'package:bloc/bloc.dart';

import './counter_cubit.dart';
import './simple_bloc_observer.dart';

void exampleOfBasicUsage() {
  var cubit = CounterCubit();
  cubit..increment()..increment();
  print(cubit.state); // 2
}

void exampleOfCubitStream() async {
  final cubit = CounterCubit();
  final subscription = cubit.listen((state) {
    print('state changed: ${state}');
  });

  cubit.increment();
  await Future.delayed(Duration.zero);
  await subscription.cancel();
  await cubit.close();
}

void exampleOfErrorHandling() {
  CounterCubit()
    ..decrement()
    ..close();
}

void main() {
  // Bloc.observer = SimpleBlocObserver();
  // exampleOfCubitStream();
  exampleOfErrorHandling();
}
