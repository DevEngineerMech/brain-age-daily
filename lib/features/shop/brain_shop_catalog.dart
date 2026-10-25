
import 'package:flutter/material.dart';

import '../../core/constants/game_ids.dart';

enum ShopCategory {
  arcade,
  powerUps,
  customisation,
  specials,
}

enum ShopKind {
  gameUnlock,
  passes,
  missionBoost,
  badge,
  mystery,
}

class BrainShopItem {
  final String id;
  final String title;
  final String description;
  final int price;
  final int quantity;
  final ShopCategory category;
  final ShopKind kind;
  final IconData icon;
  final Color color;
  final String? gameId;

  const BrainShopItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.kind,
    required this.icon,
    required this.color,
    this.quantity = 1,
    this.gameId,
  });
}

class BrainShopCatalog {
  BrainShopCatalog._();

  static const int singleArcadeEntryPrice = 20;

  static const List<BrainShopItem> items = [
    // ARCADE — PERMANENT GAME UNLOCKS
    BrainShopItem(
      id: 'unlock_biology',
      title: 'Biology Quiz',
      description: 'Unlock Biology Quiz permanently.',
      price: 280,
      category: ShopCategory.arcade,
      kind: ShopKind.gameUnlock,
      icon: Icons.biotech_rounded,
      color: Color(0xFF4BE09D),
      gameId: GameIds.biologyQuiz,
    ),
    BrainShopItem(
      id: 'unlock_science',
      title: 'Science Quiz',
      description: 'Unlock Science Quiz permanently.',
      price: 280,
      category: ShopCategory.arcade,
      kind: ShopKind.gameUnlock,
      icon: Icons.science_rounded,
      color: Color(0xFF42D9D0),
      gameId: GameIds.scienceQuiz,
    ),
    BrainShopItem(
      id: 'unlock_antonyms',
      title: 'Antonyms',
      description: 'Unlimited access to the opposites game.',
      price: 220,
      category: ShopCategory.arcade,
      kind: ShopKind.gameUnlock,
      icon: Icons.compare_arrows_rounded,
      color: Color(0xFFFFC75D),
      gameId: GameIds.antonyms,
    ),
    BrainShopItem(
      id: 'unlock_word_snap',
      title: 'Word Snap',
      description: 'Unlock word categories permanently.',
      price: 240,
      category: ShopCategory.arcade,
      kind: ShopKind.gameUnlock,
      icon: Icons.category_rounded,
      color: Color(0xFFBE88FF),
      gameId: GameIds.wordSnap,
    ),
    BrainShopItem(
      id: 'unlock_word_scramble',
      title: 'Word Scramble',
      description: 'Unlimited word scrambling challenges.',
      price: 240,
      category: ShopCategory.arcade,
      kind: ShopKind.gameUnlock,
      icon: Icons.shuffle_rounded,
      color: Color(0xFFFF81BE),
      gameId: GameIds.wordScramble,
    ),

    // POWER-UPS
    BrainShopItem(
      id: 'three_passes',
      title: '3 Arcade Passes',
      description: 'Play any locked Arcade game three times.',
      price: 50,
      quantity: 3,
      category: ShopCategory.powerUps,
      kind: ShopKind.passes,
      icon: Icons.confirmation_number_rounded,
      color: Color(0xFF42D9D0),
    ),
    BrainShopItem(
      id: 'mission_double',
      title: 'Mission Coin Doubler',
      description: 'Double the coins from your next claimed '
          'daily mission. Does not double the completion bonus.',
      price: 70,
      category: ShopCategory.powerUps,
      kind: ShopKind.missionBoost,
      icon: Icons.bolt_rounded,
      color: Color(0xFFFFC75D),
    ),

    // CUSTOMISATION
    BrainShopItem(
      id: 'badge_star',
      title: 'Golden Star',
      description: 'A golden badge for your player identity.',
      price: 90,
      category: ShopCategory.customisation,
      kind: ShopKind.badge,
      icon: Icons.star_rounded,
      color: Color(0xFFFFC75D),
    ),
    BrainShopItem(
      id: 'badge_brain',
      title: 'Brain Master',
      description: 'Show off your brain-training dedication.',
      price: 120,
      category: ShopCategory.customisation,
      kind: ShopKind.badge,
      icon: Icons.psychology_rounded,
      color: Color(0xFFAA80FF),
    ),
    BrainShopItem(
      id: 'badge_lightning',
      title: 'Lightning Mind',
      description: 'A badge for quick-thinking players.',
      price: 110,
      category: ShopCategory.customisation,
      kind: ShopKind.badge,
      icon: Icons.flash_on_rounded,
      color: Color(0xFF42D9D0),
    ),
    BrainShopItem(
      id: 'badge_crown',
      title: 'Royal Thinker',
      description: 'A premium purple-and-gold identity badge.',
      price: 180,
      category: ShopCategory.customisation,
      kind: ShopKind.badge,
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFFFC75D),
    ),

    // SPECIALS
    BrainShopItem(
      id: 'ten_passes',
      title: '10 Arcade Passes',
      description: 'A discounted bundle of ten entries.',
      price: 140,
      quantity: 10,
      category: ShopCategory.specials,
      kind: ShopKind.passes,
      icon: Icons.local_activity_rounded,
      color: Color(0xFF4BE09D),
    ),
    BrainShopItem(
      id: 'mystery_chest',
      title: 'Mystery Chest',
      description: 'Receive 2–6 Arcade Passes. '
          'The result is revealed after purchasing.',
      price: 55,
      category: ShopCategory.specials,
      kind: ShopKind.mystery,
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFFF81BE),
    ),
  ];

  static BrainShopItem? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static BrainShopItem? gameUnlock(String gameId) {
    for (final item in items) {
      if (item.kind == ShopKind.gameUnlock &&
          item.gameId == gameId) {
        return item;
      }
    }
    return null;
  }

  static List<BrainShopItem> inCategory(
    ShopCategory category,
  ) {
    return items
        .where((item) => item.category == category)
        .toList();
  }

  static BrainShopItem? badge(String id) {
    final item = find(id);
    return item?.kind == ShopKind.badge ? item : null;
  }
}
