// create_housing_post_page.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';

class CreateHousingPostPage extends StatefulWidget {
  const CreateHousingPostPage({super.key});

  @override
  State<CreateHousingPostPage> createState() => _CreateHousingPostPageState();
}

class _CreateHousingPostPageState extends State<CreateHousingPostPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  // Amenities & tags loaded from Firestore
  List<Map<String, dynamic>> _amenities = [];
  List<Map<String, dynamic>> _housingTags = [];

  // Selection states
  final Set<String> _selectedAmenityIds = {};
  String? _selectedHousingTagId; // e.g. HousingTag1, HousingTag2...
  bool _loading = false;

  // Images
  XFile? _mainPhoto;
  final List<XFile> _otherPhotos = [];

  // Image picker
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadAmenities();
    _loadHousingTags();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadAmenities() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('Amenities').get();
      final list = snap.docs.map((d) {
        return {
          'id': d.id,
          'name': d.data()['name'] ?? d.id,
          ...d.data(),
        };
      }).toList();
      if (mounted) setState(() => _amenities = list);
    } catch (e) {
      // ignore errors for load — you may want to handle logging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error loading amenities')));
      }
    }
  }

  Future<void> _loadHousingTags() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('HousingTag').get();
      final list = snap.docs.map((d) {
        return {
          'id': d.id,
          'name': d.data()['name'] ?? d.id,
          ...d.data(),
        };
      }).toList();

      // Keep result
      if (mounted) setState(() => _housingTags = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error loading housing tags')));
      }
    }
  }

  // Pickers
  Future<void> _pickMainPhotoFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _mainPhoto = picked);
    }
  }

  Future<void> _pickFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      setState(() => _otherPhotos.add(picked));
    }
  }

  Future<void> _pickMultipleFromGallery() async {
    final pickedList = await _picker.pickMultiImage(imageQuality: 80);
    if (pickedList.isNotEmpty) {
      setState(() => _otherPhotos.addAll(pickedList));
    }
  }

  // Save flow
  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHousingTagId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione el tipo de vivienda')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Prepare new doc ref (we need the id for storage paths)
      final docRef = firestore.collection('HousingPost').doc();
      final postId = docRef.id;

      // Parse price
      final price = double.tryParse(_priceController.text.replaceAll(',', '').trim()) ?? 0;

      // Build base post data
      final Map<String, dynamic> postData = {
        'id': postId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'price': price,
        'host': user.uid,
        // optional / initially empty:
        'closureDate': null,
        'creationDate': FieldValue.serverTimestamp(),
        'location': {}, // left empty map for now
        'rating': null,
        'status': null,
        'statusChange': null,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 1) Create the main document (we put the base data first)
      await docRef.set(postData);

      // 2) Save selected housing tag in subcollection 'Tag'
      // Try find tag doc data from loaded list
      final selectedTagDoc =
          _housingTags.firstWhere((t) => t['id'] == _selectedHousingTagId, orElse: () => {});
      if (selectedTagDoc.isNotEmpty) {
        await docRef.collection('Tag').doc(_selectedHousingTagId).set({
          'id': _selectedHousingTagId,
          'name': selectedTagDoc['name'] ?? _selectedHousingTagId,
        });
      } else {
        // If not found, still create a minimal doc
        await docRef.collection('Tag').doc(_selectedHousingTagId).set({
          'id': _selectedHousingTagId,
          'name': _selectedHousingTagId,
        });
      }

      // 3) Save selected amenities as subcollection 'Amenities'
      for (final amenity in _amenities) {
        final id = amenity['id'] as String;
        if (_selectedAmenityIds.contains(id)) {
          await docRef.collection('Amenities').doc(id).set({
            'id': id,
            'name': amenity['name'] ?? id,
          });
        }
      }

      // 4) Upload pictures to Firebase Storage and add subcollection 'Pictures'
      final storage = FirebaseStorage.instance;
      final List<Map<String, String>> uploadedPictures = [];

      // Build a combined list where mainPhoto goes first (if exists)
      final List<XFile> allPhotos = [];
      if (_mainPhoto != null) allPhotos.add(_mainPhoto!);
      allPhotos.addAll(_otherPhotos);

      for (int i = 0; i < allPhotos.length; i++) {
        final xfile = allPhotos[i];
        final file = File(xfile.path);

        final storagePath = 'images/housing/${postId}_$i${_getFileExtension(xfile.path)}';
        final ref = storage.ref().child(storagePath);

        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask;
        // Optionally you can get downloadURL:
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // create record in subcollection
        final picDoc = docRef.collection('Pictures').doc();
        final picData = {
          'id': picDoc.id,
          'photoPath': storagePath,
          'name': xfile.name,
          'downloadUrl': downloadUrl,
        };
        await picDoc.set(picData);
        uploadedPictures.add({'id': picDoc.id, 'path': storagePath});
      }

      // 5) Update updatedAt in main doc (already set at creation but keep consistent)
      await docRef.update({'updatedAt': FieldValue.serverTimestamp()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Housing post created successfully')),
        );
        // Optionally clear the form or navigate away:
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _getFileExtension(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return '.jpg';
    return path.substring(idx);
  }

  void _clearForm() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _addressController.clear();
    _selectedAmenityIds.clear();
    _selectedHousingTagId = null;
    _mainPhoto = null;
    _otherPhotos.clear();
    setState(() {});
  }

  Widget _buildHousingTagButtons() {
    // We want specifically these 4 tags (IDs): HousingTag1, HousingTag2, HousingTag4, HousingTag11
    final wanted = ['HousingTag1', 'HousingTag2', 'HousingTag4', 'HousingTag11'];
    final tagsMap = {for (var t in _housingTags) t['id']: t};

    final buttons = wanted.map((id) {
      final name = (tagsMap[id] != null) ? (tagsMap[id]!['name'] ?? id) : id;
      final selected = _selectedHousingTagId == id;
      return GestureDetector(
        onTap: () {
          setState(() => _selectedHousingTagId = id);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.violetBlue.withOpacity(0.15) : Colors.transparent,
            border: Border.all(color: AppColors.violetBlue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(name, style: AppTextStyles.textRegular.copyWith(
              color: selected ? AppColors.violetBlue : Colors.black,
            )),
          ),
        ),
      );
    }).toList();

    // Layout 2x2 grid
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 3.8,
      physics: const NeverScrollableScrollPhysics(),
      children: buttons,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Housing Post'),
        titleTextStyle: AppTextStyles.tittleMedium,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text('Title', style: AppTextStyles.tittleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.violetBlue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.violetBlue, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.violetBlue, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.lavenderLight,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Price
              Text('Price', style: AppTextStyles.tittleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter price',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.violetBlue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.violetBlue, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.violetBlue, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.lavenderLight,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter price';
                  if (double.tryParse(v.replaceAll(',', '').trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description (big)
              Text('Description', style: AppTextStyles.tittleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Enter description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.violetBlue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.violetBlue, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.violetBlue, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.lavenderLight,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),

              // HousingTag buttons 2x2
              Text('Type of housing', style: AppTextStyles.tittleSmall),
              const SizedBox(height: 8),
              _buildHousingTagButtons(),
              const SizedBox(height: 16),

              // Amenities horizontal rail
              Text('Amenities', style: AppTextStyles.tittleSmall),
              const SizedBox(height: 8),
              SizedBox(
                height: 56,
                child: _amenities.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _amenities.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final a = _amenities[index];
                          final selected = _selectedAmenityIds.contains(a['id']);
                          return ChoiceChip(
                            label: Text(a['name'] ?? a['id']),
                            selected: selected,
                            onSelected: (sel) {
                              setState(() {
                                if (sel) {
                                  _selectedAmenityIds.add(a['id']);
                                } else {
                                  _selectedAmenityIds.remove(a['id']);
                                }
                              });
                            },
                            selectedColor: AppColors.violetBlue.withOpacity(0.15),
                            backgroundColor: AppColors.lavenderLight,
                            labelStyle: AppTextStyles.textRegular.copyWith(
                              color: selected ? AppColors.violetBlue : Colors.black,
                            ),
                            side: const BorderSide(color: AppColors.violetBlue, width: 2),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),

              // Add Photos
              Text('Add Photos', style: AppTextStyles.tittleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickMainPhotoFromGallery,
                      icon: const Icon(Icons.photo),
                      label: const Text('Main photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violetBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violetBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickMultipleFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violetBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Thumbnails preview
              if (_mainPhoto != null || _otherPhotos.isNotEmpty)
                SizedBox(
                  height: 96,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_mainPhoto != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.violetBlue, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.file(File(_mainPhoto!.path), fit: BoxFit.cover),
                              ),
                              const SizedBox(height: 4),
                              const Text('Main'),
                            ],
                          ),
                        ),
                      ..._otherPhotos.map((x) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.violetBlue, width: 2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.file(File(x.path), fit: BoxFit.cover),
                                ),
                                const SizedBox(height: 4),
                                const Text('Photo'),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Address
              Text('Address', style: AppTextStyles.tittleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Enter address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.violetBlue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.violetBlue, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.violetBlue, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.lavenderLight,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter address' : null,
              ),
              const SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _savePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violetBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
