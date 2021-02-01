import './counter_cubit.dart';

void exampleOfBasicUsage() {
  var cubit = CounterCubit();
  cubit..increment()..increment();
  print(cubit.state); // 2
}

void main() {
  exampleOfBasicUsage();
}
