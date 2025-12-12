import 'package:flutter/material.dart';
import '../shop_page.dart';
import 'utils.dart';
class ShopTab extends StatefulWidget {
  final int coins;
  final void Function(int) onCoinsChanged;
  final void Function(String) onEquipBackground;

  const ShopTab({
    required this.coins,
    required this.onCoinsChanged,
    required this.onEquipBackground,
    super.key,
  });

  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  String equippedBackgroundUrl = '';

  void updateCoins(int newCoins) {
    widget.onCoinsChanged(newCoins);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ShopPage(
      coins: widget.coins,
      onCoinsChanged: updateCoins,
      onEquipBackground: (url) {
        if (url != null) {
          setState(() => equippedBackgroundUrl = url);
          widget.onEquipBackground(url);
        }
      },
    );
  }
}
