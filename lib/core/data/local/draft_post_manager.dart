import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:welhome/core/data/models/draft_post.dart';
import 'dart:developer' as developer;

/// Gestor de posts en borrador usando SharedPreferences
class DraftPostManager {
  static const String _storageKey = 'draft_posts';
  late SharedPreferences _prefs;

  /// Inicializa el gestor de borradores
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    developer.log('DraftPostManager initialized');
  }

  /// Guarda un post en borrador
  Future<void> saveDraft(DraftPost draft) async {
    try {
      final drafts = await getAllDrafts();
      final index = drafts.indexWhere((d) => d.id == draft.id);

      if (index != -1) {
        drafts[index] = draft;
      } else {
        drafts.add(draft);
      }

      final jsonList = drafts.map((d) => jsonEncode(d.toMap())).toList();
      await _prefs.setStringList(_storageKey, jsonList);
      developer.log('Draft saved: ${draft.id}');
    } catch (e) {
      developer.log('Error saving draft: $e');
      rethrow;
    }
  }

  /// Obtiene un borrador específico
  Future<DraftPost?> getDraft(String id) async {
    try {
      final drafts = await getAllDrafts();
      final found = drafts.firstWhere(
        (d) => d.id == id,
        orElse: () => DraftPost(
          id: '',
          title: '',
          description: '',
          address: '',
          price: 0,
          createdAt: DateTime.now(),
          lastModifiedAt: DateTime.now(),
        ),
      );
      return found.id.isNotEmpty ? found : null;
    } catch (e) {
      developer.log('Error getting draft: $e');
      return null;
    }
  }

  /// Obtiene todos los borradores
  Future<List<DraftPost>> getAllDrafts() async {
    try {
      final jsonList = _prefs.getStringList(_storageKey) ?? [];
      return jsonList
          .map((json) => DraftPost.fromMap(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log('Error getting all drafts: $e');
      return [];
    }
  }

  /// Obtiene solo borradores no sincronizados
  Future<List<DraftPost>> getPendingSyncs() async {
    try {
      final drafts = await getAllDrafts();
      return drafts.where((d) => !d.isSynced && !d.isSyncing).toList();
    } catch (e) {
      developer.log('Error getting pending syncs: $e');
      return [];
    }
  }

  /// Obtiene solo borradores que están siendo sincronizados
  Future<List<DraftPost>> getSyncingDrafts() async {
    try {
      final drafts = await getAllDrafts();
      return drafts.where((d) => d.isSyncing).toList();
    } catch (e) {
      developer.log('Error getting syncing drafts: $e');
      return [];
    }
  }

  /// Actualiza el estado de sincronización de un borrador
  Future<void> updateSyncStatus({
    required String draftId,
    required bool isSyncing,
    required bool isSynced,
    String? syncError,
    String? remotePostId,
  }) async {
    try {
      final draft = await getDraft(draftId);
      if (draft != null) {
        final updated = draft.copyWith(
          isSyncing: isSyncing,
          isSynced: isSynced,
          syncError: syncError,
          remotePostId: remotePostId,
          lastModifiedAt: DateTime.now(),
        );
        await saveDraft(updated);
        developer.log('Draft sync status updated: $draftId (synced: $isSynced)');
      }
    } catch (e) {
      developer.log('Error updating sync status: $e');
      rethrow;
    }
  }

  /// Elimina un borrador
  Future<void> deleteDraft(String id) async {
    try {
      final drafts = await getAllDrafts();
      drafts.removeWhere((d) => d.id == id);

      final jsonList = drafts.map((d) => jsonEncode(d.toMap())).toList();
      await _prefs.setStringList(_storageKey, jsonList);
      developer.log('Draft deleted: $id');
    } catch (e) {
      developer.log('Error deleting draft: $e');
      rethrow;
    }
  }

  /// Elimina todos los borradores sincronizados
  Future<void> deleteAllSynced() async {
    try {
      final drafts = await getAllDrafts();
      drafts.removeWhere((d) => d.isSynced);

      final jsonList = drafts.map((d) => jsonEncode(d.toMap())).toList();
      await _prefs.setStringList(_storageKey, jsonList);
      developer.log('All synced drafts deleted');
    } catch (e) {
      developer.log('Error deleting synced drafts: $e');
      rethrow;
    }
  }

  /// Limpia todos los borradores
  Future<void> clearAll() async {
    try {
      await _prefs.remove(_storageKey);
      developer.log('All drafts cleared');
    } catch (e) {
      developer.log('Error clearing drafts: $e');
      rethrow;
    }
  }

  /// Cuenta el número de borradores pendientes de sincronizar
  Future<int> countPending() async {
    final pending = await getPendingSyncs();
    return pending.length;
  }
}
