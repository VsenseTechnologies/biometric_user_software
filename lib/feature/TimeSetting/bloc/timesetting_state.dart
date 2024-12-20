import 'package:flutter/material.dart';

abstract class TimeFormState {}

class TimeFormInitial extends TimeFormState {}

class TimeFormStateWithInput extends TimeFormState {
  final TimeOfDay? morningStartTime;
  final TimeOfDay? morningEndTime;
  final TimeOfDay? afternoonStartTime;
  final TimeOfDay? afternoonEndTime;
  final TimeOfDay? eveningStartTime;
  final TimeOfDay? eveningEndTime;

  TimeFormStateWithInput({
   required this.morningStartTime,
    required this.morningEndTime,
    required this.afternoonStartTime,
    required this.afternoonEndTime,
   required this.eveningStartTime,
   required this.eveningEndTime,
  });
}

class TimeFormSubmitting extends TimeFormState {}

class TimeFormSubmitted extends TimeFormState {
  final String message;

  TimeFormSubmitted({required this.message});
}

class TimeFormError extends TimeFormState {
  final String error;

  TimeFormError({required this.error});
}
