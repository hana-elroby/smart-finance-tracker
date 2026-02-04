# 📧 إعداد OTP في السيرفر - دليل كامل

## الخطوة 1: إعداد Gmail App Password

### أ. تفعيل 2-Factor Authentication:
1. اذهب لـ https://myaccount.google.com/security
2. اضغط على "2-Step Verification"
3. فعل الـ 2FA باستخدام رقم الموبايل

### ب. إنشاء App Password:
1. في نفس الصفحة، اضغط "App passwords"
2. اختر "Mail" و "Other (custom name)"
3. اكتب "Smart Finance Tracker"
4. احفظ الـ App Password (16 رقم)

## الخطوة 2: تحديث كود السيرفر

### أ. إضافة المكتبات:
```javascript
// في أول ملف السيرفر
const nodemailer = require('nodemailer');

// إعداد Gmail
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER || 'your-email@gmail.com',
    pass: process.env.EMAIL_PASS || 'your-16-digit-app-password'
  }
});
```

### ب. دالة إرسال OTP:
```javascript
// دالة إرسال OTP
async function sendOTPEmail(email, otp, userName) {
  const mailOptions = {
    from: process.env.EMAIL_USER || 'your-email@gmail.com',
    to: email,
    subject: 'Smart Finance Tracker - رمز التحقق',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="text-align: center; margin-bottom: 30px;">
          <h1 style="color: #0D47A1;">Smart Finance Tracker</h1>
          <p style="color: #666;">تطبيق إدارة الأموال الذكي</p>
        </div>
        
        <div style="background: #f8f9fa; padding: 20px; border-radius: 10px; margin: 20px 0;">
          <h2 style="color: #333; text-align: center;">مرحباً ${userName}!</h2>
          <p style="color: #666; text-align: center;">رمز التحقق الخاص بك هو:</p>
          
          <div style="background: #0D47A1; color: white; padding: 15px; text-align: center; border-radius: 8px; margin: 20px 0;">
            <h1 style="margin: 0; font-size: 32px; letter-spacing: 5px;">${otp}</h1>
          </div>
          
          <p style="color: #666; text-align: center; font-size: 14px;">
            هذا الرمز صالح لمدة 10 دقائق فقط
          </p>
        </div>
        
        <div style="text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
          <p style="color: #999; font-size: 12px;">
            إذا لم تطلب هذا الرمز، يرجى تجاهل هذا الإيميل
          </p>
        </div>
      </div>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log('✅ OTP sent successfully to:', email);
    return true;
  } catch (error) {
    console.error('❌ Failed to send OTP:', error);
    return false;
  }
}
```

### ج. تحديث endpoint التسجيل:
```javascript
// في endpoint /auth/signup
app.post('/auth/signup', async (req, res) => {
  const { firstName, lastName, email, password } = req.body;
  
  try {
    // التحقق من وجود المستخدم
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'البريد الإلكتروني مستخدم بالفعل',
        flag: true
      });
    }
    
    // توليد OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // حفظ بيانات المستخدم مؤقتاً
    const tempUser = new TempUser({
      firstName,
      lastName,
      email,
      password: await bcrypt.hash(password, 10),
      otp,
      otpExpires: new Date(Date.now() + 10 * 60 * 1000) // 10 دقائق
    });
    
    await tempUser.save();
    
    // إرسال OTP
    const emailSent = await sendOTPEmail(email, otp, firstName);
    
    if (emailSent) {
      res.json({
        success: true,
        message: 'تم إرسال رمز التحقق إلى بريدك الإلكتروني'
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'فشل في إرسال رمز التحقق'
      });
    }
    
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({
      success: false,
      message: 'خطأ في الخادم'
    });
  }
});
```

## الخطوة 3: إعداد Environment Variables

### في Render.com:
1. اذهب لـ Dashboard > Your Service > Environment
2. أضف:
   - `EMAIL_USER`: your-email@gmail.com
   - `EMAIL_PASS`: your-16-digit-app-password

## الخطوة 4: اختبار النظام

### أ. اختبار محلي:
```bash
# تشغيل السيرفر محلياً
npm start

# اختبار إرسال OTP
curl -X POST http://localhost:3000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Test","lastName":"User","email":"your-email@gmail.com","password":"test123"}'
```

### ب. اختبار على Render:
```bash
curl -X POST https://graduation-project-21p3.onrender.com/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Test","lastName":"User","email":"your-email@gmail.com","password":"test123"}'
```

## 🎯 النتيجة المتوقعة:
- ✅ المستخدم يسجل في التطبيق
- ✅ يصله OTP على الإيميل فوراً
- ✅ يدخل الـ OTP ويتم تفعيل الحساب
- ✅ يدخل التطبيق بنجاح

## 🔧 استكشاف الأخطاء:
- تأكد من صحة Gmail credentials
- تحقق من Environment Variables في Render
- راجع logs السيرفر للأخطاء
- جرب إرسال إيميل تجريبي أولاً