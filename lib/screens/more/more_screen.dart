import 'package:flutter/material.dart';
import '../savings/savings_screen.dart';
import '../debts/debts_screen.dart';
import '../ai_tips/ai_tips_screen.dart';
import '../calendar/calendar_view_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../categories/categories_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      _MoreItem('Savings Goals', Icons.savings_outlined, cs.primary,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsScreen()))),
      _MoreItem('Debt Tracker', Icons.handshake_outlined, Colors.orange,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DebtsScreen()))),
      _MoreItem('AI Financial Tips', Icons.lightbulb_outline, Colors.amber,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiTipsScreen()))),
      _MoreItem('Calendar View', Icons.calendar_month_outlined, Colors.teal,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarViewScreen()))),
      _MoreItem('Search', Icons.search, Colors.indigo,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
      _MoreItem('Categories', Icons.category_outlined, Colors.green,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()))),
      _MoreItem('Settings', Icons.settings_outlined, Colors.grey,
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final item = items[i];
          return Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              title: Text(item.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right),
              onTap: item.onTap,
            ),
          );
        },
      ),
    );
  }
}

class _MoreItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MoreItem(this.title, this.icon, this.color, this.onTap);
}
