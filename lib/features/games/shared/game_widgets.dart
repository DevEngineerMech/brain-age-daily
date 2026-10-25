
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/game_ids.dart';
import '../../../core/services/stats_service.dart';
import 'game_theme.dart';

class GameScreen extends StatelessWidget {
  final Widget child;

  const GameScreen({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: GameTheme.backgroundGradient,
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}

class GameHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final IconData icon;
  final Color accent;

  const GameHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.icon,
    this.accent = GameTheme.purple,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          style: IconButton.styleFrom(
            backgroundColor: GameTheme.panel,
            side: const BorderSide(
              color: GameTheme.border,
            ),
          ),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          width: 41,
          height: 41,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.16),
            border: Border.all(
              color: accent.withOpacity(0.6),
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: accent,
            size: 23,
          ),
        ),
      ],
    );
  }
}

class GameRoundProgress extends StatelessWidget {
  final int current;
  final int total;
  final Color accent;

  const GameRoundProgress({
    super.key,
    required this.current,
    required this.total,
    this.accent = GameTheme.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ROUND PROGRESS',
              style: TextStyle(
                color: GameTheme.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            Text(
              '$current / $total',
              style: const TextStyle(
                color: GameTheme.gold,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: List.generate(total, (index) {
            final active = index < current;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 230),
                height: 7,
                margin:
                    const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: active
                      ? accent
                      : GameTheme.border.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class GamePanel extends StatelessWidget {
  final String title;
  final String instruction;
  final Widget child;
  final IconData icon;
  final Color accent;

  const GamePanel({
    super.key,
    required this.title,
    required this.instruction,
    required this.child,
    required this.icon,
    this.accent = GameTheme.purple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: GameTheme.card(accent: accent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              border: Border.all(
                color: accent.withOpacity(0.7),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 27,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            instruction,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: GameTheme.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 17),
          child,
        ],
      ),
    );
  }
}

class GameAnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool selected;
  final bool? correct;
  final Color accent;

  const GameAnswerButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.selected = false,
    this.correct,
    this.accent = GameTheme.purple,
  });

  @override
  Widget build(BuildContext context) {
    final color = !selected
        ? accent
        : correct == true
            ? GameTheme.green
            : correct == false
                ? GameTheme.red
                : accent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 190),
      decoration: BoxDecoration(
        color: selected
            ? color.withOpacity(0.24)
            : GameTheme.panelLight,
        border: Border.all(
          color: selected ? color : GameTheme.border,
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 57),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(
                      correct == true
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: color,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameScoreChip extends StatelessWidget {
  final int score;
  final int total;

  const GameScoreChip({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: GameTheme.card(
        accent: GameTheme.gold,
        radius: 15,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: GameTheme.gold,
            size: 21,
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'Current Score',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$score / $total',
            style: const TextStyle(
              color: GameTheme.gold,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// AUTOMATICALLY SAVED FREE PLAY RESULTS
// =====================================================

class GameResultsDialog extends StatefulWidget {
  final String title;
  final int score;
  final int total;
  final VoidCallback onReplay;
  final VoidCallback onExit;

  const GameResultsDialog({
    super.key,
    required this.title,
    required this.score,
    required this.total,
    required this.onReplay,
    required this.onExit,
  });

  @override
  State<GameResultsDialog> createState() =>
      _GameResultsDialogState();
}

class _GameResultsDialogState extends State<GameResultsDialog> {
  bool _saving = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  String? _gameIdForTitle(String title) {
    for (final id in GameIds.all) {
      if (GameIds.label(id).toLowerCase() ==
          title.trim().toLowerCase()) {
        return id;
      }
    }
    return null;
  }

  Future<void> _saveResult() async {
    final gameId = _gameIdForTitle(widget.title);

    if (gameId == null) {
      debugPrint(
        'Unknown game results title: ${widget.title}',
      );

      if (mounted) {
        setState(() {
          _saving = false;
          _saved = false;
        });
      }
      return;
    }

    try {
      await StatsService.saveFreePlayResult(
        gameId: gameId,
        score: widget.score,
        attempts: widget.total,
      );

      if (mounted) {
        setState(() {
          _saving = false;
          _saved = true;
        });
      }
    } catch (error) {
      debugPrint('Free Play save error: $error');

      if (mounted) {
        setState(() {
          _saving = false;
          _saved = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fraction = widget.total <= 0
        ? 0.0
        : widget.score / widget.total;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: GameTheme.card(
          accent: GameTheme.gold,
          radius: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 59,
              color: GameTheme.gold,
            ),
            const SizedBox(height: 11),
            const Text(
              'ROUND COMPLETE!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.title,
              style: const TextStyle(
                color: GameTheme.muted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '${widget.score} / ${widget.total}',
              style: const TextStyle(
                color: GameTheme.gold,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${(fraction * 100).round()}% accuracy',
              style: const TextStyle(
                color: GameTheme.muted,
              ),
            ),
            const SizedBox(height: 13),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _saving
                      ? Icons.sync_rounded
                      : _saved
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                  color: _saved
                      ? GameTheme.green
                      : GameTheme.muted,
                  size: 17,
                ),
                const SizedBox(width: 6),
                Text(
                  _saving
                      ? 'Saving your result...'
                      : _saved
                          ? 'Result saved!'
                          : 'Result could not be saved',
                  style: const TextStyle(
                    color: GameTheme.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _saving ? null : widget.onReplay,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Play Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(13),
                ),
              ),
            ),
            TextButton(
              onPressed: _saving ? null : widget.onExit,
              child: const Text(
                'Back to Free Play',
                style: TextStyle(color: GameTheme.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
