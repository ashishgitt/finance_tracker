import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/transaction_model.dart';
import '../../widgets/transaction_card.dart';
import '../transactions/add_transaction_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  List<TransactionModel> _results = [];
  bool _searched = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() { _results = []; _searched = false; });
      return;
    }
    final provider = context.read<TransactionProvider>();
    final results = await provider.search(query.trim());
    setState(() { _results = results; _searched = true; });
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();
    final currency = context.watch<SettingsProvider>().currency;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by note, amount...',
            border: InputBorder.none,
            filled: false,
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      _search('');
                    },
                  )
                : null,
          ),
          onChanged: _search,
          onSubmitted: _search,
        ),
      ),
      body: !_searched
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Text('Search your transactions',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Try searching by note, amount or category',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.outlineVariant)),
                ],
              ),
            )
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 64, color: cs.outlineVariant),
                      const SizedBox(height: 12),
                      Text('No results for "${_searchCtrl.text}"',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          Text('${_results.length} result${_results.length > 1 ? 's' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _results.length,
                        itemBuilder: (ctx, i) {
                          final t = _results[i];
                          return TransactionCard(
                            transaction: t,
                            category: catProvider.findById(t.categoryId),
                            currency: currency,
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        AddTransactionScreen(existing: t))),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
