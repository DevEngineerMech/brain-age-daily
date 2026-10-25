
import '../constants/game_ids.dart';

enum MissionTier {
  easy,
  personal,
  challenge,
}

class MissionDefinition {
  final String id;
  final String title;
  final String description;
  final String metric;
  final int target;
  final int reward;
  final MissionTier tier;
  final String? gameId;

  const MissionDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.metric,
    required this.target,
    required this.reward,
    required this.tier,
    this.gameId,
  });
}

class DailyMissionsBank {
  DailyMissionsBank._();

  static List<MissionDefinition> _create() {
    final result = <MissionDefinition>[];

    // 60 VERIFIED GAME-SPECIFIC COMPLETION MISSIONS
    // 15 existing games x 4 completed-round targets.
    // GameResultsDialog saves each finished round to StatsService.
    for (final game in GameIds.all) {
      final name = GameIds.label(game);

      for (var level = 1; level <= 4; level++) {
        result.add(
          MissionDefinition(
            id: 'visit_${game}_$level',
            title: level == 1
                ? 'Complete $name'
                : '$name Champion $level',
            description: level == 1
                ? 'Finish a full $name round in Free Play.'
                : 'Finish $level full $name rounds in Free Play.',
            metric: 'game_visits', // Existing ID, now means completed rounds.
            target: level,
            reward: level <= 2 ? 30 : 40,
            tier: level == 1
                ? MissionTier.easy
                : level == 2
                    ? MissionTier.personal
                    : MissionTier.challenge,
            gameId: game,
          ),
        );
      }
    }

    // 10 DAILY CHECK MISSIONS.
    result.addAll(const [
      MissionDefinition(
        id: 'daily_1',
        title: 'Daily Warm-up',
        description: 'Complete a Daily Brain Check.',
        metric: 'checks',
        target: 1,
        reward: 30,
        tier: MissionTier.easy,
      ),
      MissionDefinition(
        id: 'daily_2',
        title: 'Second Check',
        description: 'Complete 2 daily checks today.',
        metric: 'checks',
        target: 2,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'daily_3',
        title: 'Five Correct',
        description: 'Get 5 correct answers in daily checks.',
        metric: 'correct',
        target: 5,
        reward: 30,
        tier: MissionTier.easy,
      ),
      MissionDefinition(
        id: 'daily_4',
        title: 'Ten Correct',
        description: 'Get 10 correct answers in daily checks.',
        metric: 'correct',
        target: 10,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'daily_5',
        title: 'Answer Explorer',
        description: 'Answer 10 daily check questions.',
        metric: 'attempts',
        target: 10,
        reward: 30,
        tier: MissionTier.easy,
      ),
      MissionDefinition(
        id: 'daily_6',
        title: 'Question Marathon',
        description: 'Answer 20 daily check questions.',
        metric: 'attempts',
        target: 20,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'daily_7',
        title: 'Score Builder',
        description: 'Earn 5 points in daily checks.',
        metric: 'score',
        target: 5,
        reward: 30,
        tier: MissionTier.easy,
      ),
      MissionDefinition(
        id: 'daily_8',
        title: 'Score Hunter',
        description: 'Earn 15 points in daily checks.',
        metric: 'score',
        target: 15,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'daily_9',
        title: 'Accurate Thinker',
        description: 'Reach at least 60% accuracy '
            'in a daily check.',
        metric: 'accuracy',
        target: 60,
        reward: 30,
        tier: MissionTier.easy,
      ),
      MissionDefinition(
        id: 'daily_10',
        title: 'Precision Master',
        description: 'Reach at least 80% accuracy '
            'in a daily check.',
        metric: 'accuracy',
        target: 80,
        reward: 40,
        tier: MissionTier.challenge,
      ),
    ]);

    // 10 FREE PLAY VARIETY MISSIONS.
    result.addAll(const [
      MissionDefinition(
        id: 'free_1',
        title: 'Practice Starter',
        description: 'Complete 1 Free Play round.',
        metric: 'visits',
        target: 1,
        reward: 30,
        tier: MissionTier.easy,
      ),
      MissionDefinition(
        id: 'free_2',
        title: 'Practice Pair',
        description: 'Complete 2 Free Play rounds today.',
        metric: 'visits',
        target: 2,
        reward: 30,
        tier: MissionTier.easy,
      ),
      MissionDefinition(
        id: 'free_3',
        title: 'Practice Trio',
        description: 'Complete 3 Free Play rounds today.',
        metric: 'visits',
        target: 3,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'free_4',
        title: 'Practice Marathon',
        description: 'Complete 5 Free Play rounds today.',
        metric: 'visits',
        target: 5,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'free_5',
        title: 'New Territory',
        description: 'Complete rounds in 2 different Free Play games.',
        metric: 'unique_visits',
        target: 2,
        reward: 30,
        tier: MissionTier.easy,
      ),
      MissionDefinition(
        id: 'free_6',
        title: 'Variety Player',
        description: 'Complete rounds in 3 different Free Play games.',
        metric: 'unique_visits',
        target: 3,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'free_7',
        title: 'Game Explorer',
        description: 'Complete rounds in 4 different Free Play games.',
        metric: 'unique_visits',
        target: 4,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'free_8',
        title: 'All-Round Practice',
        description: 'Complete rounds in 5 different Free Play games.',
        metric: 'unique_visits',
        target: 5,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'free_9',
        title: 'Back for More',
        description: 'Complete 4 Free Play rounds today.',
        metric: 'visits',
        target: 4,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'free_10',
        title: 'Dedicated Explorer',
        description: 'Complete 6 Free Play rounds today.',
        metric: 'visits',
        target: 6,
        reward: 40,
        tier: MissionTier.challenge,
      ),
    ]);

    // 10 PERSONAL IMPROVEMENT MISSIONS.
    // Targets for these are calculated using saved
    // previous results by the generator.
    result.addAll(const [
      MissionDefinition(
        id: 'personal_1',
        title: 'Beat Your Score',
        description: 'Beat your previous daily score.',
        metric: 'improve_score',
        target: 1,
        reward: 40,
        tier: MissionTier.personal,
      ),
      MissionDefinition(
        id: 'personal_2',
        title: 'Accuracy Upgrade',
        description: 'Improve your previous accuracy.',
        metric: 'improve_accuracy',
        target: 1,
        reward: 40,
        tier: MissionTier.personal,
      ),
      MissionDefinition(
        id: 'personal_3',
        title: 'Faster Thinking',
        description: 'Beat your previous response time.',
        metric: 'improve_speed',
        target: 1,
        reward: 40,
        tier: MissionTier.personal,
      ),
      MissionDefinition(
        id: 'personal_4',
        title: 'Brain Age Goal',
        description: 'Improve your previous brain age.',
        metric: 'improve_age',
        target: 1,
        reward: 40,
        tier: MissionTier.personal,
      ),
      MissionDefinition(
        id: 'personal_5',
        title: 'Strengthen Your Weakness',
        description: 'Practise your lowest-scoring game.',
        metric: 'weak_visits',
        target: 1,
        reward: 40,
        tier: MissionTier.personal,
      ),
      MissionDefinition(
        id: 'personal_6',
        title: 'Weak Point Workout',
        description: 'Complete your weakest game twice.',
        metric: 'weak_visits',
        target: 2,
        reward: 40,
        tier: MissionTier.personal,
      ),
      MissionDefinition(
        id: 'personal_7',
        title: 'Play Your Strength',
        description: 'Complete your strongest game.',
        metric: 'strong_visits',
        target: 1,
        reward: 40,
        tier: MissionTier.personal,
      ),
      MissionDefinition(
        id: 'personal_8',
        title: 'Double Your Strength',
        description: 'Complete your strongest game twice.',
        metric: 'strong_visits',
        target: 2,
        reward: 40,
        tier: MissionTier.personal,
      ),
      MissionDefinition(
        id: 'personal_9',
        title: 'Personal Score Target',
        description: 'Reach a score based on '
            'your recent results.',
        metric: 'recent_score',
        target: 1,
        reward: 40,
        tier: MissionTier.personal,
      ),
      MissionDefinition(
        id: 'personal_10',
        title: 'Personal Accuracy Target',
        description: 'Reach an accuracy target based '
            'on your recent results.',
        metric: 'recent_accuracy',
        target: 1,
        reward: 40,
        tier: MissionTier.personal,
      ),
    ]);

    // 10 CONSISTENCY / EXTRA CHALLENGE MISSIONS.
    result.addAll(const [
      MissionDefinition(
        id: 'extra_1',
        title: 'Two-Game Day',
        description: 'Complete 2 Free Play rounds and '
            'complete your daily check.',
        metric: 'combo_two',
        target: 1,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'extra_2',
        title: 'Three-Game Day',
        description: 'Complete 3 Free Play rounds and '
            'complete your daily check.',
        metric: 'combo_three',
        target: 1,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'extra_3',
        title: 'Thinking Streak',
        description: 'Reach a 2-day check streak.',
        metric: 'streak',
        target: 2,
        reward: 30,
        tier: MissionTier.easy,
      ),
      MissionDefinition(
        id: 'extra_4',
        title: 'Streak Builder',
        description: 'Reach a 3-day check streak.',
        metric: 'streak',
        target: 3,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'extra_5',
        title: 'Five-Day Focus',
        description: 'Reach a 5-day check streak.',
        metric: 'streak',
        target: 5,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'extra_6',
        title: 'Week of Training',
        description: 'Reach a 7-day check streak.',
        metric: 'streak',
        target: 7,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'extra_7',
        title: 'Quick and Accurate',
        description: 'Reach 70% accuracy in '
            'a Daily Brain Check.',
        metric: 'accuracy',
        target: 70,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'extra_8',
        title: 'Brain Points',
        description: 'Earn 10 points in daily checks.',
        metric: 'score',
        target: 10,
        reward: 30,
        tier: MissionTier.easy,
      ),
      MissionDefinition(
        id: 'extra_9',
        title: 'Thinking Variety',
        description: 'Complete 3 different games and '
            'answer 5 daily questions correctly.',
        metric: 'combo_variety',
        target: 1,
        reward: 40,
        tier: MissionTier.challenge,
      ),
      MissionDefinition(
        id: 'extra_10',
        title: 'Active Brain Day',
        description: 'Complete 2 different games and '
            'answer 10 daily questions.',
        metric: 'combo_active',
        target: 1,
        reward: 40,
        tier: MissionTier.challenge,
      ),
    ]);

    assert(
      result.length == 100,
      'The mission bank must contain exactly 100 missions.',
    );

    assert(
      result.map((m) => m.id).toSet().length == 100,
      'Every mission needs a unique ID.',
    );

    return result;
  }

  static final List<MissionDefinition> all =
      List.unmodifiable(_create());

  static MissionDefinition? byId(String id) {
    for (final mission in all) {
      if (mission.id == id) return mission;
    }
    return null;
  }
}
