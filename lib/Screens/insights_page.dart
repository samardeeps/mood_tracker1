import 'package:flutter/material.dart';
import '../services/mood_service.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Loving':
        return const Color(0xFFFF8CAB);
      case 'Happy':
        return const Color(0xFFFFB347);
      case 'Sad':
        return const Color(0xFF87CEEB);
      case 'Excited':
        return const Color.fromARGB(255, 195, 135, 235);
      case 'Angry':
        return const Color.fromARGB(255, 255, 50, 46);
      case 'Calm':
        return const Color(0xFF98FB98);
      default:
        return const Color(0xFF4F4F4F);
    }
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'Loving':
        return Icons.favorite;
      case 'Happy':
        return Icons.sentiment_very_satisfied;
      case 'Sad':
        return Icons.sentiment_very_dissatisfied;
      case 'Excited':
        return Icons.electric_bolt;
      case 'Angry':
        return Icons.mood_bad;
      case 'Calm':
        return Icons.water_drop;
      default:
        return Icons.mood;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF6F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mood Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF1D1D1D),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFF8CAB)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: MoodService().calculateInsights(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Color(0xFFFF6B6B),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF1D1D1D),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8CAB)),
              ),
            );
          }

          final insights = snapshot.data!;
          final mostFrequentMood = insights['mostFrequentMood'] as String;
          final happyPercentage = insights['happyPercentage'] as double;
          final longestStreak = insights['longestStreak'] as int;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Most Frequent Mood',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFF1D1D1D),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getMoodColor(
                            mostFrequentMood,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getMoodIcon(mostFrequentMood),
                          size: 48,
                          color: _getMoodColor(mostFrequentMood),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        mostFrequentMood,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: _getMoodColor(mostFrequentMood),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Happy Days',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFF1D1D1D),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${happyPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getMoodColor('Happy'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'of the last 7 days',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Longest Mood Streak',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFF1D1D1D),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$longestStreak days',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF8CAB),
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'with the same mood',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
