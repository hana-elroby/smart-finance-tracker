// ده الملف اللي فيه حالة التطبيق (State)
// يعني البيانات اللي هتتعرض على الشاشة

part of 'counter_bloc.dart';

// الـ State بتاعنا - فيها قيمة العداد
class CounterState extends Equatable {
  final int counterValue;

  const CounterState({this.counterValue = 0});

  // دي Function بتساعدنا نعمل نسخة جديدة من الـ State مع تغيير قيمة معينة
  CounterState copyWith({int? counterValue}) {
    return CounterState(
      counterValue: counterValue ?? this.counterValue,
    );
  }

  @override
  List<Object> get props => [counterValue];
}
