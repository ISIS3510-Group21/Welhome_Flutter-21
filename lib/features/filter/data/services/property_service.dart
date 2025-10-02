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

      // Obtener todos los documentos de HousingPost
      final QuerySnapshot housingPostsSnapshot = await _firestore
          .collection('HousingPost')
          .get();

      print('Found ${housingPostsSnapshot.docs.length} housing posts');

      List<Property> properties = [];

      for (var doc in housingPostsSnapshot.docs) {
        try {
          print('Processing housing post: ${doc.id}');
          
          // Verificar los filtros si están activos
          bool includeProperty = true;

          if (selectedAmenities != null && selectedAmenities.isNotEmpty) {
            try {
              final amenitiesSnapshot = await doc.reference.collection('Amenities').get();
              final amenityNames = amenitiesSnapshot.docs
                  .map((amenityDoc) => amenityDoc.data()['name']?.toString())
                  .where((name) => name != null)
                  .toList();
              
              print('Housing post ${doc.id} amenities: $amenityNames');
              
              // Verificar si tiene al menos una de las amenidades seleccionadas
              includeProperty = amenityNames.any((name) => selectedAmenities.contains(name));
            } catch (e) {
              print('Error checking amenities for ${doc.id}: $e');
              includeProperty = false; // Si no podemos verificar las amenidades, excluimos la propiedad
            }
          }

          if (includeProperty && selectedHousingTags != null && selectedHousingTags.isNotEmpty) {
            try {
              final tagsSnapshot = await doc.reference.collection('Tag').get();
              final tagNames = tagsSnapshot.docs
                  .map((tagDoc) => tagDoc.data()['name']?.toString())
                  .where((name) => name != null)
                  .toList();
              
              print('Housing post ${doc.id} tags: $tagNames');
              
              // Verificar si tiene al menos uno de los tags seleccionados
              includeProperty = tagNames.any((name) => selectedHousingTags.contains(name));
            } catch (e) {
              print('Error checking tags for ${doc.id}: $e');
              includeProperty = false; // Si no podemos verificar los tags, excluimos la propiedad
            }
          }

          if (includeProperty) {
            print('Including housing post: ${doc.id}');
            
            // Crear la propiedad con los datos base del documento
            Property property = Property.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            });

            // Intentar obtener amenidades
            try {
              final amenitiesSnapshot = await doc.reference.collection('Amenities').get();
              property.amenities = amenitiesSnapshot.docs
                  .map((amenityDoc) => amenityDoc.data()['name'] as String?)
                  .where((name) => name != null)
                  .cast<String>()
                  .toList();
              print('Housing post ${doc.id} amenities: ${property.amenities}');
            } catch (e) {
              print('Error getting amenities for ${doc.id}: $e');
              property.amenities = [];
            }

            // Intentar obtener tags
            try {
              final tagsSnapshot = await doc.reference.collection('Tag').get();
              property.housingTags = tagsSnapshot.docs
                  .map((tagDoc) => tagDoc.data()['name'] as String?)
                  .where((name) => name != null)
                  .cast<String>()
                  .toList();
              print('Housing post ${doc.id} tags: ${property.housingTags}');
            } catch (e) {
              print('Error getting tags for ${doc.id}: $e');
              property.housingTags = [];
            }

            // Intentar obtener imágenes
            try {
              final picturesSnapshot = await doc.reference.collection('Pictures').get();
              property.pictures = picturesSnapshot.docs
                  .map((picDoc) => picDoc.data()['url'] as String?)
                  .where((url) => url != null)
                  .cast<String>()
                  .toList();
              print('Housing post ${doc.id} pictures: ${property.pictures.length}');
            } catch (e) {
              print('Error getting pictures for ${doc.id}: $e');
              property.pictures = [];
            }

            properties.add(property);
          }
        } catch (e) {
          print('Error processing document ${doc.id}: $e');
          continue;  // Saltar este documento si hay error
        }
      }
      
      print('Retrieved ${properties.length} properties');  // Debug
      return properties;
    } catch (e) {
      print('Error getting properties: $e');
      return [];
    }
  }

  // Obtener todas las etiquetas disponibles
  Future<Map<String, List<String>>> getAllTags() async {
    try {
      // Lista predefinida de amenities
      final amenities = [
        'WiFi', 'Refrigerator', 'Dishwasher', 'Pets Allowed', 'Gym', 'Pool', 
        'Garden', 'Elevator', 'Security', 'Desk', 'Coffee Maker', 'Washing Machine', 
        'Oven', 'Playstation', 'Workspace', 'Fireplace', 'Terrace', 'BBQ', 'Dryer', 
        'Parking', 'Balcony', 'Air Conditioning', 'Heating', 'TV', 'Microwave'
      ];

      // Lista predefinida de housing tags
      final housingTags = [
        'House', 'Penthouse', 'Apartment', 'Cabin', 'Room', 'PrivateBackyard', 
        'Vape-Free', 'Studio', 'Loft', 'SharedKitchen'
      ];
      
      return {
        'amenities': amenities,
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