import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/mood_service.dart';
import 'history_page.dart';
import 'insights_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _moodService = MoodService();
  final _noteController = TextEditingController();
  String? _selectedMood;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _moods = [
    {
      'name': 'Loving',
      'icon': Icons.favorite,
      'color': Color(0xFFFF8CAB),
      'gradient': [Color(0xFFFF8CAB), Color(0xFFFF6B9C)],
    },
    {
      'name': 'Happy',
      'icon': Icons.sentiment_very_satisfied,
      'color': Color(0xFFFFB347),
      'gradient': [Color(0xFFFFB347), Color(0xFFFF9417)],
    },
    {
      'name': 'Sad',
      'icon': Icons.sentiment_very_dissatisfied,
      'color': Color(0xFF87CEEB),
      'gradient': [Color(0xFF87CEEB), Color(0xFF5FB6E5)],
    },
    {
      'name': 'Excited',
      'icon': Icons.electric_bolt,
      'color': Color.fromARGB(255, 195, 135, 235),
      'gradient': [
        Color.fromARGB(255, 215, 135, 235),
        Color.fromARGB(255, 164, 95, 229),
      ],
    },
    {
      'name': 'Angry',
      'icon': Icons.mood_bad,
      'color': Color.fromARGB(255, 255, 50, 46),
      'gradient': [
        Color.fromARGB(255, 251, 152, 152),
        Color.fromARGB(255, 252, 53, 53),
      ],
    },
    {
      'name': 'Calm',
      'icon': Icons.water_drop,
      'color': Color(0xFF98FB98),
      'gradient': [Color(0xFF98FB98), Color(0xFF70E970)],
    },
  ];

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      return user.email!.split('@')[0];
    }
    return 'User';
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a mood')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _moodService.saveMood(
        _selectedMood!,
        _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      if (success) {
        _noteController.clear();
        setState(() {
          _selectedMood = null;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mood saved successfully!')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You\'ve already logged a mood for today'),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save mood')));
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFF8CAB)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                '${_getGreeting()},\n${_getUserName()}!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'How are you feeling today?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: PageController(
                      viewportFraction: 0.4,
                      initialPage: 1,
                    ),
                    onPageChanged: (index) {
                      setState(() {
                        _selectedMood = _moods[index]['name'];
                      });
                    },
                    padEnds: true,
                    itemCount: _moods.length,
                    itemBuilder: (context, index) {
                      final mood = _moods[index];
                      final isSelected = _selectedMood == mood['name'];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMood = mood['name'];
                          });
                        },
                        child: AnimatedScale(
                          scale: isSelected ? 1.1 : 0.9,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? (mood['gradient'] as List<Color>)
                                    : [Colors.white, Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: mood['color'].withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  mood['icon'],
                                  size: 32,
                                  color: isSelected
                                      ? Colors.white
                                      : mood['color'],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  mood['name'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'scroll to choose another emotion',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Text my therapist...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8CAB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Mood',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryPage(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE5EC),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.history,
                                    color: Color(0xFFFF8CAB),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Mood\nHistory',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InsightsPage(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE5EC),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.bar_chart,
                                    color: Color(0xFFFF8CAB),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'See mood\nstatistics',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
}
