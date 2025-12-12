import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../service/api_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../model/user_model.dart';
import './home_screen.dart';
import './profile_screen.dart';
import './weight_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final GlobalKey _profileIconKey = GlobalKey();

  UserProfile? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();

    Future.delayed(const Duration(seconds: 1), () {
      _showTutorial();
    });
  }

  void _fetchUserProfile() async {
    try {
      final data = await ApiService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = data;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  void _showTutorial() async {
    bool shouldShow = await ApiService.shouldShowDashboardTutorial();
    if (shouldShow && mounted) {
      TutorialCoachMark(
        targets: _createTargets(),
        colorShadow: Colors.black,
        textSkip: "LEWATI",
        paddingFocus: 10,
        opacityShadow: 0.8,
        onFinish: () => ApiService.completeDashboardTutorial(),
        onSkip: () {
          ApiService.completeDashboardTutorial();
          return true;
        },
      ).show(context: context);
    }
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "profile_key",
        keyTarget: _profileIconKey,
        alignSkip: Alignment.topLeft,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Atur Profil & Target",
                  style: GoogleFonts.signika(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Masuk ke menu ini untuk mengatur berat badan dan target kalori harianmu.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.signika(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.nutrinTrackGreen),
        ),
      );
    }

    final List<Widget> screens = [
      HomeScreen(
        userProfile: _userProfile,
        onRefreshProfile: _fetchUserProfile,
      ),
      const WeightScreen(),
      ProfileScreen(
        userProfile: _userProfile,
        onProfileUpdated: _fetchUserProfile,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        profileKey: _profileIconKey, // Key untuk tutorial
      ),
    );
  }
}
