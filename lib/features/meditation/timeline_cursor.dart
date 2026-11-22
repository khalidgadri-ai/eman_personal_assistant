import 'session_planner.dart';

/// حدث في الخط الزمني، يُنفَّذ مرة واحدة حين يصل إليه الوقت.
sealed class TimelineEvent {
  const TimelineEvent(this.atSec);
  final int atSec;
}

class BellEvent extends TimelineEvent {
  const BellEvent(super.atSec);
}

class CueEvent extends TimelineEvent {
  CueEvent(this.cue) : super(cue.atSec);
  final PlannedCue cue;
}

class PhaseStartEvent extends TimelineEvent {
  PhaseStartEvent(this.phase) : super(phase.startSec);
  final PlannedPhase phase;
}

class SessionEndEvent extends TimelineEvent {
  const SessionEndEvent(super.atSec);
}

/// يمشي على الخط الزمني: كل نداء يرجّع الأحداث التي حان وقتها ولم تُرجَع من قبل، بالترتيب.
/// الوقت يأتي من موضع تشغيل الصوت، لا من مؤقت، فلا تتأخر الأجراس والشاشة مطفأة.
class TimelineCursor {
  TimelineCursor(this.plan) : _events = _build(plan);

  final SessionPlan plan;
  final List<TimelineEvent> _events;
  int _next = 0;

  bool get finished => _next >= _events.length;

  static List<TimelineEvent> _build(SessionPlan plan) {
    final events = <TimelineEvent>[
      for (final phase in plan.phases) PhaseStartEvent(phase),
      for (final bell in plan.bells) BellEvent(bell),
      for (final cue in plan.cues) CueEvent(cue),
      SessionEndEvent(plan.totalSec),
    ];
    // في الثانية نفسها: بداية المرحلة، ثم الجرس، ثم صوت المرشد، والنهاية آخرًا.
    int rank(TimelineEvent e) => switch (e) {
          PhaseStartEvent() => 0,
          BellEvent() => 1,
          CueEvent() => 2,
          SessionEndEvent() => 3,
        };
    events.sort((a, b) {
      final byTime = a.atSec.compareTo(b.atSec);
      return byTime != 0 ? byTime : rank(a).compareTo(rank(b));
    });
    return events;
  }

  List<TimelineEvent> advanceTo(double elapsedSec) {
    final due = <TimelineEvent>[];
    while (_next < _events.length && _events[_next].atSec <= elapsedSec) {
      due.add(_events[_next++]);
    }
    return due;
  }
}
