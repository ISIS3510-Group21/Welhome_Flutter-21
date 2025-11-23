# Eventual Connectivity para Crear Posts

## Descripción

Esta implementación permite que los usuarios creen publicaciones de vivienda incluso sin conexión a internet. El sistema guarda automáticamente borradores locales que se sincronizan a Firebase cuando se recupera la conexión.

## Características

- **Guardado Offline**: Las publicaciones se guardan como borradores cuando no hay internet
- **Sincronización Automática**: Se sincroniza automáticamente cuando se recupera conexión
- **Notificaciones de Estado**: Mensajes claros sobre el estado del proceso
- **UI Adaptativa**: La interfaz se adapta según el estado de conectividad
- **Manejo de Errores**: Reintentos automáticos y manejo de errores de sincronización

## Componentes Implementados

### 1. **DraftPost Model** (`lib/core/data/models/draft_post.dart`)
Modelo que representa una publicación en borrador con:
- Datos del formulario (título, descripción, dirección, precio)
- Información de comodidades y tipo de vivienda
- Rutas locales de imágenes
- Estado de sincronización
- Timestamps de creación y modificación

### 2. **DraftPostManager** (`lib/core/data/local/draft_post_manager.dart`)
Servicio para gestionar borradores:
- Guardar/obtener/eliminar borradores
- Obtener borradores pendientes de sincronizar
- Actualizar estado de sincronización
- Persistencia en SharedPreferences

### 3. **DraftPostSyncService** (`lib/core/services/draft_post_sync_service.dart`)
Sincronizador de borradores a Firebase:
- Detección automática de conectividad
- Sincronización automática de borradores pendientes
- Subida de imágenes a Firebase Storage
- Manejo de errores con reintentos
- Logging detallado

### 4. **ConnectivityService** (`lib/core/services/connectivity_service.dart`)
Servicio para monitorear conectividad (mejorado):
- Stream de cambios de conectividad
- Comprobación del estado actual
- Compatible con nuevas versiones de `connectivity_plus`

## Flujo de Funcionamiento

### Caso 1: Usuario Online
1. Usuario llena el formulario y presiona "Enviar"
2. App detecta que hay conexión
3. Formulario se envía directamente a Firebase
4. Imágenes se suben a Cloud Storage
5. Se muestra mensaje: "Publicación creada exitosamente"

### Caso 2: Usuario Offline
1. Usuario llena el formulario y presiona "Enviar"
2. App detecta que NO hay conexión
3. Formulario se guarda como borrador localmente
4. Se muestra banner: "Modo offline: Se guardará como borrador"
5. Se muestra mensaje: "Se guardó la publicación para ser enviada cuando se recupere conexión"

### Caso 3: Reconexión
1. App recupera conexión a internet
2. DraftPostSyncService detecta conectividad
3. Se buscan borradores no sincronizados
4. Se inicia sincronización automática
5. Se muestra banner: "Sincronizando borradores..."
6. Cada borrador se envía a Firebase
7. Se marca como sincronizado
8. Si hay error, se guarda el error para reintentar

## Notificaciones de Estado

### En Modo Offline
- **Banner Naranja**: "Modo offline: Se guardará como borrador"
- **SnackBar Verde**: "Se guardó la publicación para ser enviada cuando se recupere conexión"

### Durante Sincronización
- **Banner Azul**: "Sincronizando borradores..."
- **SnackBar Azul**: "Publicando post..."

### Éxito
- **SnackBar Verde**: "Publicación creada exitosamente"

### Error
- **SnackBar Rojo**: "Error al guardar publicación: [detalles]"

## Estructura de Almacenamiento

### SharedPreferences (Local)
```json
{
  "draft_posts": [
    {
      "id": "uuid",
      "title": "Apartamento 2 habitaciones",
      "description": "...",
      "address": "...",
      "price": 1500000,
      "housingTagId": "HousingTag1",
      "amenityIds": ["Amenity1", "Amenity2"],
      "localImagePaths": ["/path/to/image1.jpg", "/path/to/image2.jpg"],
      "createdAt": "2025-11-21T...",
      "lastModifiedAt": "2025-11-21T...",
      "isSyncing": false,
      "isSynced": false,
      "syncError": null,
      "remotePostId": null
    }
  ]
}
```

### Firebase (Remoto)
Se usa la misma estructura que antes, pero ahora se puede ser creada:
- Online inmediatamente
- Offline y luego sincronizada automáticamente

## Cómo Usar

### En el CreatePostPage
La integración está lista:
1. Inicialización automática de servicios en `initState`
2. Detección automática de conectividad
3. Guardado de borradores cuando no hay internet
4. Sincronización automática cuando se recupera conexión

### Métodos Principales

```dart
// Guardar como borrador
await _draftManager.saveDraft(draft);

// Obtener borradores pendientes
final pending = await _draftManager.getPendingSyncs();

// Iniciar sincronización manual
await _syncService.syncAllPending();

// Reintentar sincronización de un borrador
await _syncService.retrySyncDraft(draftId);
```

## Consideraciones de Seguridad

1. **Contraseñas No Almacenadas**: Las credenciales de usuario no se guardan
2. **Imágenes Locales**: Se almacenan rutas, no las imágenes en sí
3. **Encriptación**: SharedPreferences maneja encriptación nativa
4. **Limpieza**: Los borradores sincronizados se pueden eliminar

## Testing

Para probar la funcionalidad:

1. **Modo Offline**:
   - Desactiva WiFi y datos móviles
   - Intenta crear un post
   - Verifica que se guarde como borrador
   - Revisa los logs en `dart analyze`

2. **Sincronización**:
   - Activa internet nuevamente
   - La app debería sincronizar automáticamente
   - Verifica que el post aparezca en Firebase

3. **Errores**:
   - Intenta crear un post sin usuario autenticado
   - Verifica manejo de errores

## Próximas Mejoras Posibles

1. Notificación persistente durante sincronización
2. Mostrar lista de borradores en pantalla separada
3. Permitir editar borradores
4. Sincronización progresiva (no bloquear UI)
5. Compresión de imágenes antes de guardar localmente
6. Limpieza automática de borradores sincronizados después de X días

## Troubleshooting

**Problema**: Los borradores no se sincronizan
- Solución: Verifica que el usuario esté autenticado antes de conectar internet

**Problema**: Las imágenes no se suben
- Solución: Verifica que las rutas locales sean válidas y que los archivos existan

**Problema**: Errores en SharedPreferences
- Solución: Limpia los datos de la app y vuelve a intentar
