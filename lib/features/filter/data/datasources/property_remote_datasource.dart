import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/filter/data/models/property_model.dart';
import 'package:welhome/features/filter/data/services/property_cache_service.dart';

class PropertyRemoteDataSource {
  final FirebaseFirestore _firestore;
  final PropertyCacheService _cacheService;
  
  PropertyRemoteDataSource({
    FirebaseFirestore? firestore,
    required PropertyCacheService cacheService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cacheService = cacheService;
      
  Future<(List<PropertyModel>, DocumentSnapshot?)> getProperties({
    List<String>? selectedAmenities,
    List<String>? selectedHousingTags,
    DocumentSnapshot? lastDocument,
    int pageSize = 20,
  }) async {
    try {
      // Try to get filtered properties from cache first if no lastDocument (first page)
      if (lastDocument == null && 
          (selectedAmenities?.isNotEmpty == true || selectedHousingTags?.isNotEmpty == true)) {
        final cachedProperties = await _cacheService.filterCachedProperties(
          selectedAmenities: selectedAmenities,
          selectedHousingTags: selectedHousingTags,
        );
        if (cachedProperties.isNotEmpty) {
          print('Returning filtered properties from cache');
          return (cachedProperties.take(pageSize).toList(), null);
        }
      }
      
      print('Fetching properties from Firestore... Page size: $pageSize');
      print('Selected amenities: $selectedAmenities');
      print('Selected housing tags: $selectedHousingTags');

      Query query = _firestore.collection('HousingPost');

      // Si hay filtros de amenidades, necesitamos cargar todos los posts y filtrar manualmente
      // ya que las amenidades están en una subcolección
      if (selectedAmenities?.isNotEmpty == true) {
        try {
          // Obtener los primeros 50 posts (ajusta este número según necesidad)
          final QuerySnapshot initialHousingSnapshot = await query.limit(50).get();
          final matchingPostIds = <String>{};

          // Para cada post, cargar y verificar sus amenidades
          for (var doc in initialHousingSnapshot.docs) {
            // Cargar todas las amenidades del post
            final amenitiesSnapshot = await doc.reference.collection('Amenities').get();
            if (amenitiesSnapshot.docs.isEmpty) {
              print('No amenities found for post ${doc.id}');
              continue;
            }

            // Extraer los nombres de las amenidades
            final postAmenities = amenitiesSnapshot.docs
                .map((amenityDoc) => amenityDoc.data()['name'] as String?)
                .where((name) => name != null)
                .cast<String>()
                .toSet();

            print('Post ${doc.id} has amenities: $postAmenities');

            // Verificar si el post tiene TODAS las amenidades seleccionadas
            if (selectedAmenities!.every((amenity) => 
                postAmenities.any((postAmenity) => 
                    postAmenity.toLowerCase() == amenity.toLowerCase()))) {
              print('Post ${doc.id} matches all selected amenities');
              matchingPostIds.add(doc.id);
            }
          }

          if (matchingPostIds.isEmpty) {
            print('No posts found matching all selected amenities: $selectedAmenities');
            return (List<PropertyModel>.empty(), null);
          }

          print('Found ${matchingPostIds.length} posts matching all amenities');
          
          // Actualizar la consulta para obtener solo los posts que coinciden
          query = _firestore.collection('HousingPost')
              .where(FieldPath.documentId, whereIn: matchingPostIds.toList());
        } catch (e) {
          print('Failed to query amenities: $e');
          return (List<PropertyModel>.empty(), null);
        }
      }

      // Añadir paginación
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      query = query.limit(pageSize);
      
      final QuerySnapshot housingSnapshot = await query.get();
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
            final amenitiesSnapshot = await doc.reference.collection('Amenities').get();
            final amenities = amenitiesSnapshot.docs
                .map((doc) => doc.data()['name'] as String?)
                .where((name) => name != null)
                .cast<String>()
                .toList();

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
              amenities: amenities,
              housingTags: property.housingTags,
              pictures: property.pictures,
            );

            // Solo verificar las amenidades si no se hizo en la consulta inicial
            if (selectedAmenities?.isNotEmpty == true && lastDocument != null) {
              final hasAllAmenities = selectedAmenities!.every((amenity) =>
                  amenities.any((a) => a.toLowerCase() == amenity.toLowerCase()));
              if (!hasAllAmenities) {
                print('Post ${doc.id} missing some selected amenities');
                continue;
              }
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

      DocumentSnapshot? lastVisibleDoc = housingSnapshot.docs.isEmpty ? null : housingSnapshot.docs.last;
      print('Retrieved ${properties.length} matching properties');
      
      // Cache properties if this is the first page and no filters are applied
      if (lastDocument == null && 
          selectedAmenities?.isEmpty != false && 
          selectedHousingTags?.isEmpty != false) {
        await _cacheService.cacheProperties(properties);
        print('Cached ${properties.length} properties');
      }
      
      return (properties, lastVisibleDoc);
    } catch (e) {
      print('Error in getProperties: $e');
      return (List<PropertyModel>.empty(), null);
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