import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/property.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Property>> getProperties({
    List<String>? selectedAmenities,
    List<String>? selectedHousingTags,
  }) async {
    try {
      print('Fetching properties...');
      print('Selected amenities: $selectedAmenities');
      print('Selected housing tags: $selectedHousingTags');

      QuerySnapshot housingSnapshot;

      // Si hay filtros de amenidades
      if (selectedAmenities?.isNotEmpty == true) {
        try {
          // Intentar usar collectionGroup (requiere índice)
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
          print(
              'CollectionGroup query failed, falling back to simple query: $e');
          // Fallback: obtener posts y filtrar manualmente
          housingSnapshot =
              await _firestore.collection('HousingPost').limit(10).get();
        }
      } else {
        // Sin filtros de amenidades, obtener los últimos posts
        housingSnapshot =
            await _firestore.collection('HousingPost').limit(10).get();
      }
      print('Processing ${housingSnapshot.docs.length} housing posts');
      List<Property> properties = [];

      // Procesar cada documento
      for (var doc in housingSnapshot.docs) {
        try {
          Property property = Property.fromJson({
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
          });

          // Cargar amenidades
          try {
            final amenitiesSnapshot =
                await doc.reference.collection('Amenities').get();
            property.amenities = amenitiesSnapshot.docs
                .map((doc) => doc.data()['name'] as String?)
                .where((name) => name != null)
                .cast<String>()
                .toList();

            // Verificar filtro de amenidades
            if (selectedAmenities?.isNotEmpty == true &&
                !property.amenities
                    .any((a) => selectedAmenities!.contains(a))) {
              continue; // Skip if doesn't match amenities filter
            }
          } catch (e) {
            print('Error loading amenities for ${doc.id}: $e');
            property.amenities = [];
            if (selectedAmenities?.isNotEmpty == true) {
              continue; // Skip if amenities are required but failed to load
            }
          }

          // Cargar tags
          try {
            final tagsSnapshot = await doc.reference.collection('Tag').get();
            property.housingTags = tagsSnapshot.docs
                .map((doc) => doc.data()['name'] as String?)
                .where((name) => name != null)
                .cast<String>()
                .toList();

            // Verificar filtro de tags
            if (selectedHousingTags?.isNotEmpty == true &&
                !property.housingTags
                    .any((t) => selectedHousingTags!.contains(t))) {
              continue; // Skip if doesn't match tags filter
            }
          } catch (e) {
            print('Error loading tags for ${doc.id}: $e');
            property.housingTags = [];
            if (selectedHousingTags?.isNotEmpty == true) {
              continue; // Skip if tags are required but failed to load
            }
          }

          // Cargar imágenes
          try {
            final picturesSnapshot =
                await doc.reference.collection('Pictures').get();
            property.pictures = picturesSnapshot.docs
                .map((doc) => doc.data()['url'] as String?)
                .where((url) => url != null)
                .cast<String>()
                .toList();
          } catch (e) {
            print('Error loading pictures for ${doc.id}: $e');
            property.pictures = [];
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

// Obtener todas las etiquetas disponibles
  Future<Map<String, dynamic>> getAllTags() async {
    try {
      // Amenities agrupados por categoría
      final Map<String, List<String>> amenitiesByCategory = {
        'Básicos': ['WiFi', 'Air Conditioning', 'Heating'],
        'Cocina': [
          'Refrigerator',
          'Dishwasher',
          'Oven',
          'Microwave',
          'Coffee Maker'
        ],
        'Lavandería': ['Washing Machine', 'Dryer'],
        'Entretenimiento': ['TV', 'Playstation', 'BBQ'],
        'Espacios': ['Workspace', 'Garden', 'Terrace', 'Balcony', 'Parking'],
        'Comodidades': ['Elevator', 'Security', 'Desk', 'Fireplace'],
        'Reglas': ['Pets Allowed'],
      };
      // Lista predefinida de housing tags (tipos de vivienda)
      final housingTags = [
        'House',
        'Penthouse',
        'Apartment',
        'Cabin',
        'Room',
        'PrivateBackyard',
        'Vape-Free',
        'Studio',
        'Loft',
        'SharedKitchen'
      ];
      return {
        'amenitiesByCategory': amenitiesByCategory,
        'housingTags': housingTags,
      };
    } catch (e) {
      print('Error getting tags: $e');
      return {
        'amenities': [],
        'housingTags': [],
      };
    }
  }
}
