import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MoodModel(),
      child: const MyApp(),
    ),
  );
}

/// --- Mood Model (State) -----------------------------------------------
/// Holds the current mood, background color (Bonus #1),
/// and counts of selections (Bonus #2).
class MoodModel with ChangeNotifier {
  Mood _mood = Mood.happy;

  // Bonus #2: counters for each mood
  final Map<Mood, int> _counts = {
    Mood.happy: 0,
    Mood.sad: 0,
    Mood.excited: 0,
  };

  Mood get mood => _mood;
  Map<Mood, int> get counts => Map.unmodifiable(_counts);

  void setHappy() {
    _mood = Mood.happy;
    _increment(Mood.happy);
    notifyListeners(); // Critical for UI updates
  }

  void setSad() {
    _mood = Mood.sad;
    _increment(Mood.sad);
    notifyListeners();
  }

  void setExcited() {
    _mood = Mood.excited;
    _increment(Mood.excited);
    notifyListeners();
  }

  void _increment(Mood m) {
    _counts[m] = (_counts[m] ?? 0) + 1;
  }

  // --- Bonus #1: Background color depends on mood -----------------------
  // Happy → Yellow, Sad → Blue, Excited → Orange
  Color get backgroundColor {
    switch (_mood) {
      case Mood.happy:
        return Colors.yellow.shade100;
      case Mood.sad:
        return Colors.lightBlue.shade100;
      case Mood.excited:
        return Colors.orange.shade100;
    }
  }

  // Asset paths (optional; falls back to emoji if missing)
  String get assetPath {
    switch (_mood) {
      case Mood.happy:
        return 'assets/happy.png';
      case Mood.sad:
        return 'assets/sad.png';
      case Mood.excited:
        return 'assets/excited.png';
    }
  }

  String get emoji {
    switch (_mood) {
      case Mood.happy:
        return '😊';
      case Mood.sad:
        return '😢';
      case Mood.excited:
        return '🎉';
    }
  }
}

enum Mood { happy, sad, excited }

/// --- App Root ----------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Toggle Challenge',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// --- Home Page ---------------------------------------------------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = context.watch<MoodModel>().backgroundColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Mood Toggle Challenge')),
      body: Container(
        color: bg,
        width: double.infinity,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: _Content(),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'How are you feeling?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        MoodDisplay(),
        SizedBox(height: 40),
        MoodButtons(),
        SizedBox(height: 24),
        MoodCounter(), // Bonus #2 widget
      ],
    );
  }
}

/// --- Mood Display (reads state with Consumer) --------------------------
class MoodDisplay extends StatelessWidget {
  const MoodDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, moodModel, _) {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220, maxHeight: 220),
          child: Image.asset(
            moodModel.assetPath,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) {
              return Text(
                moodModel.emoji,
                style: const TextStyle(fontSize: 100),
              );
            },
          ),
        );
      },
    );
  }
}

/// --- Mood Buttons (writes state; read-only context) --------------------
class MoodButtons extends StatelessWidget {
  const MoodButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final mood = context.read<MoodModel>();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          onPressed: mood.setHappy,
          icon: const Text('😊', style: TextStyle(fontSize: 20)),
          label: const Text('Happy'),
        ),
        ElevatedButton.icon(
          onPressed: mood.setSad,
          icon: const Text('😢', style: TextStyle(fontSize: 20)),
          label: const Text('Sad'),
        ),
        ElevatedButton.icon(
          onPressed: mood.setExcited,
          icon: const Text('🎉', style: TextStyle(fontSize: 20)),
          label: const Text('Excited'),
        ),
      ],
    );
  }
}

/// --- Mood Counter (reads counts; Bonus #2) -----------------------------
class MoodCounter extends StatelessWidget {
  const MoodCounter({super.key});

  String _label(Mood m) {
    switch (m) {
      case Mood.happy:
        return 'Happy';
      case Mood.sad:
        return 'Sad';
      case Mood.excited:
        return 'Excited';
    }
  }

  String _emoji(Mood m) {
    switch (m) {
      case Mood.happy:
        return '😊';
      case Mood.sad:
        return '😢';
      case Mood.excited:
        return '🎉';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodModel>(
      builder: (context, model, _) {
        final counts = model.counts;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(top: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _countChip(_emoji(Mood.happy), _label(Mood.happy), counts[Mood.happy] ?? 0),
                _countChip(_emoji(Mood.sad), _label(Mood.sad), counts[Mood.sad] ?? 0),
                _countChip(_emoji(Mood.excited), _label(Mood.excited), counts[Mood.excited] ?? 0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _countChip(String emoji, String label, int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$emoji $label', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('$value', style: const TextStyle(fontSize: 18)),
      ],
    );
  }
}
