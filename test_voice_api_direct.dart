import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/features/home/bloc/expense_bloc.dart';
import 'lib/widgets/dialogs/voice_input_dialog_api_direct.dart';
import 'lib/services/voice_api_direct_service.dart';

/// Test Voice API Direct - يستخدم API المستخدم مباشرة
/// يدعم العربي والإنجليزي مع إدخال نصي كبديل
void main() {
  runApp(const VoiceApiDirectTestApp());
}

class VoiceApiDirectTestApp extends StatelessWidget {
  const VoiceApiDirectTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice API Direct Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => ExpenseBloc(),
        child: const VoiceApiDirectTestPage(),
      ),
    );
  }
}

class VoiceApiDirectTestPage extends StatefulWidget {
  const VoiceApiDirectTestPage({super.key});

  @override
  State<VoiceApiDirectTestPage> createState() => _VoiceApiDirectTestPageState();
}

class _VoiceApiDirectTestPageState extends State<VoiceApiDirectTestPage> {
  bool _isConnected = false;
  bool _isTestingConnection = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() => _isTestingConnection = true);
    
    final connected = await VoiceApiDirectService.testConnection();
    
    setState(() {
      _isConnected = connected;
      _isTestingConnection = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice API Direct Test'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: _testConnection,
            icon: _isTestingConnection 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Connection Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isConnected ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isConnected ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isConnected ? Icons.check_circle : Icons.error,
                    color: _isConnected ? Colors.green : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isConnected ? 'متصل بالسيرفر ✅' : 'غير متصل بالسيرفر ❌',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isConnected ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'gradution-project-u39v.onrender.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Main Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 2),
              ),
              child: const Icon(
                Icons.mic_rounded,
                size: 60,
                color: Colors.blue,
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'اختبار الصوت + النص → API',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'يستخدم سيرفرك مباشرة\nيدعم العربي والإنجليزي والفرانكو-عربي\nمع إدخال نصي كبديل للصوت',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isConnected ? () => _testVoiceApiDirect(context) : null,
                icon: const Icon(Icons.mic, size: 28),
                label: const Text(
                  'فتح Voice + Text Dialog',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConnected ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Features
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المميزات الجديدة:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '🎤 تسجيل صوتي (عربي وإنجليزي)\n'
                    '⌨️ إدخال نصي مباشر كبديل\n'
                    '📡 يستخدم سيرفرك مباشرة (لا توجد معالجة لغوية)\n'
                    '🔢 يدعم الكمية (Quantity) بشكل صحيح\n'
                    '📊 يظهر في الـ Chart بالكمية الفعلية\n'
                    '✅ يعمل حتى لو الصوت لا يعمل في الإيميوليتر',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Examples
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أمثلة للاختبار:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'بالعربي:\n'
                    '• "اشتريت خبز بخمسة جنيه"\n'
                    '• "دفعت عشرين جنيه مواصلات"\n'
                    '• "جبت قهوتين بستين جنيه"\n\n'
                    'بالإنجليزي:\n'
                    '• "I bought bread for 5 EGP"\n'
                    '• "I paid 20 EGP for transport"\n'
                    '• "I bought 2 coffees for 60 EGP"\n\n'
                    'فرانكو-عربي:\n'
                    '• "gbt 3eesh b 5 gneeh"',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            
            if (!_isConnected) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Text(
                      'تحقق من الاتصال:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• تأكد من الاتصال بالإنترنت\n'
                      '• تأكد أن السيرفر يعمل\n'
                      '• اضغط على زر التحديث أعلاه',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _testVoiceApiDirect(BuildContext context) async {
    final result = await showVoiceInputDialogApiDirect(context);
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم معالجة النص: $result'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}