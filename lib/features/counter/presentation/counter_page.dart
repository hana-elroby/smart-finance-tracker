// ده الملف اللي فيه الشاشة (UI) بتاعة العداد
// هنا بنستخدم الـ BLoC عشان نعرض البيانات ونتفاعل مع المستخدم

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/counter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // هنا بنسجل الـ BLoC عشان الشاشة دي تقدر تستخدمه
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مثال BLoC - العداد'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'اضغط الأزرار لتغيير الرقم:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            
            // BlocBuilder بيسمع على أي تغيير في الـ State ويحدث الـ UI فورًا
            BlocBuilder<CounterBloc, CounterState>(
              builder: (context, state) {
                return Text(
                  '${state.counterValue}',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // الأزرار اللي بتبعت Events للـ BLoC
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // زرار النقصان
                FloatingActionButton(
                  heroTag: 'decrement',
                  onPressed: () {
                    // بنبعت Event للـ BLoC
                    context.read<CounterBloc>().add(DecrementCounter());
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.remove),
                ),
                
                const SizedBox(width: 20),
                
                // زرار Reset
                FloatingActionButton(
                  heroTag: 'reset',
                  onPressed: () {
                    context.read<CounterBloc>().add(ResetCounter());
                  },
                  backgroundColor: Colors.grey,
                  child: const Icon(Icons.refresh),
                ),
                
                const SizedBox(width: 20),
                
                // زرار الزيادة
                FloatingActionButton(
                  heroTag: 'increment',
                  onPressed: () {
                    context.read<CounterBloc>().add(IncrementCounter());
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // شرح بسيط
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '💡 كل ما تضغط زرار، بيتبعت Event للـ BLoC\n'
                'الـ BLoC بيغير الـ State\n'
                'والـ UI بيتحدث فورًا بدون ما نعيد تحميل الشاشة!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
