import 'package:flutter/material.dart';

abstract class TimeFormEvent {}

// Morning Events
class SetMorningStartTimeEvent extends TimeFormEvent {
  final TimeOfDay startTime;
  SetMorningStartTimeEvent({required this.startTime});
}

class SetMorningEndTimeEvent extends TimeFormEvent {
  final TimeOfDay endTime;
  SetMorningEndTimeEvent({required this.endTime});
}

// Afternoon Events
class SetAfternoonStartTimeEvent extends TimeFormEvent {
  final TimeOfDay startTime;
  SetAfternoonStartTimeEvent({required this.startTime});
}

class SetAfternoonEndTimeEvent extends TimeFormEvent {
  final TimeOfDay endTime;
  SetAfternoonEndTimeEvent({required this.endTime});
}

// Evening Events
class SetEveningStartTimeEvent extends TimeFormEvent {
  final TimeOfDay startTime;
  SetEveningStartTimeEvent({required this.startTime});
}

class SetEveningEndTimeEvent extends TimeFormEvent {
  final TimeOfDay endTime;
  SetEveningEndTimeEvent({required this.endTime});
}

class SubmitTimesEvent extends TimeFormEvent {}
