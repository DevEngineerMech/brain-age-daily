
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/player_account_service.dart';
import '../../core/services/saved_data_audit_service.dart';
import '../../core/services/social_leaderboard_service.dart';

class PlayerAccountPage extends StatefulWidget {
  const PlayerAccountPage({super.key});

  @override
  State<PlayerAccountPage> createState() =>
      _PlayerAccountPageState();
}

class _PlayerAccountPageState
    extends State<PlayerAccountPage> {
  static const Color background = Color(0xFF100C2F);
  static const Color panel = Color(0xFF221949);
  static const Color gold = Color(0xFFFFC75D);
  static const Color muted = Color(0xFFC3B5DC);
  static const Color green = Color(0xFF4BE09D);
  static const Color red = Color(0xFFFF8297);

  PlayerProfile? _profile;
  SavedDataAudit? _audit;

  bool _loading = true;
  bool _auditing = false;
  bool _deleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profile =
          await SocialLeaderboardService.getMyProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not load the player profile: $error';
      });
    }
  }

  Future<void> _runAudit() async {
    if (_auditing) return;

    setState(() {
      _auditing = true;
      _error = null;
    });

    try {
      final audit = await SavedDataAuditService.inspect();

      if (!mounted) return;

      setState(() => _audit = audit);
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Saved-data check failed: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _auditing = false);
    }
  }

  Future<bool> _confirmDeletion() async {
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: !_deleting,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final matches =
                controller.text.trim() == 'DELETE';

            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'Delete Player Account?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This permanently deletes your online '
                    'username, Firebase account and '
                    'leaderboard information.\n\n'
                    'Your locally saved Brain Coins, '
                    'game results, achievements and '
                    'purchases will remain on this device.',
                    style: TextStyle(
                      color: muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Type DELETE to confirm:',
                    style: TextStyle(
                      color: red,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    autocorrect: false,
                    textCapitalization:
                        TextCapitalization.characters,
                    onChanged: (_) => setDialogState(() {}),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'DELETE',
                      hintStyle: const TextStyle(
                        color: muted,
                      ),
                      filled: true,
                      fillColor: background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: matches
                      ? () =>
                          Navigator.pop(dialogContext, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: background,
                  ),
                  child: const Text(
                    'Delete Account',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // Dispose after the dialog has finished its route
    // transition to avoid disposal during animations.
    await Future<void>.delayed(
      const Duration(milliseconds: 250),
    );
    controller.dispose();

    return confirmed == true;
  }

  Future<void> _deleteAccount() async {
    if (_deleting) return;

    final confirmed = await _confirmDeletion();

    if (!confirmed || !mounted) return;

    setState(() {
      _deleting = true;
      _error = null;
    });

    try {
      await PlayerAccountService.deletePlayerAccount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your online player account has been deleted. '
            'Local game progress has been kept.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not finish deleting the account: '
            '$error';
      });
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }

  Widget _line(
    String label,
    String value, {
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFF625098),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: gold,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );
  }

  Widget _savedDataSection() {
    final audit = _audit;

    return _section(
      title: 'Saved Game Data',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Check that your wallet and gameplay records '
            'are readable before submitting the update.',
            style: TextStyle(
              color: muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _auditing ? null : _runAudit,
              icon: _auditing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.fact_check_rounded),
              label: Text(
                _auditing
                    ? 'Checking data...'
                    : 'CHECK SAVED DATA',
              ),
            ),
          ),
          if (audit != null) ...[
            const SizedBox(height: 12),
            _line(
              'Brain Coins',
              '${audit.coins}',
              color: gold,
            ),
            _line(
              'Permanent Arcade unlocks',
              '${audit.arcadeUnlocks}',
            ),
            _line(
              'Arcade Passes',
              '${audit.arcadePasses}',
            ),
            _line(
              'Mission Doublers',
              '${audit.missionDoublers}',
            ),
            _line(
              'Owned badges',
              '${audit.ownedBadges}',
            ),
            _line(
              'Daily Brain Checks saved',
              '${audit.dailySessions}',
            ),
            _line(
              'Free Play results saved',
              '${audit.freePlayResults}',
            ),
            _line(
              'Missions claimed today',
              '${audit.claimedMissions}',
            ),
            _line(
              'Last claimed reward day',
              '${audit.calendarDay}',
            ),
            _line(
              'Today’s reward claimed',
              audit.calendarClaimedToday ? 'Yes' : 'No',
            ),
            _line(
              'Mystery Bonus state',
              audit.mysteryStatus,
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                Icon(
                  audit.passed
                      ? Icons.check_circle_rounded
                      : Icons.warning_amber_rounded,
                  color: audit.passed ? green : red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    audit.passed
                        ? 'Saved records passed the '
                            'structural checks.'
                        : '${audit.problems.length} potential '
                            'data issue(s) found.',
                    style: TextStyle(
                      color: audit.passed ? green : red,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            for (final problem in audit.problems)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '• $problem',
                  style: const TextStyle(
                    color: red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16, 8, 16, 30,
          ),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _deleting
                      ? null
                      : () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Player Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _section(
              title: 'Your Player Profile',
              child: _loading
                  ? const CircularProgressIndicator()
                  : Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _line(
                          'Username',
                          _profile?.username ?? 'Not created',
                        ),
                        _line(
                          'Online account',
                          FirebaseAuth
                                      .instance.currentUser !=
                                  null
                              ? 'Connected'
                              : 'Not connected',
                        ),
                        const Text(
                          'Your online username is separate '
                          'from the locally saved game data.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 14),
            _savedDataSection(),
            const SizedBox(height: 14),
            _section(
              title: 'Delete Player Account',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Permanently remove your online player '
                    'identity, reserved username and '
                    'leaderboard entries.\n\n'
                    'This does not reset your local '
                    'Brain Coins, achievements or games.',
                    style: TextStyle(
                      color: muted,
                      height: 1.5,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _deleting
                          ? null
                          : _deleteAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            red.withOpacity(0.16),
                        foregroundColor: red,
                        side: const BorderSide(color: red),
                        padding: const EdgeInsets.all(14),
                      ),
                      icon: _deleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: red,
                              ),
                            )
                          : const Icon(
                              Icons.delete_forever_rounded,
                            ),
                      label: Text(
                        _deleting
                            ? 'Deleting account...'
                            : 'DELETE PLAYER ACCOUNT',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 13),
              Text(
                _error!,
                style: const TextStyle(
                  color: red,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
