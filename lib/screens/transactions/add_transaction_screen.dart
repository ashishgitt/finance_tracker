import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/transaction_model.dart';
import '../../models/models.dart';
import '../../core/constants/app_constants.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existing;
  const AddTransactionScreen({super.key, this.existing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _type = 'expense';
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _paymentMode = 'Cash';
  bool _isRecurring = false;
  String _recurrenceType = 'Monthly';
  String? _receiptPath;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.existing!;
      _amountCtrl.text = t.amount.toString();
      _noteCtrl.text = t.note ?? '';
      _type = t.type;
      _selectedCategoryId = t.categoryId;
      _selectedDate = DateTime.tryParse(t.date) ?? DateTime.now();
      _paymentMode = t.paymentMode;
      _isRecurring = t.isRecurring;
      _recurrenceType = t.recurrenceType ?? 'Monthly';
      _receiptPath = t.receiptImage;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickReceipt() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img != null) setState(() => _receiptPath = img.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')));
      return;
    }
    final amount = double.parse(_amountCtrl.text.trim());
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    final txn = TransactionModel(
      id: _isEditing ? widget.existing!.id : const Uuid().v4(),
      amount: amount,
      type: _type,
      categoryId: _selectedCategoryId!,
      date: dateStr,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      paymentMode: _paymentMode,
      isRecurring: _isRecurring,
      recurrenceType: _isRecurring ? _recurrenceType : null,
      receiptImage: _receiptPath,
      createdAt: _isEditing
          ? widget.existing!.createdAt
          : DateTime.now().toIso8601String(),
    );

    final provider = context.read<TransactionProvider>();
    if (_isEditing) {
      await provider.updateTransaction(txn);
    } else {
      await provider.addTransaction(txn);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();
    final settings = context.watch<SettingsProvider>();
    final currency = settings.currency;
    final cs = Theme.of(context).colorScheme;

    final cats = _type == 'expense'
        ? catProvider.expenseCategories
        : catProvider.incomeCategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: cs.error),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Transaction'),
                    content: const Text('Are you sure?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true && mounted) {
                  await context
                      .read<TransactionProvider>()
                      .deleteTransaction(widget.existing!.id);
                  Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Type Toggle ───────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'expense',
                        label: Text('Expense'),
                        icon: Icon(Icons.arrow_upward)),
                    ButtonSegment(
                        value: 'income',
                        label: Text('Income'),
                        icon: Icon(Icons.arrow_downward)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) {
                    setState(() {
                      _type = s.first;
                      _selectedCategoryId = null;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ── Amount ────────────────────────────────────────────
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '$currency ',
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Invalid number';
                if (double.parse(v.trim()) <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            // ── Category ──────────────────────────────────────────
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              child: cats.isEmpty
                  ? const Text('No categories')
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategoryId,
                        isExpanded: true,
                        hint: const Text('Select category'),
                        items: cats
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Row(children: [
                                    Text(c.emoji),
                                    const SizedBox(width: 8),
                                    Text(c.name),
                                  ]),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedCategoryId = v),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            // ── Date ──────────────────────────────────────────────
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  suffixIcon: Icon(Icons.chevron_right),
                ),
                child: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
              ),
            ),
            const SizedBox(height: 12),
            // ── Payment Mode ─────────────────────────────────────
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Payment Mode',
                prefixIcon: Icon(Icons.payment_outlined),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _paymentMode,
                  isExpanded: true,
                  items: AppConstants.paymentModes
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _paymentMode = v!),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ── Note ─────────────────────────────────────────────
            TextFormField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note / Description (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 12),
            // ── Recurring ────────────────────────────────────────
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Recurring Transaction'),
                    subtitle: const Text('Repeat this automatically'),
                    secondary: const Icon(Icons.repeat),
                    value: _isRecurring,
                    onChanged: (v) => setState(() => _isRecurring = v),
                  ),
                  if (_isRecurring)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: DropdownButtonFormField<String>(
                        value: _recurrenceType,
                        decoration: const InputDecoration(
                          labelText: 'Repeat',
                          prefixIcon: Icon(Icons.schedule),
                        ),
                        items: AppConstants.recurrenceTypes
                            .map((r) =>
                                DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _recurrenceType = v!),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Receipt ──────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: _pickReceipt,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(_receiptPath != null
                  ? 'Receipt attached ✓'
                  : 'Attach Receipt (optional)'),
            ),
            const SizedBox(height: 24),
            // ── Save ─────────────────────────────────────────────
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Update Transaction' : 'Save Transaction'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
            ),
          ],
        ),
      ),
    );
  }
}
