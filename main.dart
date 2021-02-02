import 'package:bloc/bloc.dart';

import './counter_cubit.dart';
import './simple_bloc_observer.dart';

void exampleOfBasicUsage() {
  var cubit = CounterCubit();
  cubit..increment()..increment();
  print(cubit.state); // 2
}

void main() {
  Bloc.observer = SimpleBlocObserver();
  exampleOfBasicUsage();
}
