import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Si llega aquí, el login fue exitoso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bienvenido ${credential.user?.email}")),
        );

        // Aquí puedes navegar a tu HomePage
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));

      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = "No existe un usuario con ese correo.";
        } else if (e.code == 'wrong-password') {
          message = "Contraseña incorrecta.";
        } else {
          message = "Error: ${e.message}";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        setState(() => _loading = false);
      }
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
                      if (_emailController.text.isNotEmpty) {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: _emailController.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Email de recuperación enviado.")),
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
                    onPressed: () {
                      // Aquí navegas a tu pantalla de registro
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
                    },
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
    );
  }
}
