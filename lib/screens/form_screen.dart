import 'package:flutter/material.dart';

import '../models/discipline.dart';
import '../models/tournament.dart';
import '../routes.dart';
import '../utils/format.dart';

/// New and edit in one screen; answers with the saved tournament via pop.
class FormScreen extends StatefulWidget {
  const FormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

typedef _Snapshot = ({
  String title,
  String venue,
  String slots,
  String description,
  Discipline? discipline,
  bool online,
  DateTime? date,
  TimeOfDay? time,
});

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Tournament _base = widget.args.item ?? Tournament.empty();
  bool get _isNew => widget.args.item == null;

  late final _title = TextEditingController(text: _base.title);
  late final _venue = TextEditingController(text: _base.venue);
  late final _slots = TextEditingController(text: '${_base.slots}');
  late final _description = TextEditingController(
    text: _base.description ?? '',
  );
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();

  final _titleFocus = FocusNode();
  final _venueFocus = FocusNode();
  final _slotsFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  late Discipline? _discipline = _isNew ? null : _base.discipline;
  late bool _online = _base.online;
  late DateTime? _date = _isNew ? null : _base.startsAt;
  late TimeOfDay? _time = _isNew
      ? null
      : TimeOfDay.fromDateTime(_base.startsAt);
  bool _saving = false;

  /// What the form held when it opened; compared against to know if dirty.
  late final _Snapshot _initial;

  @override
  void initState() {
    super.initState();
    _showDate();
    _showTime();
    _initial = _snapshot;
  }

  @override
  void dispose() {
    for (final c in [
      _title, _venue, _slots, _description, _dateText, _timeText, //
    ]) {
      c.dispose();
    }
    for (final f in [
      _titleFocus,
      _venueFocus,
      _slotsFocus,
      _descriptionFocus,
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  _Snapshot get _snapshot => (
    title: _title.text,
    venue: _venue.text,
    slots: _slots.text,
    description: _description.text,
    discipline: _discipline,
    online: _online,
    date: _date,
    time: _time,
  );

  bool get _dirty => _snapshot != _initial;

  DateTime? get _startsAt => switch ((_date, _time)) {
    (final d?, final t?) => DateTime(d.year, d.month, d.day, t.hour, t.minute),
    _ => null,
  };

  void _showDate() => _dateText.text = switch (_date) {
    final d? => formatDate(d),
    null => '',
  };

  void _showTime() => _timeText.text = switch (_time) {
    final t? => formatTime(t.hour, t.minute),
    null => '',
  };

  // ---- validators -------------------------------------------------------

  String? _validateTitle(String? value) {
    final length = value?.trim().length ?? 0;
    if (length < 3) return 'At least 3 characters';
    if (length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validateVenue(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return _online ? 'A stream link is required' : 'Required';
    if (_online && !v.contains('://')) return 'A link must contain ://';
    return null;
  }

  String? _validateSlots(String? value) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null) return 'Enter a whole number';
    if (n < 1 || n > 500) return 'From 1 to 500';
    if (n < _base.count) return '${_base.count} players have already joined';
    return null;
  }

  String? _validateDiscipline(Discipline? value) =>
      value == null ? 'Pick a discipline' : null;

  String? _validateDate(String? _) {
    if (_date == null) return 'Pick a date';
    final start = _startsAt;
    if (_isNew && start != null && !start.isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  String? _validateTime(String? _) => _time == null ? 'Pick a time' : null;

  // ---- pickers ----------------------------------------------------------

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: _isNew
          ? DateTime(now.year, now.month, now.day)
          : DateTime(2020),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null || !mounted) return; // Cancel keeps the old value
    setState(() => _date = picked);
    _showDate();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked == null || !mounted) return; // Cancel keeps the old value
    setState(() => _time = picked);
    _showTime();
  }

  // ---- save -------------------------------------------------------------

  Tournament _result() {
    final description = _description.text.trim();
    return _base.copyWith(
      title: _title.text.trim(),
      discipline: _discipline,
      startsAt: _startsAt,
      slots: int.tryParse(_slots.text.trim()),
      venue: _venue.text.trim(),
      online: _online,
      description: () => description.isEmpty ? null : description,
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.of(context).pop(_result());
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  static void _unfocus(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? 'New tournament' : 'Edit tournament'),
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: _validateTitle,
                onTapOutside: _unfocus,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Discipline>(
                initialValue: _discipline,
                decoration: const InputDecoration(
                  labelText: 'Discipline',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final d in Discipline.values)
                    DropdownMenuItem(
                      value: d,
                      child: Row(
                        children: [
                          Icon(d.icon),
                          const SizedBox(width: 12),
                          Text(d.label),
                        ],
                      ),
                    ),
                ],
                onChanged: (d) => setState(() => _discipline = d),
                validator: _validateDiscipline,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: _online,
                onChanged: (v) => setState(() => _online = v ?? false),
                title: const Text('Online'),
                subtitle: const Text('The venue becomes a stream link'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _venue,
                focusNode: _venueFocus,
                decoration: InputDecoration(
                  labelText: _online ? 'Stream link' : 'Venue',
                  hintText: _online ? 'https://twitch.tv/…' : null,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: _online ? TextInputType.url : TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: _validateVenue,
                onTapOutside: _unfocus,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateText,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _timeText,
                      readOnly: true,
                      onTap: _pickTime,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        suffixIcon: Icon(Icons.schedule),
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slots,
                focusNode: _slotsFocus,
                decoration: const InputDecoration(
                  labelText: 'Slots',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: _validateSlots,
                onTapOutside: _unfocus,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                focusNode: _descriptionFocus,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onTapOutside: _unfocus,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
