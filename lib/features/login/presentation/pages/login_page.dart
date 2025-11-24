import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:welhome/core/data/local/secure_session_manager.dart';
import 'package:welhome/features/home/presentation/pages/home_page.dart';
import 'package:welhome/features/register/presentation/pages/register_page.dart';
import 'dart:developer' as developer;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  late SecureSessionManager _sessionManager;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _sessionManager = SecureSessionManager();
    _initializeSessionManager();
    _checkConnectivity();
  }

  Future<void> _initializeSessionManager() async {
    try {
      await _sessionManager.initialize();
    } catch (e) {
      developer.log('Error initializing SecureSessionManager: $e');
    }
  }

  void _checkConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      final isOnline = result != ConnectivityResult.none;
      setState(() {
        _isOnline = isOnline;
      });
      if (_isOnline) {
        developer.log('Device is online');
      } else {
        developer.log('Device is offline');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        // Si hay internet, intentar login con Firebase
        if (_isOnline) {
          await _loginWithFirebase();
        } else {
          // Si no hay internet, intentar login offline
          await _loginOffline();
        }
      } catch (e) {
        developer.log('Login error: $e');
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loginWithFirebase() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Login exitoso con Firebase, guardar sesión
      final user = credential.user;
      if (user != null && mounted) {
        await _sessionManager.saveSession(
          userId: user.uid,
          email: user.email ?? '',
          isOwner: false,
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Bienvenido ${user.email}")),
          );

          // Navegar a Home
          _navigateToHome(user.uid);
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = "No existe un usuario con ese correo.";
      } else if (e.code == 'wrong-password') {
        message = "Contraseña incorrecta.";
      } else {
        message = "Error: ${e.message}";
      }
      if (mounted) {
        _showErrorSnackBar(message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error durante el login: $e');
      }
    }
  }

  Future<void> _loginOffline() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Verificar si las credenciales coinciden con datos offline guardados
    if (_sessionManager.verifyOfflineEmailAndPassword(
      email: email,
      password: password,
    )) {
      final offlineIdentity = _sessionManager.getOfflineIdentity();
      if (offlineIdentity != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Modo offline: Bienvenido ${offlineIdentity.email}"),
          ),
        );

        developer.log('Logged in offline with user: ${offlineIdentity.email}');
        _navigateToHome(offlineIdentity.userId);
      }
    } else {
      _showErrorSnackBar(
        'No hay conexión a internet y las credenciales no coinciden con datos guardados.\n'
        'Por favor, conéctate a internet para iniciar sesión por primera vez.',
      );
    }
  }

  void _navigateToHome(String userId) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(userId: userId),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      height: 220,
                      width: 220,
                      color: Colors.transparent,
                      child: Image.asset('android/app/assets/images/AzulLetra.png'),
                    ),
                    const SizedBox(height: 40),

                    // Banner de modo offline
                    if (!_isOnline)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          border: Border.all(color: Colors.orange, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.wifi_off, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Modo offline: Usa credenciales guardadas',
                                style: AppTextStyles.textSmall.copyWith(
                                  color: Colors.orange[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Campo correo
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: AppTextStyles.textSmall,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.violetBlue),
                        ),
                        prefixIcon: const Icon(Icons.email),
                        filled: true,
                        fillColor: AppColors.lavenderLight,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your email";
                        }
                        final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                        if (!emailRegex.hasMatch(value)) {
                          return "Email not valid";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: AppTextStyles.textSmall,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: AppColors.lavenderLight,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your password";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Botón "Olvidé mi contraseña"
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () async {
                          if (_emailController.text.isNotEmpty && _isOnline) {
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: _emailController.text.trim());
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Email de recuperación enviado.")),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                _showErrorSnackBar('Error al enviar email: $e');
                              }
                            }
                          } else if (!_isOnline && mounted) {
                            _showErrorSnackBar(
                              'No disponible en modo offline. Por favor, conéctate a internet.',
                            );
                          }
                        },
                        child: Text(
                          "Forgot Password?",
                          style: AppTextStyles.textRegular.copyWith(color: AppColors.violetBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botón Login
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.violetBlue,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text("Login", style: AppTextStyles.buttons),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Botón Registrarse
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isOnline
                            ? () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => const RegisterPage()));
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Register now",
                          style: AppTextStyles.textRegular.copyWith(color: AppColors.violetBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
