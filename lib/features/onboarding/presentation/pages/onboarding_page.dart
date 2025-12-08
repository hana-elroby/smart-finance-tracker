import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/navigation_helper.dart';
import '../../../auth/presentation/pages/auth_page.dart';
import '../../data/onboarding_data.dart';
import '../widgets/onboarding_page_item.dart';
import '../widgets/page_indicator.dart';
import '../widgets/onboarding_button.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // هنا بنلف الـ Page بـ BlocProvider عشان نوفر الـ Bloc لكل الـ widgets
    // Wrap the page with BlocProvider to provide the Bloc to all widgets
    return BlocProvider(
      create: (context) => OnboardingBloc(),
      child: const _OnboardingPageContent(),
    );
  }
}

class _OnboardingPageContent extends StatefulWidget {
  const _OnboardingPageContent();

  @override
  State<_OnboardingPageContent> createState() => _OnboardingPageContentState();
}

class _OnboardingPageContentState extends State<_OnboardingPageContent>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = OnboardingData.getPages();

    // هنا بنستخدم BlocConsumer عشان نسمع للـ State ونعمل actions
    // Using BlocConsumer to listen to state and perform actions
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      // listener بيتنفذ لما الـ state يتغير (للـ side effects زي Navigation)
      // listener executes when state changes (for side effects like navigation)
      listener: (context, state) {
        // لو المستخدم خلص الـ Onboarding، ننقله للـ Auth
        // If user completed onboarding, navigate to Auth
        if (state.shouldNavigateToAuth) {
          NavigationHelper.pushReplacement(context, const AuthPage());
        }

        // لو الصفحة اتغيرت من الـ Bloc، نحرك الـ PageController
        // If page changed from Bloc, animate the PageController
        if (state.currentPage != _pageController.page?.round()) {
          _pageController.animateToPage(
            state.currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      // builder بيبني الـ UI بناءً على الـ State الحالي
      // builder builds the UI based on current state
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      // لما المستخدم يعمل swipe، نبلّغ الـ Bloc
                      // When user swipes, notify the Bloc
                      onPageChanged: (page) {
                        context.read<OnboardingBloc>().add(PageChanged(page));
                      },
                      physics: const BouncingScrollPhysics(),
                      children: pages
                          .map((model) => OnboardingPageItem(model: model))
                          .toList(),
                    ),
                  ),
                  PageIndicator(
                    pageCount: pages.length,
                    currentPage: state.currentPage,
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OnboardingButton(
                      // لما المستخدم يضغط Next/Get Started
                      // When user clicks Next/Get Started
                      onPressed: () {
                        context.read<OnboardingBloc>().add(
                          const NextPageRequested(),
                        );
                      },
                      text: state.isLastPage ? 'Get Started' : 'Next',
                      pulseAnimation: _pulseAnimation,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
              _buildNavigationButtons(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationButtons(BuildContext context, OnboardingState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button - بس لو مش في أول صفحة
            // Back button - only if not on first page
            if (!state.isFirstPage)
              IconButton(
                onPressed: () {
                  context.read<OnboardingBloc>().add(
                    const PreviousPageRequested(),
                  );
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                  size: 28,
                ),
              )
            else
              const SizedBox(width: 48),
            // Skip button
            TextButton(
              onPressed: () {
                context.read<OnboardingBloc>().add(const SkipRequested());
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
