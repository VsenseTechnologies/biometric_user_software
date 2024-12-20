import 'package:application/feature/TimeSetting/bloc/timesetting_bloc.dart';
import 'package:application/feature/TimeSetting/bloc/timesetting_event.dart';
import 'package:application/feature/TimeSetting/bloc/timesetting_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// Custom ScrollBehavior to hide the scrollbar
class NoScrollBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child; // No scrollbars will be shown
  }
}

class TimeForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimeFormBloc(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          title: Text(
            "Set time",
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 20, // Fixed text size for the title
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.grey.shade900,
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 30,
          ),
        ),
        body: BlocListener<TimeFormBloc, TimeFormState>(
          listener: (context, state) {
            if (state is TimeFormSubmitting) {
              _showDialog(
                context,
                'Submitting...',
                'Please wait while the time settings are being submitted.',
                isLoading: true,
              );
            }

            if (state is TimeFormSubmitted) {
              _showDialog(
                context,
                'Success',
                state.message,
                isError: false,
              );
            }

            if (state is TimeFormError) {
              _showDialog(
                context,
                'Error',
                state.error,
                isError: true,
              );
            }
          },
          child: Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: ScrollConfiguration(
                  behavior:
                      NoScrollBehavior(), // Apply the custom scroll behavior
                  child: SingleChildScrollView(
                    child: Card(
                      elevation: 8,
                      color: Colors.white,
                      margin: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: 400, // Limit the width to 400px for compact UI
                          child: BlocBuilder<TimeFormBloc, TimeFormState>(
                            builder: (context, state) {
                              final bloc =
                                  BlocProvider.of<TimeFormBloc>(context);

                              // Fetching selected times from the state (or defaults)
                              TimeOfDay? morningStartTime =
                                  (state is TimeFormStateWithInput)
                                      ? state.morningStartTime
                                      : TimeOfDay(
                                          hour: 8,
                                          minute: 0); // Default to 8:00 AM

                              TimeOfDay? morningEndTime =
                                  (state is TimeFormStateWithInput)
                                      ? state.morningEndTime
                                      : TimeOfDay(
                                          hour: 9,
                                          minute: 0); // Default to 12:00 PM

                              TimeOfDay? afternoonStartTime =
                                  (state is TimeFormStateWithInput)
                                      ? state.afternoonStartTime
                                      : TimeOfDay(
                                          hour: 13,
                                          minute: 0); // Default to 1:00 PM

                              TimeOfDay? afternoonEndTime =
                                  (state is TimeFormStateWithInput)
                                      ? state.afternoonEndTime
                                      : TimeOfDay(
                                          hour: 13,
                                          minute: 30); // Default to 5:00 PM

                              TimeOfDay? eveningStartTime =
                                  (state is TimeFormStateWithInput)
                                      ? state.eveningStartTime
                                      : TimeOfDay(
                                          hour: 16,
                                          minute: 0); // Default to 6:00 PM

                              TimeOfDay? eveningEndTime =
                                  (state is TimeFormStateWithInput)
                                      ? state.eveningEndTime
                                      : TimeOfDay(
                                          hour: 16,
                                          minute: 30); // Default to 9:00 PM

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // const Icon(
                                  //   Icons.timelapse_sharp,
                                  //   size: 100,
                                  // ),
                                  _buildSectionLabel('Morning Time Range:'),
                                  SizedBox(height: 20),
                                  _buildTimeRangePicker(
                                    context,
                                    label: 'Start Time',
                                    selectedTime: morningStartTime,
                                    onTimeSelected: (time) => bloc.add(
                                        SetMorningStartTimeEvent(
                                            startTime: time)),
                                  ),
                                  SizedBox(height: 20),
                                  _buildTimeRangePicker(
                                    context,
                                    label: 'End Time',
                                    selectedTime: morningEndTime,
                                    onTimeSelected: (time) => bloc.add(
                                        SetMorningEndTimeEvent(endTime: time)),
                                  ),
                                  SizedBox(height: 20),

                                  _buildSectionLabel('Afternoon Time Range:'),
                                  SizedBox(height: 20),
                                  _buildTimeRangePicker(
                                    context,
                                    label: 'Start Time',
                                    selectedTime: afternoonStartTime,
                                    onTimeSelected: (time) => bloc.add(
                                        SetAfternoonStartTimeEvent(
                                            startTime: time)),
                                  ),
                                  SizedBox(height: 20),
                                  _buildTimeRangePicker(
                                    context,
                                    label: 'End Time',
                                    selectedTime: afternoonEndTime,
                                    onTimeSelected: (time) => bloc.add(
                                        SetAfternoonEndTimeEvent(
                                            endTime: time)),
                                  ),
                                  SizedBox(height: 20),

                                  _buildSectionLabel('Evening Time Range:'),
                                  SizedBox(height: 20),
                                  _buildTimeRangePicker(
                                    context,
                                    label: 'Start Time',
                                    selectedTime: eveningStartTime,
                                    onTimeSelected: (time) => bloc.add(
                                        SetEveningStartTimeEvent(
                                            startTime: time)),
                                  ),
                                  SizedBox(height: 20),
                                  _buildTimeRangePicker(
                                    context,
                                    label: 'End Time',
                                    selectedTime: eveningEndTime,
                                    onTimeSelected: (time) => bloc.add(
                                        SetEveningEndTimeEvent(endTime: time)),
                                  ),
                                  SizedBox(height: 40),

                                  // Submit Button
                                  ElevatedButton(
                                    onPressed: () {
                                      if (morningStartTime != null &&
                                          morningEndTime != null &&
                                          afternoonStartTime != null &&
                                          afternoonEndTime != null &&
                                          eveningStartTime != null &&
                                          eveningEndTime != null) {
                                        bloc.add(SubmitTimesEvent());
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  "Please select all time ranges")),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      "Submit ",
                                      style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 20),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for showing the Dialog
  void _showDialog(BuildContext context, String title, String content,
      {bool isLoading = false, bool isError = false}) {
    showDialog(
      context: context,
      barrierDismissible:
          !isLoading, // Allow dismissal only if it's not loading
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                CircularProgressIndicator(), // Show loader if loading
              if (!isLoading) Text(content), // Show message if not loading
            ],
          ),
          actions: [
            if (!isLoading)
              TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Close the dialog on button press
                },
                child: Text('OK'),
              ),
          ],
        );
      },
    ).then((_) {
      // Add any additional cleanup here if necessary
      if (!isLoading) {
        Navigator.of(context).pop(); // Ensure the dialog closes on tap outside
      }
    });
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16, // Set a reasonable size for section labels
      ),
    );
  }

  Widget _buildTimeRangePicker(
    BuildContext context, {
    required String label,
    required TimeOfDay? selectedTime,
    required Function(TimeOfDay) onTimeSelected,
  }) {
    final TextEditingController controller = TextEditingController(
      text: selectedTime != null ? _formatTimeOfDay(selectedTime) : '',
    );

    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
          initialEntryMode: TimePickerEntryMode.input,
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            );
          },
        );
        if (time != null) {
          controller.text = _formatTimeOfDay(time);
          onTimeSelected(time);
        }
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
