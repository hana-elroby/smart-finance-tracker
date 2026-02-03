import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Voice to Server Service - يرسل الصوت مباشرة للسيرفر
/// يستخدم السيرفر بتاعك: https://gradution-project-u39v.onrender.com/voice
class VoiceToServerService {
  static final VoiceToServerService _instance = VoiceToServerService._internal();
  factory VoiceToServerService() => _instance;
  VoiceToServerService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;

  bool get isRecording => _isRecording;

  /// بدء التسجيل
  Future<bool> startRecording() async {
    try {
      // طلب إذن الميكروفون
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        print('❌ مطلوب إذن الميكروفون');
        return false;
      }

      // التحقق من توفر التسجيل
      if (await _recorder.hasPermission()) {
        // إنشاء مسار مؤقت للملف
        final directory = Directory.systemTemp;
        _recordingPath = '${directory.path}/voice_recording_${DateTime.now().millisecondsSinceEpoch}.wav';

        // بدء التسجيل
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav, // WAV format للسيرفر
            sampleRate: 16000, // 16kHz sample rate
            bitRate: 128000,
          ),
          path: _recordingPath!,
        );

        _isRecording = true;
        print('🎤 بدء التسجيل: $_recordingPath');
        return true;
      } else {
        print('❌ لا يمكن الوصول للميكروفون');
        return false;
      }
    } catch (e) {
      print('❌ خطأ في بدء التسجيل: $e');
      return false;
    }
  }

  /// إيقاف التسجيل وإرسال للسيرفر
  Future<Map<String, dynamic>?> stopRecordingAndSend() async {
    if (!_isRecording || _recordingPath == null) {
      print('❌ لا يوجد تسجيل جاري');
      return null;
    }

    try {
      // إيقاف التسجيل
      await _recorder.stop();
      _isRecording = false;
      print('⏹️ تم إيقاف التسجيل');

      // التحقق من وجود الملف
      final file = File(_recordingPath!);
      if (!await file.exists()) {
        print('❌ ملف التسجيل غير موجود');
        return null;
      }

      print('📁 حجم الملف: ${await file.length()} bytes');

      // إرسال الملف للسيرفر
      return await _sendAudioToServer(file);

    } catch (e) {
      print('❌ خطأ في إيقاف التسجيل: $e');
      return null;
    }
  }

  /// إرسال ملف الصوت للسيرفر
  Future<Map<String, dynamic>?> _sendAudioToServer(File audioFile) async {
    try {
      print('📡 إرسال الصوت للسيرفر...');

      // إنشاء multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://gradution-project-u39v.onrender.com/voice'),
      );

      // إضافة ملف الصوت
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio', // اسم الحقل في السيرفر
          audioFile.path,
          filename: 'voice_recording.wav',
        ),
      );

      // إضافة headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
      });

      print('📤 إرسال الطلب...');

      // إرسال الطلب
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      // قراءة الاستجابة
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 استجابة السيرفر: ${response.statusCode}');
      print('📄 محتوى الاستجابة: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ تم تحليل الصوت بنجاح');
        
        // حذف الملف المؤقت
        await _cleanupTempFile();
        
        return jsonResponse;
      } else {
        print('❌ خطأ من السيرفر: ${response.statusCode}');
        print('❌ رسالة الخطأ: ${response.body}');
        
        // حذف الملف المؤقت
        await _cleanupTempFile();
        
        return null;
      }

    } catch (e) {
      print('❌ خطأ في إرسال الصوت: $e');
      
      // حذف الملف المؤقت
      await _cleanupTempFile();
      
      return null;
    }
  }

  /// حذف الملف المؤقت
  Future<void> _cleanupTempFile() async {
    if (_recordingPath != null) {
      try {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
          print('🗑️ تم حذف الملف المؤقت');
        }
      } catch (e) {
        print('⚠️ لا يمكن حذف الملف المؤقت: $e');
      }
      _recordingPath = null;
    }
  }

  /// إلغاء التسجيل
  Future<void> cancelRecording() async {
    if (_isRecording) {
      try {
        await _recorder.stop();
        _isRecording = false;
        await _cleanupTempFile();
        print('❌ تم إلغاء التسجيل');
      } catch (e) {
        print('❌ خطأ في إلغاء التسجيل: $e');
      }
    }
  }

  /// تنظيف الموارد
  void dispose() {
    if (_isRecording) {
      cancelRecording();
    }
    _recorder.dispose();
  }
}