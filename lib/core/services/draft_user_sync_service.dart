import 'dart:developer' as developer;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:welhome/core/data/local/draft_user_manager.dart';
import 'package:welhome/core/data/models/draft_user.dart';
import 'package:welhome/core/services/connectivity_service.dart';

class DraftUserSyncService {
  final DraftUserManager _draftUserManager;
  final ConnectivityService _connectivityService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool isSyncing = false;

  DraftUserSyncService({
    required DraftUserManager draftUserManager,
    required ConnectivityService connectivityService,
  })  : _draftUserManager = draftUserManager,
        _connectivityService = connectivityService;

  Future<void> startAutoSync() async {
    _connectivityService.connectivityStream.listen((isConnected) async {
      if (isConnected) {
        developer.log('Connection recovered, syncing pending users...');
        await syncAllPending();
      }
    });
  }

  Future<void> syncAllPending() async {
    try {
      List<DraftUser> pendingDrafts =
          await _draftUserManager.getPendingSyncs();

      for (DraftUser draft in pendingDrafts) {
        await _syncDraft(draft);
      }
    } catch (e) {
      developer.log('Error syncing all users: $e');
    }
  }

  Future<void> _syncDraft(DraftUser draft) async {
    try {
      await _draftUserManager.updateSyncStatus(
        draft.id,
        isSyncing: true,
      );

      // Create user in Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: draft.email,
        password: draft.password,
      );

      String uid = userCredential.user!.uid;
      String? profileImageUrl;

      // Upload profile image if exists
      if (draft.localImagePath != null) {
        try {
          final File imageFile = File(draft.localImagePath!);
          if (await imageFile.exists()) {
            final uploadTask = await _storage
                .ref('user_profiles/$uid/profile.jpg')
                .putFile(imageFile);
            profileImageUrl = await uploadTask.ref.getDownloadURL();
          }
        } catch (e) {
          developer.log('Error uploading profile image: $e');
        }
      }

      // Create user document in Firestore
      Map<String, dynamic> userData = {
        'id': uid,
        'name': draft.name,
        'email': draft.email,
        'password': draft.password,
        'birthDate': Timestamp.fromDate(draft.birthDate),
        'gender': draft.gender,
        'nationality': draft.nationality,
        'language': draft.language,
        'phoneNumber': '${draft.phonePrefix} ${draft.phoneNumber}',
        'photoPath': profileImageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (draft.userType == 'host') {
        await _firestore.collection('OwnerUser').doc(uid).set(userData);
      } else {
        await _firestore.collection('StudentUser').doc(uid).set(userData);
      }

      // Mark as synced
      await _draftUserManager.updateSyncStatus(
        draft.id,
        isSyncing: false,
        isSynced: true,
        remoteUserId: uid,
      );

      developer.log('Successfully synced user draft: ${draft.id}');
    } catch (e) {
      developer.log('Error syncing draft: $e');
      await _draftUserManager.updateSyncStatus(
        draft.id,
        isSyncing: false,
        syncError: e.toString(),
      );
    }
  }

  Future<void> retrySyncDraft(String draftId) async {
    DraftUser? draft = await _draftUserManager.getDraft(draftId);
    if (draft != null) {
      await _syncDraft(draft);
    }
  }
}
