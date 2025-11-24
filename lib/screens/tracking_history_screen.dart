import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/tracking_data.dart';
import '../service/api_service.dart';
import '../theme/app_theme.dart';

class TrackingHistory extends StatefulWidget {
  const TrackingHistory({super.key});

  @override
  State<TrackingHistory> createState() => _TrackingHistoryState();
}

class _TrackingHistoryState extends State<TrackingHistory> {
  late Future<List<DailyLog>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchHistory();
  }

  // Fungsi internal untuk memanggil API dan mem-parsing
  Future<List<DailyLog>> _fetchHistory() async {
    try {
      final List<dynamic> rawData = await ApiService.getHistory();
      return rawData
          .map((json) => DailyLog.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Nutrisi',
          style: GoogleFonts.signika(
            color: AppTheme.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: AppTheme.textColor),
      ),
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<List<DailyLog>>(
        future: _historyFuture,
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Gagal memuat data: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.signika(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'Belum ada riwayat data',
                style: GoogleFonts.signika(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          }

          // Data sudah berupa List<DailyLog>
          final historyList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final dailyLog = historyList[index];
              return _DayLogCard(dailyLog: dailyLog);
            },
          );
        },
      ),
    );
  }
}

// --- Widget Card (Tidak perlu diubah) ---

class _DayLogCard extends StatelessWidget {
  final DailyLog dailyLog;
  const _DayLogCard({required this.dailyLog});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shadowColor: Colors.grey.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dailyLog.formattedDate, // Gunakan helper
              style: GoogleFonts.signika(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.nutrinTrackGreen,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(dailyLog.summary), // Kirim object summary
            const Divider(height: 24),
            _buildMealLogCategory(
              title: 'Sarapan',
              items: dailyLog.sarapan, // Gunakan helper
            ),
            const SizedBox(height: 12),
            _buildMealLogCategory(
              title: 'Makan Siang',
              items: dailyLog.makanSiang, // Gunakan helper
            ),
            const SizedBox(height: 12),
            _buildMealLogCategory(
              title: 'Makan Malam',
              items: dailyLog.makanMalam, // Gunakan helper
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(DailySummary summary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMacroItem(
          'Kalori',
          '${summary.totalCaloriesKcal.toStringAsFixed(0)} kkal',
        ),
        _buildMacroItem(
          'Protein',
          '${summary.totalProteinG.toStringAsFixed(0)}g',
        ),
        _buildMacroItem('Lemak', '${summary.totalFatG.toStringAsFixed(0)}g'),
        _buildMacroItem('Karbo', '${summary.totalCarbsG.toStringAsFixed(0)}g'),
      ],
    );
  }

  Widget _buildMacroItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.signika(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: GoogleFonts.signika(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMealLogCategory({
    required String title,
    required List<FoodLogItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.signika(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              '(Belum ada data)',
              style: GoogleFonts.signika(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0, left: 10.0),
              child: Text(
                '• ${item.displayString}', // Gunakan helper
                style: GoogleFonts.signika(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
