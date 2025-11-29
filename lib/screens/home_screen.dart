import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../model/tracking_data.dart';
import '../service/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<DailyLog?> _todayLogFuture;

  @override
  void initState() {
    super.initState();
    _todayLogFuture = _fetchTodayLog();
  }

  void _refreshData() {
    setState(() {
      _todayLogFuture = _fetchTodayLog();
    });
  }

  Future<DailyLog?> _fetchTodayLog() async {
    try {
      final List<dynamic> rawData = await ApiService.getHistory();
      final List<DailyLog> allLogs = rawData
          .map((json) => DailyLog.fromJson(json as Map<String, dynamic>))
          .toList();

      final now = DateTime.now();
      for (final log in allLogs) {
        if (log.date.day == now.day &&
            log.date.month == now.month &&
            log.date.year == now.year) {
          return log;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<DailyLog?>(
          future: _todayLogFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.nutrinTrackGreen,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Gagal memuat data',
                      style: GoogleFonts.signika(color: Colors.red),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _refreshData,
                    ),
                  ],
                ),
              );
            }

            final dailyLog = snapshot.data;
            final summary = dailyLog?.summary;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kirim fungsi refresh ke Header
                  _Header(onRefresh: _refreshData),
                  const SizedBox(height: 30),
                  _buildCalorieSummaryCard(summary),
                  const SizedBox(height: 40),
                  _buildTodayFoodLog(dailyLog),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalorieSummaryCard(DailySummary? summary) {
    final double caloriesEaten = summary?.totalCaloriesKcal ?? 0.0;
    final double protein = summary?.totalProteinG ?? 0.0;
    final double fat = summary?.totalFatG ?? 0.0;
    final double carbs = summary?.totalCarbsG ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppTheme.nutrinTrackGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 12.0,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.buttonGreen,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        caloriesEaten.toStringAsFixed(0),
                        style: GoogleFonts.signika(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      Text(
                        'kkal',
                        style: GoogleFonts.signika(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem("Protein", protein),
              _buildMacroItem("Lemak", fat),
              _buildMacroItem("Karbo", carbs),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String title, double value) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.signika(
            fontSize: 15,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(0)}g',
          style: GoogleFonts.signika(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayFoodLog(DailyLog? dailyLog) {
    final sarapanItems = dailyLog?.sarapan ?? [];
    final siangItems = dailyLog?.makanSiang ?? [];
    final malamItems = dailyLog?.makanMalam ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Log Makanan Hari Ini',
          style: GoogleFonts.signika(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 20),
        _buildMealLogCategory(title: 'Sarapan', items: sarapanItems),
        const SizedBox(height: 16),
        _buildMealLogCategory(title: 'Makan Siang', items: siangItems),
        const SizedBox(height: 16),
        _buildMealLogCategory(title: 'Makan Malam', items: malamItems),
      ],
    );
  }

  Widget _buildMealLogCategory({
    required String title,
    required List<FoodLogItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F9EB),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.signika(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
              const Spacer(),
            ],
          ),

          if (items.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '• ${item.displayString}',
                  style: GoogleFonts.signika(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Belum ada data',
                style: GoogleFonts.signika(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onRefresh; // Terima fungsi refresh

  const _Header({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello Chan!',
              style: GoogleFonts.signika(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.nutrinTrackGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Temukan, lacak, makan makanan sehatmu.',
              style: GoogleFonts.signika(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        // Tombol Refresh
        IconButton(
          onPressed: onRefresh,
          icon: Icon(Icons.refresh, color: Colors.grey.shade500, size: 30),
        ),
      ],
    );
  }
}
