import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/filter/data/models/property_model.dart';

class PropertyRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  PropertyRemoteDataSource({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;
      
  Future<List<PropertyModel>> getProperties({
    List<String>? selectedAmenities,
    List<String>? selectedHousingTags,
  }) async {
    try {
      print('Fetching properties...');
      print('Selected amenities: $selectedAmenities');
      print('Selected housing tags: $selectedHousingTags');

      QuerySnapshot housingSnapshot;

      if (selectedAmenities?.isNotEmpty == true) {
        try {
          final amenityQuery = await _firestore
              .collectionGroup('Amenities')
              .where('name', whereIn: selectedAmenities)
              .get();

          final postIds = amenityQuery.docs
              .map((doc) => doc.reference.parent.parent?.id)
              .where((id) => id != null)
              .cast<String>()
              .toSet();

          if (postIds.isEmpty) {
            print('No matching posts found for amenities');
            return [];
          }

          print('Found ${postIds.length} posts with matching amenities');
          housingSnapshot = await _firestore
              .collection('HousingPost')
              .where(FieldPath.documentId, whereIn: postIds.take(10).toList())
              .get();
        } catch (e) {
          print('CollectionGroup query failed, falling back to simple query: $e');
          housingSnapshot =
              await _firestore.collection('HousingPost').limit(10).get();
        }
      } else {
        housingSnapshot =
            await _firestore.collection('HousingPost').limit(10).get();
      }

      print('Processing ${housingSnapshot.docs.length} housing posts');
      List<PropertyModel> properties = [];

      for (var doc in housingSnapshot.docs) {
        try {
          PropertyModel property = PropertyModel.fromJson({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          });

          // Load amenities
          try {
            final amenitiesSnapshot =
                await doc.reference.collection('Amenities').get();
            property = PropertyModel(
              id: property.id,
              title: property.title,
              description: property.description,
              address: property.address,
              price: property.price,
              rating: property.rating,
              creationDate: property.creationDate,
              updatedAt: property.updatedAt,
              location: property.location,
              host: property.host,
              closureDate: property.closureDate,
              amenities: amenitiesSnapshot.docs
                  .map((doc) => doc.data()['name'] as String?)
                  .where((name) => name != null)
                  .cast<String>()
                  .toList(),
              housingTags: property.housingTags,
              pictures: property.pictures,
            );

            if (selectedAmenities?.isNotEmpty == true &&
                !property.amenities.any((a) => selectedAmenities!.contains(a))) {
              continue;
            }
          } catch (e) {
            print('Error loading amenities for ${doc.id}: $e');
            if (selectedAmenities?.isNotEmpty == true) {
              continue;
            }
          }

          // Load tags
          try {
            final tagsSnapshot = await doc.reference.collection('Tag').get();
            property = PropertyModel(
              id: property.id,
              title: property.title,
              description: property.description,
              address: property.address,
              price: property.price,
              rating: property.rating,
              creationDate: property.creationDate,
              updatedAt: property.updatedAt,
              location: property.location,
              host: property.host,
              closureDate: property.closureDate,
              amenities: property.amenities,
              housingTags: tagsSnapshot.docs
                  .map((doc) => doc.data()['name'] as String?)
                  .where((name) => name != null)
                  .cast<String>()
                  .toList(),
              pictures: property.pictures,
            );

            if (selectedHousingTags?.isNotEmpty == true &&
                !property.housingTags.any((t) => selectedHousingTags!.contains(t))) {
              continue;
            }
          } catch (e) {
            print('Error loading tags for ${doc.id}: $e');
            if (selectedHousingTags?.isNotEmpty == true) {
              continue;
            }
          }

          // Load pictures
          try {
            final picturesSnapshot =
                await doc.reference.collection('Pictures').get();
            property = PropertyModel(
              id: property.id,
              title: property.title,
              description: property.description,
              address: property.address,
              price: property.price,
              rating: property.rating,
              creationDate: property.creationDate,
              updatedAt: property.updatedAt,
              location: property.location,
              host: property.host,
              closureDate: property.closureDate,
              amenities: property.amenities,
              housingTags: property.housingTags,
              pictures: picturesSnapshot.docs
                  .map((doc) => doc.data()['url'] as String?)
                  .where((url) => url != null)
                  .cast<String>()
                  .toList(),
            );
          } catch (e) {
            print('Error loading pictures for ${doc.id}: $e');
          }

          properties.add(property);
          print('Added property ${doc.id} to results');
        } catch (e) {
          print('Error processing document ${doc.id}: $e');
          continue;
        }
      }

      print('Retrieved ${properties.length} matching properties');
      return properties;
    } catch (e) {
      print('Error in getProperties: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getAllTags() async {
    try {
      print('Fetching all tags from Firebase...');
      
      // Obtener amenities desde Firebase
      final amenitiesSnapshot = await _firestore.collection('Amenities').get();
      final amenities = amenitiesSnapshot.docs
          .map((doc) => doc.data()['name'] as String?)
          .where((name) => name != null)
          .cast<String>()
          .toList();
      
      print('Found ${amenities.length} amenities');
      
      // Ordenar las amenidades
      amenities.sort();

      // Obtener housing tags
      final housingTagsSnapshot = await _firestore.collection('HousingTypes').get();
      final housingTags = housingTagsSnapshot.docs
          .map((doc) => doc.data()['name'] as String?)
          .where((name) => name != null)
          .cast<String>()
          .toList();

      // Ordenar los housing tags
      housingTags.sort();

      print('Retrieved ${amenities.length} amenities and ${housingTags.length} housing types');

      return {
        'amenities': amenities,
        'housingTags': housingTags,
      };
    } catch (e) {
      print('Error getting tags from Firebase: $e');
      // Fallback a una lista básica en caso de error
      return {
        'amenities': ['WiFi', 'AC'],
        'housingTags': ['Apartment', 'House'],
      };
    }
  }
}