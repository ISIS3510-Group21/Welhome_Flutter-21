# User Registration - Eventual Connectivity Implementation

## Overview

This document describes the implementation of **eventual connectivity** for the user registration flow. When a user attempts to register without internet connection, their registration data is saved locally as a draft and automatically synchronized to Firebase when connectivity is restored.

## Architecture

### Components Created

#### 1. **DraftUser Model** (`lib/core/data/models/draft_user.dart`)
Immutable value object representing a user registration in draft state.

**Fields:**
- User Data: `id`, `name`, `email`, `password`, `birthDate`, `gender`, `nationality`, `language`, `phoneNumber`, `phonePrefix`, `userType`
- Image: `localImagePath` (local path to profile image)
- Metadata: `createdAt`, `lastModifiedAt`, `isSyncing`, `isSynced`, `syncError`, `remoteUserId`

**Methods:**
- `toMap()` / `fromMap()` - JSON serialization for SharedPreferences
- `copyWith()` - Creates modified copies with immutability

#### 2. **DraftUserManager** (`lib/core/data/local/draft_user_manager.dart`)
Handles local storage and CRUD operations for draft users.

**Key Methods:**
```dart
Future<void> initialize()              // Initialize SharedPreferences
Future<void> saveDraft(DraftUser user) // Save/update draft
Future<List<DraftUser>> getAllDrafts() // Retrieve all drafts
Future<List<DraftUser>> getPendingSyncs() // Get !isSynced && !isSyncing
Future<void> updateSyncStatus(...)     // Update sync metadata
Future<void> deleteDraft(String id)    // Remove individual draft
Future<void> deleteAllSynced()         // Cleanup after sync
```

**Storage:**
- Uses `SharedPreferences` with key: `draft_users`
- Stores JSON-encoded list of drafts

#### 3. **DraftUserSyncService** (`lib/core/services/draft_user_sync_service.dart`)
Orchestrates automatic synchronization of drafts to Firebase.

**Key Methods:**
```dart
Future<void> startAutoSync()           // Listen to connectivity stream
Future<void> syncAllPending()          // Sync all !isSynced drafts
Future<void> retrySyncDraft(String id) // Manual retry mechanism
```

**Sync Flow:**
1. Listen to `ConnectivityService.connectivityStream`
2. When connection restored: call `syncAllPending()`
3. For each draft:
   - Create user in Firebase Auth
   - Upload profile image to Firebase Storage (if exists)
   - Create user document in Firestore (`OwnerUser` or `StudentUser` collection)
   - Update local draft with `isSynced=true` and `remoteUserId`
4. On error: update draft with `syncError` message for UI display

**Image Handling:**
- Stores local image path during offline registration
- On sync: uploads image to `user_profiles/{uid}/profile.jpg`
- Gets download URL and stores in Firestore as `photoPath`

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    RegisterPage                             │
│                                                             │
│  1. User fills form + selects photo                         │
│  2. Checks connectivity: _isOnline                          │
│     ├─ Online → _registerWithFirebase()                     │
│     └─ Offline → _saveDraft()                               │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
    Online         Offline      Auto-Sync
        │              │              │
        │         ┌─────┴─────┐       │
        │         ▼           ▼       │
        │    Save Draft   UI: Banner  │
        │    Local & UUID            │
        │         │                   │
        │         └──────────┬────────┘
        │                    │
        ▼                    ▼
  Register in         Navigate to Login
  Firebase & Firestore (Draft syncs later)
        │
        ├─ Firebase Auth: createUserWithEmailAndPassword()
        ├─ Upload image to Firebase Storage
        ├─ Create document in Firestore
        └─ Update draft: remoteUserId, isSynced=true
