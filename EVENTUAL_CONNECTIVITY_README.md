# Estrategia de Eventual Connectivity - Login

## Descripción

Esta implementación permite que los usuarios inicien sesión en la aplicación incluso cuando el dispositivo no tiene conexión a internet, utilizando credenciales guardadas de sesiones anteriores.

## Componentes Principales

### 1. `SecureSessionManager` (`lib/core/data/local/secure_session_manager.dart`)

Gestor de sesión que utiliza SharedPreferences para almacenar datos de forma segura.

**Características:**
- Almacena datos de sesión activa (usuario, email, estado de propietario)
- Almacena identidad offline para login sin internet
- Encriptación automática de contraseñas (SharedPreferences maneja esto)
- Validación de sesión por expiración (30 días)
- Separación entre sesión activa e identidad offline

**Métodos Principales:**

```dart
// Inicializar antes de usar
await sessionManager.initialize();

// Guardar sesión después de login exitoso
await sessionManager.saveSession(
  userId: 'user123',
  email: 'user@example.com',
  isOwner: false,
  password: 'password123',
);

// Verificar credenciales offline
bool isValid = sessionManager.verifyOfflineEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Obtener identidad offline
OfflineIdentity? identity = sessionManager.getOfflineIdentity();

// Limpiar sesión (logout - preserva identidad offline)
await sessionManager.clearSession();

// Limpiar todo (cierre completo)
await sessionManager.clearAll();
```

### 2. `LoginPage` (`lib/features/login/presentation/pages/login_page.dart`)

Pantalla de login mejorada con soporte para eventual connectivity.

**Características:**
- Detección automática de estado de conectividad
- Login online con Firebase (con guardado de credenciales)
- Login offline usando credenciales guardadas
- Banner visual indicando modo offline
- Botón "Forgot Password" deshabilitado en modo offline
- Botón "Register" deshabilitado en modo offline

### 3. `ConnectivityService` (`lib/core/services/connectivity_service.dart`)

Servicio para monitorear cambios en la conectividad de la aplicación.

## Flujo de Funcionamiento

### Primer Login (Online)

1. Usuario ingresa email y contraseña
2. Aplicación verifica conectividad
3. Si hay internet:
   - Se intenta login con Firebase
   - Si es exitoso:
     - Credenciales y datos se guardan localmente
     - Usuario es redirigido a Home
     - Se muestra mensaje de bienvenida

### Logins Posteriores (Offline)

1. Usuario ingresa email y contraseña
2. Si no hay internet:
   - Se verifica si las credenciales coinciden con datos guardados
   - Si coinciden:
     - Usuario puede ingresar a la aplicación
     - Se muestra indicador de "Modo offline"
   - Si no coinciden:
     - Se muestra error pidiendo conectividad

### Actualización de Sesión

Cada vez que el usuario inicia sesión exitosamente online, sus credenciales se actualizan en el almacenamiento local.

## Consideraciones de Seguridad

1. **Contraseñas Encriptadas:** SharedPreferences cifra automáticamente los valores en Android
2. **Expiración de Sesión:** Las sesiones expiran después de 30 días
3. **Separación de Datos:** Los datos offline se guardan por separado de la sesión activa
4. **Cierre de Sesión:** El logout limpia la sesión pero preserva la identidad offline

## Cómo Usar en Otras Pantallas

Para verificar si el usuario tiene sesión válida o datos offline:

```dart
import 'package:welhome/core/data/local/secure_session_manager.dart';

final sessionManager = SecureSessionManager();
await sessionManager.initialize();

// Verificar sesión activa
if (sessionManager.hasValidSession()) {
  final session = sessionManager.getSession();
  print('Usuario: ${session?.email}');
}

// Verificar datos offline
if (sessionManager.hasOfflineData()) {
  final offline = sessionManager.getOfflineIdentity();
  print('Identidad offline: ${offline?.email}');
}
```

## Cambios Realizados

1. **Creado:** `lib/core/data/local/secure_session_manager.dart`
   - Gestión completa de sesiones y credenciales offline

2. **Modificado:** `lib/features/login/presentation/pages/login_page.dart`
   - Integración de eventual connectivity
   - Detección de estado online/offline
   - Lógica de login online y offline
   - UI mejorada con indicadores visuales

3. **Creado:** `lib/core/services/connectivity_service.dart`
   - Servicio para monitorear conectividad

## Dependencias Necesarias

Las siguientes dependencias ya están en `pubspec.yaml`:
- `shared_preferences: ^2.5.3` ✓
- `connectivity_plus: ^7.0.0` ✓
- `firebase_auth: 6.1.0` ✓

## Próximos Pasos

1. Prueba la funcionalidad desactivando WiFi/datos del dispositivo
2. Inicia sesión online primero para guardar credenciales
3. Desactiva internet y verifica que puedas iniciar sesión offline
4. Vuelve a conectar y verifica que el login online siga funcionando

## Troubleshooting

Si no puedes hacer login offline:
1. Verifica que hayas iniciado sesión exitosamente al menos una vez online
2. Revisa los logs para ver si hay errores en la inicialización del SecureSessionManager
3. Comprueba que las credenciales sean exactamente iguales (incluyendo mayúsculas/minúsculas)
4. Limpia datos de la app y vuelve a intentar desde cero
