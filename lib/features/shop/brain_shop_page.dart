
import 'package:flutter/material.dart';

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
  ShopCategory _category = ShopCategory.arcade;

  Map<String, dynamic> _wallet = {};
  bool _loading = true;
  bool _busy = false;

  int get _coins =>
      (_wallet['coins'] as num?)?.toInt() ?? 0;

  int get _passes =>
      (_wallet['passes'] as num?)?.toInt() ?? 0;

  int get _boosts =>
      (_wallet['boosts'] as num?)?.toInt() ?? 0;

  String get _equipped =>
      _wallet['equipped']?.toString() ?? '';

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
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    try {
      final result =
          await DailyMissionsService.getShopState();

      if (!mounted) return;

      setState(() {
        _wallet = result;
        _loading = false;
      });
    } catch (error) {
      debugPrint('Brain Shop wallet error: $error');

      if (mounted) {
        setState(() => _loading = false);
        _notice('Could not load Brain Coins.');
      }
    }
  }

  void _notice(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF39226F),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  bool _owned(BrainShopItem item) {
    switch (item.kind) {
      case ShopKind.gameUnlock:
        return _unlocks.contains(item.gameId);

      case ShopKind.badge:
        return _badges.contains(item.id);

      default:
        return false;
    }
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
      final success =
          await DailyMissionsService.equipShopBadge(item.id);

      await _refresh();

      _notice(
        success
            ? '${item.title} equipped!'
            : 'You do not own this badge.',
      );
    } catch (error) {
      debugPrint('Badge equip error: $error');
      _notice('Could not equip this badge.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeBadge() async {
    if (_busy) return;

    setState(() => _busy = true);

    try {
      await DailyMissionsService.equipShopBadge('');
      await _refresh();
      _notice('Badge unequipped.');
    } catch (error) {
      debugPrint('Badge removal error: $error');
      _notice('Could not remove the badge.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _buy(BrainShopItem item) async {
    if (_busy) return;

    final previousPasses = _passes;

    setState(() => _busy = true);

    try {
      final result =
          await DailyMissionsService.buyShopItem(item.id);

      await _refresh();

      if (result == 0) {
        _notice(
          'Not enough coins. You need ${item.price} '
          'and have $_coins.',
        );
      } else if (result == 2) {
        _notice('You already own ${item.title}.');
      } else if (item.kind == ShopKind.mystery) {
        final received = _passes - previousPasses;

        if (!mounted) return;

        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: GameTheme.panel,
            title: const Text(
              'MYSTERY CHEST!',
              style: TextStyle(
                color: GameTheme.gold,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: GameTheme.gold,
                  size: 69,
                ),
                const SizedBox(height: 14),
                Text(
                  'You won $received Arcade Passes!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext),
                child: const Text('Collect'),
              ),
            ],
          ),
        );
      } else {
        _notice('${item.title} purchased!');
      }
    } catch (error) {
      debugPrint('Brain Shop purchase error: $error');
      _notice('Could not complete this purchase.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _inspect(BrainShopItem item) async {
    if (_busy) return;

    final owned = _owned(item);

    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF21184E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.color,
                    width: 2,
                  ),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 51,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                item.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: GameTheme.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              if (!owned)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: GameTheme.gold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.price} Brain Coins',
                      style: const TextStyle(
                        color: GameTheme.gold,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              if (item.kind == ShopKind.gameUnlock)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Permanently unlock this game, or '
                    'play individual rounds in Knowledge Arcade '
                    'using an Arcade Pass or '
                    '${BrainShopCatalog.singleArcadeEntryPrice} '
                    'Brain Coins.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: GameTheme.muted,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, 'cancel'),
              child: const Text(
                'Cancel',
                style: TextStyle(color: GameTheme.muted),
              ),
            ),
            if (item.kind == ShopKind.badge && owned)
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, 'equip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Equip'),
              )
            else if (owned)
              const Text(
                'OWNED',
                style: TextStyle(
                  color: GameTheme.green,
                  fontWeight: FontWeight.w900,
                ),
              )
            else
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, 'buy'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Buy'),
              ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (action == 'buy') {
      await _buy(item);
    } else if (action == 'equip') {
      await _equip(item);
    }
  }

  String _categoryTitle(ShopCategory category) {
    switch (category) {
      case ShopCategory.arcade:
        return 'Arcade';

      case ShopCategory.powerUps:
        return 'Power-ups';

      case ShopCategory.customisation:
        return 'Customisation';

      case ShopCategory.specials:
        return 'Specials';
    }
  }

  IconData _categoryIcon(ShopCategory category) {
    switch (category) {
      case ShopCategory.arcade:
        return Icons.sports_esports_rounded;

      case ShopCategory.powerUps:
        return Icons.bolt_rounded;

      case ShopCategory.customisation:
        return Icons.auto_awesome_rounded;

      case ShopCategory.specials:
        return Icons.card_giftcard_rounded;
    }
  }

  Widget _walletHeader() {
    final badge = BrainShopCatalog.badge(_equipped);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: GameTheme.card(
        accent: GameTheme.gold,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 53,
                height: 53,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: GameTheme.gold.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.monetization_on_rounded,
                  color: GameTheme.gold,
                  size: 34,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR BRAIN COINS',
                      style: TextStyle(
                        color: GameTheme.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$_coins',
                      style: const TextStyle(
                        color: GameTheme.gold,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                IconButton(
                  onPressed: _removeBadge,
                  tooltip: 'Unequip badge',
                  icon: Icon(
                    badge.icon,
                    size: 31,
                    color: badge.color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 13),
          const Divider(color: GameTheme.border),
          Row(
            children: [
              const Icon(
                Icons.confirmation_number_rounded,
                color: GameTheme.cyan,
                size: 21,
              ),
              const SizedBox(width: 6),
              Text(
                '$_passes Arcade Passes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.bolt_rounded,
                color: GameTheme.gold,
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                '$_boosts Doublers',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playArcadeButton() {
    return SizedBox(
      width: double.infinity,
      height: 53,
      child: ElevatedButton.icon(
        onPressed: _openArcade,
        style: ElevatedButton.styleFrom(
          backgroundColor: GameTheme.gold,
          foregroundColor: const Color(0xFF251338),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: const Icon(Icons.sports_esports_rounded),
        label: const Text(
          'PLAY KNOWLEDGE ARCADE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _tabs() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ShopCategory.values.map((category) {
          final selected = category == _category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _categoryIcon(category),
                    size: 17,
                    color: selected
                        ? Colors.white
                        : GameTheme.muted,
                  ),
                  const SizedBox(width: 6),
                  Text(_categoryTitle(category)),
                ],
              ),
              onSelected: (_) {
                setState(() => _category = category);
              },
              backgroundColor: GameTheme.panel,
              selectedColor: GameTheme.purple,
              side: const BorderSide(
                color: GameTheme.border,
              ),
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : GameTheme.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _itemCard(BrainShopItem item) {
    final owned = _owned(item);
    final equipped =
        item.kind == ShopKind.badge &&
        _equipped == item.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _busy ? null : () => _inspect(item),
        borderRadius: BorderRadius.circular(19),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: GameTheme.card(
            accent: item.color,
            radius: 19,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  Icon(
                    equipped
                        ? Icons.verified_rounded
                        : owned
                            ? Icons.check_circle_rounded
                            : Icons.lock_outline_rounded,
                    color: owned
                        ? GameTheme.green
                        : GameTheme.muted,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                width: 70,
                height: 70,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  color: item.color.withOpacity(0.15),
                  border: Border.all(
                    color: item.color.withOpacity(0.7),
                  ),
                ),
                child: Icon(
                  item.icon,
                  size: 40,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                item.title,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 7),
              Expanded(
                child: Text(
                  item.description,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GameTheme.muted,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  equipped
                      ? 'EQUIPPED'
                      : owned
                          ? 'OWNED'
                          : '🪙 ${item.price}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: owned
                        ? GameTheme.green
                        : item.color,
                    fontSize: 12,
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

  Widget _itemGrid() {
    final items =
        BrainShopCatalog.inCategory(_category);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 252,
        crossAxisSpacing: 11,
        mainAxisSpacing: 11,
      ),
      itemBuilder: (context, index) =>
          _itemCard(items[index]),
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
                    padding: const EdgeInsets.fromLTRB(
                      14, 10, 14, 28,
                    ),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  GameTheme.panel,
                            ),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Brain Shop',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.storefront_rounded,
                            color: GameTheme.gold,
                            size: 28,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _walletHeader(),
                      const SizedBox(height: 14),
                      _playArcadeButton(),
                      const SizedBox(height: 17),
                      _tabs(),
                      const SizedBox(height: 14),
                      Text(
                        _categoryTitle(_category),
                        style: const TextStyle(
                          color: GameTheme.gold,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Tap an item to inspect or purchase it.',
                        style: TextStyle(
                          color: GameTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _itemGrid(),
                      const SizedBox(height: 19),
                      const Text(
                        'Earn Brain Coins through Daily Missions '
                        'and the Seven-Day Reward Calendar. '
                        'Use Arcade Passes to play locked games.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: GameTheme.muted,
                          fontSize: 11,
                          height: 1.5,
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
