import 'dart:math';
import 'package:flutter/material.dart';
import '../../../shared/app_colors.dart';
import '../../../models/formatters.dart';
import '../../../localization/app_language.dart';
import '../../../localization/app_translations.dart';

/// Shows a professional, luxury-styled booking date range picker dialog.
/// Matches high-end automotive and car rental platforms (Turo, Hertz, Porsche Drive).
Future<DateTimeRange?> showProfessionalBookingDatePicker({
  required BuildContext context,
  required DateTime initialStart,
  required DateTime initialEnd,
  DateTime? firstDate,
  DateTime? lastDate,
  AppLanguage language = AppLanguage.english,
}) async {
  return showDialog<DateTimeRange>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => ProfessionalBookingDateDialog(
      initialStart: initialStart,
      initialEnd: initialEnd,
      firstDate: firstDate,
      lastDate: lastDate,
      language: language,
    ),
  );
}

class ProfessionalBookingDateDialog extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final AppLanguage language;

  const ProfessionalBookingDateDialog({
    super.key,
    required this.initialStart,
    required this.initialEnd,
    this.firstDate,
    this.lastDate,
    this.language = AppLanguage.english,
  });

  @override
  State<ProfessionalBookingDateDialog> createState() => _ProfessionalBookingDateDialogState();
}

class _ProfessionalBookingDateDialogState extends State<ProfessionalBookingDateDialog> {
  late DateTime _startDate;
  DateTime? _endDate;
  late DateTime _firstDate;
  late DateTime _lastDate;
  late DateTime _viewMonth;

  static const List<String> _enMonthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> _kmMonthNames = [
    'មករា', 'កុម្ភៈ', 'មីនា', 'មេសា', 'ឧសភា', 'មិថុនា',
    'កក្កដា', 'សីហា', 'កញ្ញា', 'តុលា', 'វិច្ឆិកា', 'ធ្នូ'
  ];

  List<String> get _monthNames => widget.language == AppLanguage.khmer ? _kmMonthNames : _enMonthNames;

  static const List<String> _enWeekdays = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
  static const List<String> _kmWeekdays = ['អា', 'ច', 'អ', 'ព', 'ព្រ', 'សុ', 'ស'];

  List<String> get _weekdays => widget.language == AppLanguage.khmer ? _kmWeekdays : _enWeekdays;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = _stripTime(now);

    _firstDate = widget.firstDate != null ? _stripTime(widget.firstDate!) : today;
    _lastDate = widget.lastDate != null ? _stripTime(widget.lastDate!) : DateTime(now.year + 3, 12, 31);

    final start = _stripTime(widget.initialStart);
    _startDate = start.isBefore(_firstDate) ? _firstDate : start;

    final end = _stripTime(widget.initialEnd);
    _endDate = end.isBefore(_startDate) ? _startDate.add(const Duration(days: 2)) : end;

