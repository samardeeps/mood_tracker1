import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry.dart';

class MoodService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Get the current user's ID
  String? get _userId => _auth.currentUser?.uid;

  // Reference to the user's moods collection
  CollectionReference<Map<String, dynamic>> _moodsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('moods');
  }

  // Save a new mood entry
  Future<bool> saveMood(String mood, String? note) async {
    if (_userId == null) return false;

    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Check if entry already exists for today
    final existingDoc = await _moodsCollection(_userId!).doc(dateStr).get();
    if (existingDoc.exists) {
      return false; // Don't allow duplicate entries for the same day
    }

    await _moodsCollection(_userId!).doc(dateStr).set({
      'mood': mood,
      'note': note,
      'timestamp': FieldValue.serverTimestamp(),
    });

    return true;
  }

  // Update note for an existing mood entry
  Future<bool> updateNote(String date, String note) async {
    if (_userId == null) return false;

    await _moodsCollection(_userId!).doc(date).update({'note': note});

    return true;
  }

  // Get last 7 days of mood entries
  Stream<List<MoodEntry>> getLast7DaysMoods() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _moodsCollection(_userId!)
        .orderBy('timestamp', descending: true)
        .limit(7)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return MoodEntry.fromMap(data);
          }).toList();
        });
  }

  // Calculate mood insights
  Future<Map<String, dynamic>> calculateInsights() async {
    if (_userId == null) {
      return {
        'mostFrequentMood': 'Unknown',
        'happyPercentage': 0.0,
        'longestStreak': 0,
      };
    }

    final moodsSnapshot = await _moodsCollection(
      _userId!,
    ).orderBy('timestamp', descending: true).limit(7).get();

    final moods = moodsSnapshot.docs
        .map((doc) => doc.data()['mood'] as String)
        .toList();

    // Most frequent mood
    final moodCounts = <String, int>{};
    for (final mood in moods) {
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }
    final mostFrequentMood = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Happy percentage
    final happyCount = moods.where((mood) => mood == 'Happy').length;
    final happyPercentage = moods.isEmpty
        ? 0.0
        : (happyCount / moods.length) * 100;

    // Longest streak
    int longestStreak = 1;
    int currentStreak = 1;
    for (int i = 1; i < moods.length; i++) {
      if (moods[i] == moods[i - 1]) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return {
      'mostFrequentMood': mostFrequentMood,
      'happyPercentage': happyPercentage,
      'longestStreak': longestStreak,
    };
  }
}
