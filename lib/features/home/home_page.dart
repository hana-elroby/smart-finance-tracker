import 'package:flutter/material.dart';
import 'package:graduation_project/recorses/colors_manager.dart';
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
<<<<<<< HEAD
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
=======
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi Bassant! 👋',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 16,
                            color: ColorsManager.black ,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Expense Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          '30% Of Your Expenses, Looks Good.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Categories Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.black1A,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Categories Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                  children: [
                    _buildCategoryCard(
                      'Shopping',
                      '650 EGP',
                      Icons.shopping_bag_outlined,
                      const Color(0xFF214E79),
                      const Color(0xFF4FC3C9),
                    ),
                    _buildCategoryCard(
                      'Bills',
                      '900 EGP',
                      Icons.receipt,
                      const Color(0xFF5C2E5E),
                      const Color(0xFFE85D75),
                    ),
                    _buildCategoryCard(
                      'Health',
                      '120 EGP',
                      Icons.favorite_border,
                      const Color(0xFF2D7A5F),
                      const Color(0xFF7FD8B3),
                    ),
                    _buildCategoryCard(
                      'Activities',
                      '450 EGP',
                      Icons.fitness_center,
                      const Color(0xFF5E3A7D),
                      const Color(0xFFA97BC8),
                    ),
                    _buildCategoryCard(
                      'Food & Drink',
                      '397 EGP',
                      Icons.restaurant_menu,
                      const Color(0xFF2B5A8E),
                      const Color(0xFF5B9BD5),
                    ),
                    _buildCategoryCard(
                      'Education',
                      '200 EGP',
                      Icons.school_outlined,
                      const Color(0xFF1B7A7A),
                      const Color(0xFF4DB8B8),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Recent Transactions Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('see more'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Recent Transactions List
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTransactionItem(
                        'Food',
                        '120 EGP',
                        Icons.restaurant,
                        const Color(0xFF3498DB),
                      ),
                      _buildDivider(),
                      _buildTransactionItem(
                        'Shopping',
                        '360 EGP',
                        Icons.shopping_bag,
                        const Color(0xFF4A90E2),
                      ),
                      _buildDivider(),
                      _buildTransactionItem(
                        'Activities',
                        '220 EGP',
                        Icons.sports_basketball,
                        const Color(0xFF9B59B6),
                      ),
                      _buildDivider(),
                      _buildTransactionItem(
                        'Bills',
                        '198 EGP',
                        Icons.receipt_long,
                        const Color(0xFFE74C3C),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
>>>>>>> 034de4082a4e540adf70c7929b631c790a8bc69b
              ],
            ),
          ),
        ),
      ),
<<<<<<< HEAD
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
=======
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add expense
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Expense - قريباً')),
          );
        },
        backgroundColor: Colors.white,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.7),
              ],
            ),
          ),
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.notifications, 'Alerts', 1),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(Icons.pie_chart, 'Stats', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
>>>>>>> 034de4082a4e540adf70c7929b631c790a8bc69b
            ],
          ),
        ),
      ),
    );
  }

<<<<<<< HEAD
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
=======
  Widget _buildCategoryCard(
      String title,
      String amount,
      IconData icon,
      Color darkColor,
      Color lightColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [darkColor, lightColor],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
>>>>>>> 034de4082a4e540adf70c7929b631c790a8bc69b
              ),
            ),
          ),
          Text(
            amount,
<<<<<<< HEAD
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
=======
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.grey[200], height: 1),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.primary : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
>>>>>>> 034de4082a4e540adf70c7929b631c790a8bc69b
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