    _viewMonth = DateTime(_startDate.year, _startDate.month, 1);
  }

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int get _selectedDays {
    if (_endDate == null) return 1;
    final diff = _endDate!.difference(_startDate).inDays + 1;
    return diff > 0 ? diff : 1;
  }

  void _onDayTapped(DateTime day) {
    if (day.isBefore(_firstDate) || day.isAfter(_lastDate)) return;

    setState(() {
      if (_endDate != null) {
        // Start fresh selection
        _startDate = day;
        _endDate = null;
      } else {
        // We already have a start date, now picking end date
        if (day.isBefore(_startDate)) {
          // If clicked before start date, treat clicked as new start date
          _startDate = day;
          _endDate = null;
        } else {
          _endDate = day;
        }
      }
    });
  }

  void _applyPreset(int days) {
    final now = DateTime.now();
    final today = _stripTime(now);
    setState(() {
      _startDate = today;
      _endDate = today.add(Duration(days: days - 1));
      _viewMonth = DateTime(_startDate.year, _startDate.month, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 1);
    });
  }

  String _t(String key) => AppTranslations.tr(key, widget.language);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isDualMonth = screenSize.width >= 800;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDualMonth ? 860 : 480,
            maxHeight: min(screenSize.height - 32, isDualMonth ? 720 : 860),
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(45),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. DIALOG HEADER WITH BADGE & CLOSE
                    _buildHeader(),

                const Divider(color: Color(0xFFE2E8F0), height: 1),

                // 2. TIMELINE CARDS & DURATION SUMMARY
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Column(
                    children: [
                      _buildTimelineCards(isDualMonth),
                      const SizedBox(height: 12),
                      _buildPresetsBar(),
                    ],
                  ),
                ),

                const Divider(color: Color(0xFFF1F5F9), height: 1),

                // 3. CALENDAR SECTION (DUAL MONTH OR SINGLE MONTH)
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      children: [
                        if (_endDate == null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _t('pickup_selected_msg'),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E40AF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (isDualMonth)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildMonthCalendar(
                                  _viewMonth,
                                  showPrev: true,
                                  showNext: false,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildMonthCalendar(
                                  DateTime(_viewMonth.year, _viewMonth.month + 1, 1),
                                  showPrev: false,
                                  showNext: true,
                                ),
                              ),
                            ],
                          )
                        else
                          _buildMonthCalendar(
                            _viewMonth,
                            showPrev: true,
                            showNext: true,
                          ),
                      ],
                    ),
                  ),
                ),

                const Divider(color: Color(0xFFE2E8F0), height: 1),

                // 4. ACTION FOOTER
                _buildActionFooter(),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
}

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 16, 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brandRed.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: AppColors.brandRed, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _t('rental_period_schedule'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _t('flexible_cancellation'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF065F46),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _t('date_picker_sub'),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              padding: const EdgeInsets.all(8),
            ),
            icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF475569)),
            tooltip: _t('close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TIMELINE CARDS
  // ---------------------------------------------------------------------------
  Widget _buildTimelineCards(bool isDesktop) {
    final effectiveEnd = _endDate ?? _startDate;
    final isPickingEnd = _endDate == null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // PICKUP DATE CARD
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Icon(Icons.key_rounded, size: 20, color: AppColors.brandRed),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('pickup_date_upper'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate(_startDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // DURATION BADGE / ARROW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPickingEnd ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPickingEnd ? const Color(0xFFFCD34D) : const Color(0xFF6EE7B7),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPickingEnd ? Icons.touch_app_rounded : Icons.check_circle_rounded,
                    size: 14,
                    color: isPickingEnd ? const Color(0xFFB45309) : const Color(0xFF047857),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPickingEnd ? _t('pick_return') : '$_selectedDays ${_t('days_rental')}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isPickingEnd ? const Color(0xFF92400E) : const Color(0xFF065F46),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // RETURN DATE CARD
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Icon(Icons.assignment_turned_in_rounded, size: 20, color: Color(0xFF10B981)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('return_date_upper'),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isPickingEnd ? _t('select_return_date') : formattedDate(effectiveEnd),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isPickingEnd ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PRESETS BAR
  // ---------------------------------------------------------------------------
  Widget _buildPresetsBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(
            _t('quick_duration'),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 10),
          _presetChip(_t('preset_3_days'), 3),
          const SizedBox(width: 6),
          _presetChip(_t('preset_7_days'), 7),
          const SizedBox(width: 6),
          _presetChip(_t('preset_14_days'), 14),
          const SizedBox(width: 6),
          _presetChip(_t('preset_30_days'), 30),
        ],
      ),
    );
  }

  Widget _presetChip(String label, int days) {
    final isSelected = _endDate != null && _selectedDays == days;

    return InkWell(
      onTap: () => _applyPreset(days),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MONTH CALENDAR GRID
  // ---------------------------------------------------------------------------
  Widget _buildMonthCalendar(DateTime monthDate, {required bool showPrev, required bool showNext}) {
    final monthName = _monthNames[monthDate.month - 1];
    final year = monthDate.year;

    final firstDayOfMonth = DateTime(monthDate.year, monthDate.month, 1);
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    return Column(
      children: [
        // Month Title with Navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showPrev)
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.all(6),
                  minimumSize: const Size(32, 32),
                ),
                icon: const Icon(Icons.chevron_left_rounded, size: 20, color: Color(0xFF0F172A)),
                onPressed: _prevMonth,
                tooltip: 'Previous Month',
              )
            else
              const SizedBox(width: 32),
            Text(
              '$monthName $year',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            if (showNext)
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.all(6),
                  minimumSize: const Size(32, 32),
                ),
                icon: const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF0F172A)),
                onPressed: _nextMonth,
                tooltip: 'Next Month',
              )
            else
              const SizedBox(width: 32),
          ],
        ),

        const SizedBox(height: 10),

        // Day of Week Header
        Row(
          children: [
            for (final d in _weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: (d == 'SU' || d == 'SA') ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 6),

        // Days Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 0,
            childAspectRatio: 1.15,
          ),
          itemCount: startWeekday + daysInMonth,
          itemBuilder: (ctx, index) {
            if (index < startWeekday) {
              return const SizedBox.shrink();
            }

            final dayNumber = index - startWeekday + 1;
            final cellDate = DateTime(monthDate.year, monthDate.month, dayNumber);
            final isDisabled = cellDate.isBefore(_firstDate) || cellDate.isAfter(_lastDate);

            final isStart = _isSameDay(cellDate, _startDate);
            final isEnd = _endDate != null && _isSameDay(cellDate, _endDate);
            final isInRange = _endDate != null && cellDate.isAfter(_startDate) && cellDate.isBefore(_endDate!);

            return InkWell(
              onTap: isDisabled ? null : () => _onDayTapped(cellDate),
              borderRadius: BorderRadius.circular(isStart || isEnd ? 20 : 0),
              child: Container(
                decoration: BoxDecoration(
                  color: isStart || isEnd
                      ? AppColors.brandRed
                      : (isInRange ? const Color(0xFFFEE2E2) : Colors.transparent),
                  borderRadius: isStart && _endDate != null
                      ? const BorderRadius.horizontal(left: Radius.circular(20))
                      : (isEnd
                          ? const BorderRadius.horizontal(right: Radius.circular(20))
                          : (isStart
                              ? BorderRadius.circular(20)
                              : BorderRadius.zero)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isStart || isEnd || isInRange ? FontWeight.w900 : FontWeight.w600,
                    color: isDisabled
                        ? const Color(0xFFCBD5E1)
                        : (isStart || isEnd
                            ? Colors.white
                            : (isInRange ? const Color(0xFF991B1B) : const Color(0xFF1E293B))),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // ACTION FOOTER
  // ---------------------------------------------------------------------------
  Widget _buildActionFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: const Color(0xFFF8FAFC),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;
          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        final now = DateTime.now();
                        final today = _stripTime(now);
                        setState(() {
                          _startDate = today;
                          _endDate = today.add(const Duration(days: 2));
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF64748B)),
                      label: Text(
                        _t('reset_dates'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF334155),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(_t('cancel'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: () {
                    final effectiveEnd = _endDate ?? _startDate.add(const Duration(days: 1));
                    Navigator.of(context).pop(DateTimeRange(start: _startDate, end: effectiveEnd));
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(
                    '${_t('confirm_booking')} ($_selectedDays d)',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  final now = DateTime.now();
                  final today = _stripTime(now);
                  setState(() {
                    _startDate = today;
                    _endDate = today.add(const Duration(days: 2));
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF64748B)),
                label: Text(
                  _t('reset_dates'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
              ),
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_t('cancel'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: () {
                  final effectiveEnd = _endDate ?? _startDate.add(const Duration(days: 1));
                  Navigator.of(context).pop(DateTimeRange(start: _startDate, end: effectiveEnd));
                },
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: Text(
                  '${_t('confirm_booking')} ($_selectedDays d)',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
