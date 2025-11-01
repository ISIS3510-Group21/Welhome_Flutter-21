import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:welhome/features/home/presentation/pages/home_page.dart';
import 'package:welhome/features/register/presentation/pages/register_page.dart';
import 'package:welhome/features/login/presentation/pages/auth_local_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await _checkConnectivity();

    try {
      // 🔴 SIN CONEXIÓN → intentar sesión local
      if (!_isConnected) {
        final hasSession = await AuthLocalService.hasSavedSession();
        final savedEmail = await AuthLocalService.getSavedEmail();

        if (hasSession && savedEmail == _emailController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Modo offline: sesión restaurada.")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomePage(userId: 'Profile_Student10'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sin conexión y sin sesión previa."),
            ),
          );
        }
        return;
      }

      // 🌐 CON CONEXIÓN → login con Firebase
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await AuthLocalService.saveUserSession(_emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bienvenido ${credential.user?.email}")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(userId: 'Profile_Student10'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "No existe un usuario con ese correo.";
          break;
        case 'wrong-password':
          message = "Contraseña incorrecta.";
          break;
        case 'network-request-failed':
          message = "Error de red. Verifica tu conexión a Internet.";
          break;
        default:
          message = "Error: ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error inesperado: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isConnected)
                  Container(
                    width: double.infinity,
                    color: Colors.redAccent,
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Sin conexión: usando modo offline",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),

                // Logo
                Container(
                  height: 220,
                  width: 220,
                  color: Colors.transparent,
                  child: Image.asset('android/app/assets/images/AzulLetra.png'),
                ),
                const SizedBox(height: 40),

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
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
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

                // Olvidé mi contraseña
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () async {
                      if (_emailController.text.isNotEmpty) {
                        await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: _emailController.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Email de recuperación enviado.")),
                        );
                      }
                    },
                    child: Text(
                      "Forgot Password?",
                      style: AppTextStyles.textRegular
                          .copyWith(color: AppColors.violetBlue),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterPage()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Register now",
                      style: AppTextStyles.textRegular
                          .copyWith(color: AppColors.violetBlue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
