import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/mood_service.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _moodService = MoodService();
  final _noteController = TextEditingController();

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Happy':
        return const Color(0xFFFFD93D);
      case 'Sad':
        return const Color(0xFF6C91C2);
      case 'Angry':
        return const Color(0xFFFF6B6B);
      case 'Neutral':
        return const Color(0xFF4F4F4F);
      default:
        return const Color(0xFF4F4F4F);
    }
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'Happy':
        return Icons.sentiment_very_satisfied;
      case 'Sad':
        return Icons.sentiment_very_dissatisfied;
      case 'Angry':
        return Icons.mood_bad;
      case 'Neutral':
        return Icons.sentiment_neutral;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Future<void> _editNote(
    BuildContext context,
    String date,
    String currentNote,
  ) async {
    _noteController.text = currentNote;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Note',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF1D1D1D),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Text my therapist...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFFF8CAB)),
            ),
            filled: true,
            fillColor: const Color(0xFFFEF6F6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              await _moodService.updateNote(date, _noteController.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFFFF8CAB)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF6F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Mood History',
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
      body: StreamBuilder<List<MoodEntry>>(
        stream: _moodService.getLast7DaysMoods(),
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

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8CAB)),
              ),
            );
          }

          final moods = snapshot.data ?? [];

          if (moods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mood_rounded, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No mood entries yet',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              final date = DateFormat('yyyy-MM-dd').format(mood.timestamp);
              final displayDate = DateFormat(
                'EEEE, MMMM d',
              ).format(mood.timestamp);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _editNote(context, date, mood.note ?? ''),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getMoodColor(
                                    mood.mood,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getMoodIcon(mood.mood),
                                  color: _getMoodColor(mood.mood),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayDate,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: const Color(0xFF1D1D1D),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      mood.mood,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: _getMoodColor(mood.mood),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_note_rounded,
                                  color: Color(0xFFFF8CAB),
                                ),
                                onPressed: () =>
                                    _editNote(context, date, mood.note ?? ''),
                              ),
                            ],
                          ),
                          if (mood.note != null && mood.note!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF6F6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                mood.note!,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: const Color(0xFF666666)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
