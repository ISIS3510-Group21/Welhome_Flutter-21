import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:welhome/core/data/models/draft_user.dart';

class DraftUserManager {
  static const String _storageKey = 'draft_users';
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveDraft(DraftUser draftUser) async {
    try {
      List<DraftUser> drafts = await getAllDrafts();
      int index = drafts.indexWhere((d) => d.id == draftUser.id);

      if (index >= 0) {
        drafts[index] = draftUser;
      } else {
        drafts.add(draftUser);
      }

      List<Map<String, dynamic>> jsonList =
          drafts.map((draft) => draft.toMap()).toList();
      await _prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      throw Exception('Error saving draft user: $e');
    }
  }

  Future<DraftUser?> getDraft(String draftId) async {
    try {
      List<DraftUser> drafts = await getAllDrafts();
      return drafts.firstWhere(
        (d) => d.id == draftId,
        orElse: () => throw Exception('Draft not found'),
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<DraftUser>> getAllDrafts() async {
    try {
      String? jsonString = _prefs.getString(_storageKey);
      if (jsonString == null) return [];

      List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((item) => DraftUser.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error retrieving drafts: $e');
    }
  }

  Future<List<DraftUser>> getPendingSyncs() async {
    List<DraftUser> drafts = await getAllDrafts();
    return drafts.where((d) => !d.isSynced && !d.isSyncing).toList();
  }

  Future<List<DraftUser>> getSyncingDrafts() async {
    List<DraftUser> drafts = await getAllDrafts();
    return drafts.where((d) => d.isSyncing).toList();
  }

  Future<void> updateSyncStatus(
    String draftId, {
    bool? isSyncing,
    bool? isSynced,
    String? syncError,
    String? remoteUserId,
  }) async {
    try {
      DraftUser? draft = await getDraft(draftId);
      if (draft == null) throw Exception('Draft not found');

      DraftUser updatedDraft = draft.copyWith(
        isSyncing: isSyncing ?? draft.isSyncing,
        isSynced: isSynced ?? draft.isSynced,
        syncError: syncError ?? draft.syncError,
        remoteUserId: remoteUserId ?? draft.remoteUserId,
        lastModifiedAt: DateTime.now(),
      );

      await saveDraft(updatedDraft);
    } catch (e) {
      throw Exception('Error updating sync status: $e');
    }
  }

  Future<void> deleteDraft(String draftId) async {
    try {
      List<DraftUser> drafts = await getAllDrafts();
      drafts.removeWhere((d) => d.id == draftId);

      if (drafts.isEmpty) {
        await _prefs.remove(_storageKey);
      } else {
        List<Map<String, dynamic>> jsonList =
            drafts.map((draft) => draft.toMap()).toList();
        await _prefs.setString(_storageKey, jsonEncode(jsonList));
      }
    } catch (e) {
      throw Exception('Error deleting draft: $e');
    }
  }

  Future<void> deleteAllSynced() async {
    try {
      List<DraftUser> drafts = await getAllDrafts();
      drafts.removeWhere((d) => d.isSynced);

      if (drafts.isEmpty) {
        await _prefs.remove(_storageKey);
      } else {
        List<Map<String, dynamic>> jsonList =
            drafts.map((draft) => draft.toMap()).toList();
        await _prefs.setString(_storageKey, jsonEncode(jsonList));
      }
    } catch (e) {
      throw Exception('Error deleting synced drafts: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _prefs.remove(_storageKey);
    } catch (e) {
      throw Exception('Error clearing all drafts: $e');
    }
  }
}
