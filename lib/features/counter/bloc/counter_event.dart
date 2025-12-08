// ده الملف اللي فيه كل الأحداث (Events) اللي ممكن تحصل
// يعني لما المستخدم يضغط زرار، بنبعت Event

part of 'counter_bloc.dart';

// الـ Base Class لكل الـ Events
abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object> get props => [];
}

// Event لما المستخدم يضغط زرار الزيادة (+)
class IncrementCounter extends CounterEvent {}

// Event لما المستخدم يضغط زرار النقصان (-)
class DecrementCounter extends CounterEvent {}

// Event لو عايزين نعمل Reset للعداد
class ResetCounter extends CounterEvent {}
