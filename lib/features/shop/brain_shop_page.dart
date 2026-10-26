
import 'package:flutter/material.dart';

import '../../core/services/daily_hearts_service.dart';
import '../../core/services/daily_missions_service.dart';
import '../games/shared/game_theme.dart';
import 'brain_shop_catalog.dart';
import 'coin_arcade_library_page.dart';

class BrainShopPage extends StatefulWidget {
  const BrainShopPage({super.key});

  @override
  State<BrainShopPage> createState() => _BrainShopPageState();
}

class _BrainShopPageState extends State<BrainShopPage>
    with WidgetsBindingObserver {
  Map<String, dynamic> _wallet = {};
  int _hearts = DailyHeartsService.maxHearts;
  bool _loading = true;
  bool _busy = false;

  int get _coins => (_wallet['coins'] as num?)?.toInt() ?? 0;
  int get _passes => (_wallet['passes'] as num?)?.toInt() ?? 0;
  int get _boosts => (_wallet['boosts'] as num?)?.toInt() ?? 0;
  String get _equipped => _wallet['equipped']?.toString() ?? '';
  List<String> get _unlocks =>
      List<String>.from(_wallet['unlocks'] ?? []);
  List<String> get _badges =>
      List<String>.from(_wallet['badges'] ?? []);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final wallet = await DailyMissionsService.getShopState();
      final hearts = await DailyHeartsService.getHearts();

      if (!mounted) return;

      setState(() {
        _wallet = wallet;
        _hearts = hearts;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Shop refresh failed: $error');

      if (!mounted) return;
      setState(() => _loading = false);
      _notice('Unable to refresh your shop balance.');
    }
  }

  void _notice(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: const Color(0xFF352161),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  bool _owned(BrainShopItem item) {
    if (item.kind == ShopKind.gameUnlock) {
      return _unlocks.contains(item.gameId);
    }

    if (item.kind == ShopKind.badge) {
      return _badges.contains(item.id);
    }

    return false;
  }

  Future<void> _openArcade() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CoinArcadeLibraryPage(),
      ),
    );

    if (mounted) await _refresh();
  }

  Future<void> _equip(BrainShopItem item) async {
    if (_busy) return;

    setState(() => _busy = true);

    try {
      final equipped =
          await DailyMissionsService.equipShopBadge(
        _equipped == item.id ? '' : item.id,
      );

      await _refresh();

      _notice(
        equipped
            ? 'Badge updated!'
            : 'You do not own this badge.',
      );
    } catch (error) {
      debugPrint('Badge equip error: $error');
      _notice('Could not update the badge.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _buy(BrainShopItem item) async {
    if (_busy) return;

    final passesBefore = _passes;
    setState(() => _busy = true);

    try {
      final outcome =
          await DailyMissionsService.buyShopItem(item.id);

      await _refresh();

      if (outcome == 0) {
        _notice('Not enough Brain Coins for ${item.title}.');
      } else if (outcome == 2) {
        _notice('You already own ${item.title}.');
      } else if (item.kind == ShopKind.mystery) {
        _notice(
          'Mystery chest: +${_passes - passesBefore} Arcade Passes!',
        );
      } else {
        _notice('${item.title} purchased!');
      }
    } catch (error) {
      debugPrint('Shop purchase error: $error');
      _notice('The purchase could not be completed.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _buyHeart() async {
    if (_busy ||
        _hearts >= DailyHeartsService.maxHearts) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GameTheme.panel,
        title: const Text(
          'Buy 1 Heart?',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          'Restore one Daily Brain Check heart for '
          '${DailyMissionsService.heartCoinPrice} Brain Coins. '
          'You can hold a maximum of 3 hearts.',
          style: const TextStyle(color: GameTheme.muted),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Buy Heart'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);

    try {
      final outcome =
          await DailyMissionsService.buyHeartWithCoins();

      await _refresh();

      if (outcome == 1) {
        _notice('❤️ +1 Heart added!');
      } else if (outcome == 2) {
        _notice('Your hearts are already full.');
      } else {
        _notice('Not enough Brain Coins to buy a heart.');
      }
    } catch (error) {
      debugPrint('Heart purchase error: $error');
      await _refresh();
      _notice('Could not complete heart purchase.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _inspect(BrainShopItem item) async {
    if (_busy) return;

    final owned = _owned(item);
    final equipped = _equipped == item.id &&
        item.kind == ShopKind.badge;

    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF21184E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: item.color.withOpacity(0.7),
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 66,
                width: 66,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 34,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: GameTheme.muted,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                owned
                    ? (equipped ? 'EQUIPPED' : 'OWNED')
                    : '${item.price} Brain Coins',
                style: TextStyle(
                  color: owned
                      ? GameTheme.green
                      : GameTheme.gold,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (item.kind == ShopKind.gameUnlock) ...[
                const SizedBox(height: 9),
                const Text(
                  'Permanent unlock. You can also play locked '
                  'games using one Arcade Pass or 20 coins '
                  'per attempt.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: GameTheme.muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, 'cancel'),
            child: const Text('Close'),
          ),
          if (item.kind == ShopKind.badge && owned)
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, 'equip'),
              child: Text(equipped ? 'Unequip' : 'Equip'),
            )
          else if (!owned)
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, 'buy'),
              child: const Text('Purchase'),
            ),
        ],
      ),
    );

    if (!mounted) return;

    if (action == 'buy') await _buy(item);
    if (action == 'equip') await _equip(item);
  }

  Widget _pill(
    IconData icon,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _walletCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: GameTheme.card(
        accent: GameTheme.gold,
        radius: 18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monetization_on_rounded,
                color: GameTheme.gold,
                size: 28,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BRAIN COINS',
                      style: TextStyle(
                        color: GameTheme.muted,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '$_coins',
                      style: const TextStyle(
                        color: GameTheme.gold,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _pill(
                Icons.favorite_rounded,
                '$_hearts/${DailyHeartsService.maxHearts}',
                GameTheme.red,
              ),
            ],
          ),
          const SizedBox(height: 9),
          const Divider(
            color: GameTheme.border,
            height: 1,
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _pill(
                Icons.confirmation_number_rounded,
                '$_passes passes',
                GameTheme.cyan,
              ),
              _pill(
                Icons.bolt_rounded,
                '$_boosts doublers',
                GameTheme.gold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String text,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(
    BrainShopItem item,
    bool compact,
  ) {
    final owned = _owned(item);

    final equipped = owned &&
        item.kind == ShopKind.badge &&
        _equipped == item.id;

    final iconSize = compact ? 24.0 : 28.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _busy ? null : () => _inspect(item),
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          padding: const EdgeInsets.all(9),
          decoration: GameTheme.card(
            accent: item.color,
            radius: 15,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    owned
                        ? Icons.check_circle_rounded
                        : Icons.lock_rounded,
                    size: 13,
                    color: owned
                        ? GameTheme.green
                        : GameTheme.muted,
                  ),
                  const Spacer(),
                  Text(
                    equipped
                        ? 'ACTIVE'
                        : owned
                            ? 'OWNED'
                            : 'LOCKED',
                    style: TextStyle(
                      color: owned
                          ? GameTheme.green
                          : GameTheme.muted,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Container(
                width: compact ? 38 : 44,
                height: compact ? 38 : 44,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: iconSize,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 7),
              Expanded(
                child: Center(
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 10 : 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Container(
                height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  equipped
                      ? 'EQUIPPED'
                      : owned
                          ? 'OWNED'
                          : '🪙 ${item.price}',
                  style: TextStyle(
                    color: owned
                        ? GameTheme.green
                        : GameTheme.gold,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 10 : 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heartCard(bool compact) {
    final full =
        _hearts >= DailyHeartsService.maxHearts;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (_busy || full) ? null : _buyHeart,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          padding: const EdgeInsets.all(9),
          decoration: GameTheme.card(
            accent: GameTheme.red,
            radius: 15,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    full
                        ? Icons.check_circle_rounded
                        : Icons.favorite_rounded,
                    color: full
                        ? GameTheme.green
                        : GameTheme.red,
                    size: 13,
                  ),
                  const Spacer(),
                  Text(
                    full ? 'FULL' : 'REFILL',
                    style: TextStyle(
                      color: full
                          ? GameTheme.green
                          : GameTheme.muted,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Container(
                width: compact ? 38 : 44,
                height: compact ? 38 : 44,
                decoration: BoxDecoration(
                  color: GameTheme.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite_rounded,
                  color: GameTheme.red,
                  size: compact ? 24 : 28,
                ),
              ),
              const SizedBox(height: 7),
              Expanded(
                child: Center(
                  child: Text(
                    '+1 Heart',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 10 : 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Container(
                height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: GameTheme.red.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  full
                      ? 'MAX HEARTS'
                      : '🪙 ${DailyMissionsService.heartCoinPrice}',
                  style: TextStyle(
                    color: full
                        ? GameTheme.green
                        : GameTheme.gold,
                    fontSize: compact ? 10 : 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryGrid(
    ShopCategory category, {
    bool withHeart = false,
  }) {
    final items =
        BrainShopCatalog.inCategory(category);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final columns = width >= 555
            ? 4
            : width >= 410
                ? 3
                : 2;

        final compact = columns >= 4;

        return GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount:
              items.length + (withHeart ? 1 : 0),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: compact ? 143 : 151,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            if (withHeart && index == 0) {
              return _heartCard(compact);
            }

            return _itemCard(
              items[index - (withHeart ? 1 : 0)],
              compact,
            );
          },
        );
      },
    );
  }

  Widget _section(
    ShopCategory category,
    String title,
    IconData icon,
    Color color, {
    bool withHeart = false,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(title, icon, color),
        _categoryGrid(
          category,
          withHeart: withHeart,
        ),
        const SizedBox(height: 21),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: GameTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: GameTheme.purple,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding:
                        const EdgeInsets.fromLTRB(
                      13, 10, 13, 25,
                    ),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Brain Shop',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.storefront_rounded,
                            color: GameTheme.gold,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _walletCard(),
                      const SizedBox(height: 11),
                      SizedBox(
                        height: 45,
                        child: FilledButton.icon(
                          onPressed:
                              _busy ? null : _openArcade,
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                GameTheme.gold,
                            foregroundColor:
                                const Color(0xFF281744),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(13),
                            ),
                          ),
                          icon: const Icon(
                            Icons.sports_esports_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'PLAY KNOWLEDGE ARCADE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 19),
                      _section(
                        ShopCategory.arcade,
                        'Arcade Games',
                        Icons.sports_esports_rounded,
                        GameTheme.cyan,
                      ),
                      _section(
                        ShopCategory.powerUps,
                        'Power-ups & Hearts',
                        Icons.favorite_rounded,
                        GameTheme.red,
                        withHeart: true,
                      ),
                      _section(
                        ShopCategory.customisation,
                        'Customisation',
                        Icons.auto_awesome_rounded,
                        GameTheme.purple,
                      ),
                      _section(
                        ShopCategory.specials,
                        'Specials',
                        Icons.card_giftcard_rounded,
                        GameTheme.gold,
                      ),
                      const Text(
                        'Tap an item to see details. Earn Brain Coins '
                        'from Daily Missions and the 7-Day '
                        'Reward Calendar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: GameTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