```

## Integration with RegisterPage

### New State Variables
```dart
late DraftUserManager _draftUserManager;
late DraftUserSyncService _syncService;
late ConnectivityService _connectivityService;
bool _isOnline = true;
String? _selectedImagePath;
```

### Initialization (initState)
```dart
Future<void> _initializeServices() async {
  _draftUserManager = DraftUserManager();
  await _draftUserManager.initialize();
  
  _connectivityService = ConnectivityService();
  _syncService = DraftUserSyncService(
    draftUserManager: _draftUserManager,
    connectivityService: _connectivityService,
  );
  
  await _syncService.startAutoSync();
  _checkConnectivity();
}
```

### Registration Logic
```dart
Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;
  
  if (_isOnline) {
    await _registerWithFirebase();
  } else {
    await _saveDraft();
  }
}
```

### Offline Draft Saving
```dart
Future<void> _saveDraft() async {
  final draftUser = DraftUser(
    id: const Uuid().v4(),
    name: _nameController.text.trim(),
    email: _emailController.text.trim(),
    password: _passwordController.text.trim(),
    birthDate: DateTime(_selectedYear!, _selectedMonth!, _selectedDay!),
    gender: _gender,
    nationality: _nationality,
    language: _language,
    phoneNumber: _phoneController.text.trim(),
    phonePrefix: _phonePrefix,
    userType: _userType,
    localImagePath: _selectedImagePath,
    createdAt: DateTime.now(),
    lastModifiedAt: DateTime.now(),
  );
  
  await _draftUserManager.saveDraft(draftUser);
  
  // Show success notification and navigate to login
  _showSuccessMessage("Borrador guardado. Se sincronizará cuando tengas conexión");
}
```

### UI Enhancements

#### Offline Banner
```dart
if (!_isOnline)
  Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    color: Colors.orange,
    child: const Text(
      "Modo offline - Datos se sincronizarán cuando haya conexión",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white),
    ),
  )
