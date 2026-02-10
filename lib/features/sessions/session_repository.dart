import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'session_model.dart';

/// SharedPreferences-backed repository for academic sessions.
///
/// Storage format:
/// - JSON list under [_storageKey]
///
/// Sessions include attendance, so persisting sessions also persists attendance.
class SessionRepository {
  static const String _storageKey = 'alu_student_sessions';

  static SessionRepository? _instance;
  factory SessionRepository() => _instance ??= SessionRepository._internal();
  SessionRepository._internal();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<AcademicSession>> loadSessions() async {
    try {
      final prefs = await _prefs;
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .whereType<Map<String, dynamic>>()
          .map(AcademicSession.fromJson)
          .where((s) => s.id.isNotEmpty && s.title.trim().isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Error loading sessions: $e');
      await clearAll();
      return [];
    }
  }

  Future<bool> saveSessions(List<AcademicSession> sessions) async {
    try {
      final prefs = await _prefs;
      final validSessions = sessions
          .where((s) => s.id.isNotEmpty && s.title.trim().isNotEmpty)
          .toList();
      final jsonList = validSessions.map((s) => s.toJson()).toList();
      return prefs.setString(_storageKey, json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving sessions: $e');
      return false;
    }
  }

  Future<bool> clearAll() async {
    final prefs = await _prefs;
    return prefs.remove(_storageKey);
  }
}

