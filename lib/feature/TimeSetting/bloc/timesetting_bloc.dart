import 'dart:async';
import 'dart:convert';
import 'package:application/core/routes/routes.dart';
import 'package:application/feature/TimeSetting/bloc/timesetting_event.dart';
import 'package:application/feature/TimeSetting/bloc/timesetting_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class TimeFormBloc extends Bloc<TimeFormEvent, TimeFormState> {
  TimeOfDay morningStartTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay morningEndTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay afternoonStartTime = TimeOfDay(hour: 13, minute: 0);
  TimeOfDay afternoonEndTime = TimeOfDay(hour: 13, minute: 30);
  TimeOfDay eveningStartTime = TimeOfDay(hour: 16, minute: 0);
  TimeOfDay eveningEndTime = TimeOfDay(hour: 16, minute: 30);
  String? userId; // Added userId to the bloc
  String? authToken; // Token for authorization

  TimeFormBloc() : super(TimeFormInitial()) {
    _loadUserCredentials();

    // Morning Events
    on<SetMorningStartTimeEvent>((event, emit) {
      morningStartTime = event.startTime;
      emit(_buildTimeFormState());
    });

    on<SetMorningEndTimeEvent>((event, emit) {
      morningEndTime = event.endTime;
      emit(_buildTimeFormState());
    });

    // Afternoon Events
    on<SetAfternoonStartTimeEvent>((event, emit) {
      afternoonStartTime = event.startTime;
      emit(_buildTimeFormState());
    });

    on<SetAfternoonEndTimeEvent>((event, emit) {
      afternoonEndTime = event.endTime;
      emit(_buildTimeFormState());
    });

    // Evening Events
    on<SetEveningStartTimeEvent>((event, emit) {
      eveningStartTime = event.startTime;
      emit(_buildTimeFormState());
    });

    on<SetEveningEndTimeEvent>((event, emit) {
      eveningEndTime = event.endTime;
      emit(_buildTimeFormState());
    });

    // Submit Event with HTTP request
    on<SubmitTimesEvent>((event, emit) async {
      if (_allTimeRangesSet()) {
        emit(TimeFormSubmitting());

        try {
          var response = await _submitTimeRangesToServer();

          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");

          if (response.statusCode == 200) {
            var responseData = jsonDecode(response.body);
            emit(TimeFormSubmitted(
                message:
                    "Times submitted successfully! Response: ${responseData['message']}"));
          } else {
            var errorResponse = jsonDecode(response.body);
            emit(TimeFormError(
                error: errorResponse['message'] ?? "Failed to submit times."));
          }
        } catch (e) {
          emit(TimeFormError(
              error: "Failed to submit times. Please try again."));
        }
      } else {
        emit(TimeFormError(error: "Please fill all the time ranges."));
      }
    });
  }

  // Helper method to load user ID and token from Hive
  Future<void> _loadUserCredentials() async {
    try {
      var box = await Hive.openBox('authtoken');
      userId = box.get('user_id');
      authToken = box.get('token'); // Load the token for authentication
      await box.close();

      if (userId == null || authToken == null) {
        addError("User ID or token not found in local storage.");
      }
    } catch (e) {
      addError("Failed to load user credentials: $e");
    }
  }

  // Helper method to build the current form state
  TimeFormStateWithInput _buildTimeFormState() {
    return TimeFormStateWithInput(
      morningStartTime: morningStartTime,
      morningEndTime: morningEndTime,
      afternoonStartTime: afternoonStartTime,
      afternoonEndTime: afternoonEndTime,
      eveningStartTime: eveningStartTime,
      eveningEndTime: eveningEndTime,
    );
  }

  // Helper method to check if all time ranges are set
  bool _allTimeRangesSet() {
    return morningStartTime != null &&
        morningEndTime != null &&
        afternoonStartTime != null &&
        afternoonEndTime != null &&
        eveningStartTime != null &&
        eveningEndTime != null;
  }

  // Method to submit the time ranges to the server
  Future<http.Response> _submitTimeRangesToServer() async {
    if (authToken == null || userId == null) {
      throw Exception("Missing authorization token or user ID");
    }

    // Create a JSON object with the time data
    Map<String, dynamic> timeData = {
      "user_id": userId,
      "ms": _formatTimeWithDate(morningStartTime),
      "me": _formatTimeWithDate(morningEndTime),
      "as": _formatTimeWithDate(afternoonStartTime),
      "ae": _formatTimeWithDate(afternoonEndTime),
      "es": _formatTimeWithDate(eveningStartTime),
      "ee": _formatTimeWithDate(eveningEndTime),
    };

    // Replace with your actual API endpoint
    var url = Uri.parse(HttpRoutes.setTime);

    // Make the HTTP POST request
    var response = await http.post(
      url,
      body: jsonEncode(timeData),
    );

    return response;
  }

  // Helper method to format TimeOfDay to a string with the current date (e.g., "2024-09-28 08:30")
  String _formatTimeWithDate(TimeOfDay time) {
    // Helper method to format TimeOfDay to a string (e.g., "08:30:00")

    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    // Add seconds as "00" for consistency
    return "$hours:$minutes:00";
  }
}