```

#### Photo Picker
- New UI element for profile image selection
- Local path stored in `_selectedImagePath`
- Image preview displayed or placeholder shown

#### Button States
- Disabled in offline mode (visual feedback)
- Same functionality whether online or offline (auto-drafting)

### Notification System

```dart
void _showSuccessMessage(String message)  // Green SnackBar
void _showErrorMessage(String message)    // Red SnackBar
```

| Event | Message | Color |
|-------|---------|-------|
| Draft saved (offline) | "Borrador guardado. Se sincronizará cuando tengas conexión" | Green |
| Registration error | Error message from Firebase | Red |
| Sync completed | (Optional - handled by DraftUserSyncService) | Green |

## Data Flow: Offline Registration

### Step 1: User Registers Offline
1. Form is filled with all required data
2. Profile image is selected from gallery
3. User taps "Save user"
4. App detects no internet connection
5. `_saveDraft()` is called

### Step 2: Draft Saved Locally
1. DraftUser object created with UUID as ID
2. All fields populated from form controllers
3. `localImagePath` set to selected image location
4. Draft saved to SharedPreferences with `isSynced=false`
5. UI shows success message
6. User is navigated to login screen

**Important:** User CANNOT log in yet (account doesn't exist in Firebase)

### Step 3: Waiting for Connectivity
1. `DraftUserSyncService` listens continuously to connectivity changes
2. When internet connection is restored:
   - Service calls `syncAllPending()`
   - Retrieves all drafts with `isSynced=false`

### Step 4: Automatic Sync to Firebase
For each pending draft:
1. **Firebase Auth:** Create user account with email/password
2. **Firebase Storage:** Upload profile image (if exists)
   - Path: `user_profiles/{uid}/profile.jpg`
   - Get download URL
3. **Firestore:** Create user document
   - Collection: `OwnerUser` or `StudentUser` (based on `userType`)
   - Document ID: Firebase UID
   - Fields: All user data + photoPath URL
4. **Local Update:**
   - Set `isSynced=true`
   - Set `remoteUserId` to Firebase UID
   - Store successful sync in SharedPreferences

### Error Handling
If sync fails:
- `syncError` is populated with error message
- `isSyncing` is set to false
- Draft remains in `isSynced=false` state
- User can retry manually or wait for next connection restore
- Manual retry via `retrySyncDraft(draftId)`

## Testing Procedures

### Test 1: Offline Registration
1. Disable WiFi/mobile data
2. Navigate to registration page
3. Fill all fields and select profile photo
4. Tap "Save user"
5. **Expected:** Draft saved locally, navigate to login, banner shows "Modo offline"

### Test 2: Draft Persistence
1. After offline registration, kill and reopen app
2. Check SharedPreferences: `draft_users` key should contain registered user
3. **Expected:** Draft persists across app restarts

### Test 3: Automatic Sync
1. After offline registration, restore internet connection
2. Monitor app logs for sync messages
3. Check Firebase Auth console for new user account
4. Check Firestore for new user document in correct collection
5. Check Firebase Storage for uploaded profile image
6. **Expected:** All data synced successfully

### Test 4: Sync Verification
1. After successful sync, restart app with internet
2. Navigate to login page
3. Enter credentials from offline registration
4. **Expected:** Login should work, user account functional

### Test 5: Error Handling
1. Offline registration with same email twice
2. Restore connectivity
3. First draft syncs successfully
4. Second draft fails (email already exists)
5. **Expected:** Error stored in `syncError`, draft not marked synced

### Test 6: Manual Retry
1. Offline registration
2. Restore internet connection
3. If sync fails (simulate by disconnecting mid-sync), trigger manual retry
4. **Expected:** Retry attempts sync again

## Key Differences from Login

| Feature | Login | Registration |
|---------|-------|--------------|
| Online Action | Session saved in SharedPreferences | User created in Firebase |
| Offline Action | Offline credentials stored locally | Draft saved with UUID |
| Sync Trigger | Login attempt with credentials | Automatic on connectivity restore |
| User Feedback | Instant (local validation) | Delayed (async upload) |
| Image Handling | N/A | Local path → Storage URL |
| Expiration | 30-day session | No expiration (valid indefinitely) |

## Edge Cases Handled

1. **Duplicate Email:** If user registers same email twice offline, sync fails for second attempt with Firebase Auth error
2. **Lost Image:** If local image file deleted before sync, sync continues without image
3. **Connection Dropped During Sync:** Draft marked as `isSyncing=true`, will retry next connection restore
4. **Multiple Offline Registrations:** Each draft saved independently with unique UUID
5. **Cleanup:** `deleteAllSynced()` can be called to clean up successfully synced drafts

## File Structure

```
lib/
├── core/
│   ├── data/
│   │   ├── local/
│   │   │   ├── draft_user_manager.dart (NEW)
│   │   │   └── secure_session_manager.dart (existing)
│   │   └── models/
│   │       ├── draft_user.dart (NEW)
│   │       └── draft_post.dart (existing)
│   └── services/
│       ├── draft_user_sync_service.dart (NEW)
│       ├── draft_post_sync_service.dart (existing)
│       └── connectivity_service.dart (existing)
└── features/
    └── register/
        └── presentation/
            └── pages/
                └── register_page.dart (MODIFIED)
```

## Dependencies

- `flutter`: Material Design UI
- `firebase_auth`: User authentication
- `cloud_firestore`: User document storage
- `firebase_storage`: Profile image storage
- `shared_preferences`: Local draft storage
- `connectivity_plus`: Network monitoring
- `image_picker`: Profile photo selection
- `uuid`: Unique draft ID generation
- `equatable`: Value equality for models

## Future Enhancements

1. **Draft Management Screen:** UI to view/edit/delete pending drafts
2. **Background Sync:** Use `WorkManager` or `background_fetch` for continuous sync
3. **Image Compression:** Compress images before storing locally to save space
4. **Progressive Upload:** Show upload progress during sync
5. **Sync Notifications:** Persistent notifications during background sync
6. **Draft Expiration:** Auto-delete drafts after X days if not synced
7. **Conflict Resolution:** Handle cases where user creates account online after offline draft

## Summary

The user registration eventual connectivity implementation mirrors the post creation pattern with offline draft saving and automatic Firebase sync. Users can register without internet, and their account will be created in the cloud when connectivity is restored. All profile data and images are preserved and uploaded automatically.
