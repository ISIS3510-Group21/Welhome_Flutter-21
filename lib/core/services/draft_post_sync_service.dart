import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:welhome/core/data/local/draft_post_manager.dart';
import 'package:welhome/core/data/models/draft_post.dart';
import 'package:welhome/core/services/connectivity_service.dart';
import 'dart:developer' as developer;

/// Sincronizador de posts en borrador a Firebase
class DraftPostSyncService {
  final DraftPostManager _draftManager;
  final ConnectivityService _connectivityService;
  bool _isSyncing = false;

  DraftPostSyncService({
    required DraftPostManager draftManager,
    required ConnectivityService connectivityService,
  })  : _draftManager = draftManager,
        _connectivityService = connectivityService;

  /// Obtiene el estado actual de sincronización
  bool get isSyncing => _isSyncing;

  /// Inicia el monitoreo de conectividad para sincronizar automáticamente
  void startAutoSync() {
    _connectivityService.connectivityStream.listen((isOnline) {
      if (isOnline) {
        developer.log('Device online - starting draft post sync');
        syncAllPending();
      }
    });
  }

  /// Sincroniza todos los borradores pendientes
  Future<void> syncAllPending() async {
    if (_isSyncing) {
      developer.log('Sync already in progress, skipping');
      return;
    }

    _isSyncing = true;
    try {
      final pendingDrafts = await _draftManager.getPendingSyncs();
      developer.log('Found ${pendingDrafts.length} pending drafts to sync');  

      for (final draft in pendingDrafts) {
        await _syncDraft(draft);
      }

      developer.log('Sync completed');
    } catch (e) {
      developer.log('Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sincroniza un borrador individual
  Future<void> _syncDraft(DraftPost draft) async {
    try {
      // Marcar como sincronizando
      await _draftManager.updateSyncStatus(
        draftId: draft.id,
        isSyncing: true,
        isSynced: false,
      );

      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Crear documento en Firestore
      final docRef = firestore.collection('HousingPost').doc();
      final postId = docRef.id;

      final postData = {
        'id': postId,
        'title': draft.title,
        'description': draft.description,
        'address': draft.address,
        'price': draft.price,
        'host': user.uid,
        'closureDate': null,
        'creationDate': FieldValue.serverTimestamp(),
        'location': {},
        'rating': null,
        'status': null,
        'statusChange': null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(postData);

      // Guardar housing tag
      if (draft.housingTagId != null) {
        await docRef.collection('Tag').doc(draft.housingTagId).set({
          'id': draft.housingTagId,
          'name': draft.housingTagId,
        });
      }

      // Guardar amenities
      for (final amenityId in draft.amenityIds) {
        await docRef.collection('Amenities').doc(amenityId).set({
          'id': amenityId,
          'name': amenityId,
        });
      }

      // Subir imágenes
      final storage = FirebaseStorage.instance;
      for (int i = 0; i < draft.localImagePaths.length; i++) {
        final imagePath = draft.localImagePaths[i];
        final file = File(imagePath);

        if (!await file.exists()) {
          developer.log('Image file not found: $imagePath');
          continue;
        }

        final storagePath = 'images/housing/${postId}_$i${_getFileExtension(imagePath)}';
        final ref = storage.ref().child(storagePath);

        try {
          final uploadTask = ref.putFile(file);
          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();

          final picDoc = docRef.collection('Pictures').doc();
          await picDoc.set({
            'id': picDoc.id,
            'photoPath': storagePath,
            'name': file.path.split('/').last,
            'downloadUrl': downloadUrl,
          });

          developer.log('Image $i uploaded successfully');
        } catch (e) {
          developer.log('Error uploading image $i: $e');
        }
      }

      // Actualizar estado como sincronizado
      await _draftManager.updateSyncStatus(
        draftId: draft.id,
        isSyncing: false,
        isSynced: true,
        remotePostId: postId,
      );

      developer.log('Draft ${draft.id} synced successfully');
    } catch (e) {
      developer.log('Error syncing draft ${draft.id}: $e');
      // Guardar error pero no marcar como sincronizado
      await _draftManager.updateSyncStatus(
        draftId: draft.id,
        isSyncing: false,
        isSynced: false,
        syncError: e.toString(),
      );
    }
  }

  /// Obtiene extensión del archivo
  String _getFileExtension(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return '.jpg';
    return path.substring(idx);
  }

  /// Reintentar sincronizar un borrador específico
  Future<void> retrySyncDraft(String draftId) async {
    try {
      final draft = await _draftManager.getDraft(draftId);
      if (draft != null) {
        await _syncDraft(draft);
      }
    } catch (e) {
      developer.log('Error retrying sync for draft $draftId: $e');
    }
  }
}
