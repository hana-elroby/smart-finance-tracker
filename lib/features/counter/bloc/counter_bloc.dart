// ده الملف الرئيسي للـ BLoC
// هنا بنكتب المنطق (Business Logic) اللي بيحصل لما Event يحصل

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'counter_event.dart';
part 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  // الـ Constructor - بنبدأ بقيمة 0
  CounterBloc() : super(const CounterState(counterValue: 0)) {
    // لما يحصل IncrementCounter Event، نزود الرقم
    on<IncrementCounter>((event, emit) {
      emit(state.copyWith(counterValue: state.counterValue + 1));
    });

    // لما يحصل DecrementCounter Event، ننقص الرقم
    on<DecrementCounter>((event, emit) {
      emit(state.copyWith(counterValue: state.counterValue - 1));
    });

    // لما يحصل ResetCounter Event، نرجع الرقم لـ 0
    on<ResetCounter>((event, emit) {
      emit(const CounterState(counterValue: 0));
    });
  }
}
