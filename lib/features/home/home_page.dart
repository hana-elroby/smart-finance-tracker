import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String userName = "User"; // Default value, will be fetched from Firebase
  final ScrollController _categoriesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _categoriesScrollController.dispose();
    super.dispose();
  }

  // TODO: Fetch user data from Firebase
  Future<void> _loadUserData() async {
    // TODO: Replace with Firebase Auth
    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null) {
    //   final userDoc = await FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(user.uid)
    //       .get();
    //   setState(() {
    //     userName = userDoc.data()?['name'] ?? 'User';
    //   });
    // }

    // For now, using dummy data
    setState(() {
      userName =
          "Bassant"; // This will be replaced with actual user name from Firebase
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildProgressBar(),
                const SizedBox(height: 24),
                _buildCategoriesSection(),
                const SizedBox(height: 12),
                _buildRecentTransactionsSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ========== Header ==========
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hi $userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('👋', style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Welcome Back',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        // Notification Icon with Gradient
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.notificationGradient,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.notifications, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  // ========== Progress Bar ==========
  Widget _buildProgressBar() {
    const double progress = 0.3; // 30%

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, size: 16, color: AppColors.success),
            const SizedBox(width: 8),
            const Text(
              '30% Of Your Expenses, Looks Good.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  // ========== Categories Section ==========
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: SingleChildScrollView(
            controller: _categoriesScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // First Column (3 categories)
                Column(
                  children: [
                    _buildCategoryCard(
                      'Shopping',
                      Icons.shopping_bag,
                      '650 EGP',
                      AppColors.shoppingGradient,
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryCard(
                      'Activities',
                      Icons.sports_soccer,
                      '450 EGP',
                      AppColors.activitiesGradient,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Second Column (3 categories)
                Column(
                  children: [
                    _buildCategoryCard(
                      'Bills',
                      Icons.description,
                      '900 EGP',
                      AppColors.billsGradient,
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryCard(
                      'Food & Drink',
                      Icons.restaurant,
                      '397 EGP',
                      AppColors.foodGradient,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Third Column (3 categories)
                Column(
                  children: [
                    _buildCategoryCard(
                      'Health',
                      Icons.favorite,
                      '120 EGP',
                      AppColors.healthGradient,
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryCard(
                      'Education',
                      Icons.school,
                      '200 EGP',
                      AppColors.educationGradient,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Fourth Column (Entertainment - Hidden until scroll)
                Column(
                  children: [
                    _buildCategoryCard(
                      'Entertainment',
                      Icons.movie,
                      '0 EGP',
                      AppColors.entertainmentGradient,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // Auto scroll to show Entertainment
              _categoriesScrollController.animateTo(
                _categoriesScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: const Text(
              'see more',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    String title,
    IconData icon,
    String amount,
    LinearGradient gradient,
  ) {
    return GestureDetector(
      onTap: () => _showCategoryDialog(title, icon, gradient),
      child: Container(
        width: 120,
        height: 130,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    amount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== Recent Transactions Section ==========
  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildTransactionItem(
          'Food & Drink',
          Icons.restaurant,
          '120 EGP',
          const Color(0xFF5AC8FA),
        ),
        _buildTransactionItem(
          'Shopping',
          Icons.shopping_bag,
          '360 EGP',
          const Color(0xFF5AC8FA),
        ),
        _buildTransactionItem(
          'Activities',
          Icons.sports_soccer,
          '220 EGP',
          const Color(0xFFBF5AF2),
        ),
        _buildTransactionItem(
          'Bills',
          Icons.description,
          '198 EGP',
          const Color(0xFFAF52DE),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    String title,
    IconData icon,
    String amount,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ========== Bottom Navigation ==========
  Widget _buildBottomNavigation() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 0),
                  _buildNavItem(Icons.notifications, 1),
                  const SizedBox(width: 60), // Space for QR button
                  _buildNavItem(Icons.access_time, 2),
                  _buildNavItem(Icons.person, 3),
                ],
              ),
            ),
          ),
        ),
        // QR Scanner Button (Floating)
        Positioned(
          top: -30,
          child: GestureDetector(
            onTap: _showQRScannerOptions,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: AppColors.notificationGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : AppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }

  // ========== Category Dialog (Voice/Text Options) ==========
  void _showCategoryDialog(
    String category,
    IconData icon,
    LinearGradient gradient,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category Icon with Gradient
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Add $category Expense',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              // Voice Option
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _showVoiceRecording(category, icon, gradient);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mic, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Voice Input',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Text Option
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _showNumPad(category, icon, gradient);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.keyboard,
                        color: AppColors.textPrimary,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Text Input',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== Voice Recording Dialog ==========
  void _showVoiceRecording(
    String category,
    IconData icon,
    LinearGradient gradient,
  ) {
    bool isRecording = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isRecording ? 'Recording...' : 'Tap to Record',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Microphone Button (Changes color when recording)
                  GestureDetector(
                    onTap: () {
                      setState(() => isRecording = !isRecording);
                      if (!isRecording) {
                        // Simulate recording completion
                        Future.delayed(const Duration(milliseconds: 500), () {
                          Navigator.pop(context);
                          _showSuccessMessage();
                        });
                      }
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: isRecording
                            ? AppColors.notificationGradient
                            : gradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isRecording ? Colors.purple : Colors.blue)
                                .withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isRecording)
                    const Text(
                      '🎤 Listening...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessMessage() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Added Successfully',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your expense has been recorded',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== NumPad Dialog ==========
  void _showNumPad(String category, IconData icon, LinearGradient gradient) {
    String amount = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Amount Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      amount.isEmpty ? '0' : amount,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // NumPad
                  _buildNumPad((value) {
                    setState(() {
                      if (value == 'C') {
                        amount = '';
                      } else if (value == '⌫') {
                        if (amount.isNotEmpty) {
                          amount = amount.substring(0, amount.length - 1);
                        }
                      } else if (value == '✓') {
                        if (amount.isNotEmpty) {
                          Navigator.pop(context);
                          _showSuccessMessage();
                        }
                      } else {
                        amount += value;
                      }
                    });
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumPad(Function(String) onPressed) {
    final buttonColor = AppColors.numPad;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumButton('1', buttonColor, onPressed),
            _buildNumButton('2', buttonColor, onPressed),
            _buildNumButton('3', buttonColor, onPressed),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumButton('4', buttonColor, onPressed),
            _buildNumButton('5', buttonColor, onPressed),
            _buildNumButton('6', buttonColor, onPressed),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumButton('7', buttonColor, onPressed),
            _buildNumButton('8', buttonColor, onPressed),
            _buildNumButton('9', buttonColor, onPressed),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumButton('C', AppColors.error, onPressed),
            _buildNumButton('0', buttonColor, onPressed),
            _buildNumButton('⌫', buttonColor, onPressed),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onPressed('✓'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumButton(String text, Color color, Function(String) onPressed) {
    return GestureDetector(
      onTap: () => onPressed(text),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ========== QR Scanner Options ==========
  void _showQRScannerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Scan Receipt',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            // Camera Option
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.notificationGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
              title: const Text(
                'Take Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Use camera to scan receipt',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open camera
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Camera...')),
                );
              },
            ),
            const SizedBox(height: 12),
            // Gallery Option
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: AppColors.primary,
                ),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Select an existing photo',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open gallery
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Gallery...')),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
