import 'dart:convert';
import 'dart:io';
import 'package:application/core/routes/routes.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

part 'download_event.dart';
part 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  DownloadBloc() : super(DownloadInitial()) {
    // Handle fetching biometric units
    on<FetchBiometricUnitsEvent>((event, emit) async {
      try {
        emit(DownloadLoadingState());
        
        // Open Hive box once and reuse the data
        var box = await Hive.openBox("authtoken");
        var userId = box.get("user_id");
        box.close();

        // Send the API request
        var jsonResponse = await http.post(
          Uri.parse(HttpRoutes.fetchMachines),
          body: jsonEncode({"user_id": userId}),
          headers: {"Content-Type": "application/json"},  // Added header to handle potential issues
        );

        var response = jsonDecode(jsonResponse.body);

        if (jsonResponse.statusCode == 200 && response['data'] != null) {
          List<String> data = (response['data'] as List).map((item) => item['unit_id'] as String).toList();
          emit(FetchBiometricUnitsSuccessState(data: data));
        } else {
          emit(FetchBiometricUnitsFailedState(message: response['message'] ?? "Failed to fetch units."));
        }
      } catch (e) {
        emit(FetchBiometricUnitsFailedState(message: e.toString()));
      }
    });

    // Handle downloading the Excel file
    on<DownloadExcelEvent>((event, emit) async {
      try {
        emit(DownloadLoadingState());

        var box = await Hive.openBox('authtoken');
        var userId = box.get('user_id');
        box.close();

        // Send the request to download Excel
        var response = await http.post(
          Uri.parse(HttpRoutes.downloadExcel),
          body: jsonEncode({
            "start_date": event.startDate,
            "end_date": event.endDate,
            "unit_id": event.unitId,
            "user_id": userId,
          }),
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          // Get path to save the file
          String? savePath = await _getSavePath();
          if (savePath == null) {
            emit(DownloadExcelFailedState(message: "Save location not selected."));
            return;
          }

          // Write the file
          File file = File(savePath);
          await file.writeAsBytes(response.bodyBytes);

          emit(DownloadExcelSuccessState(message: "File downloaded and saved successfully."));
        } else {
          emit(DownloadExcelFailedState(message: "Failed to download the file. Status Code: ${response.statusCode}"));
        }
      } catch (e) {
        emit(DownloadExcelFailedState(message: "Error occurred: ${e.toString()}"));
      }
    });
  }

  // Helper method to get the directory path for saving the file
  Future<String?> _getSavePath() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return null;
      }

      // Construct file path
      String filePath = '$selectedDirectory/Attendance.xlsx';
      return filePath;
    } catch (e) {
      return null;
    }
  }
}
