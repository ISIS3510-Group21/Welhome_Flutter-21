import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _gender;
  String? _nationality;
  String? _language;
  String _userType = "student"; // default
  String _phonePrefix = "+57";

  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      Timestamp birthDate = Timestamp.fromDate(DateTime(
        _selectedYear!,
        _selectedMonth!,
        _selectedDay!,
      ));

      Map<String, dynamic> userData = {
        "id": uid,
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text.trim(),
        "birthDate": birthDate,
        "gender": _gender,
        "nationality": _nationality,
        "language": _language,
        "phoneNumber": "$_phonePrefix ${_phoneController.text.trim()}",
        "photoPath": "",
      };

      // Guardar en Firestore
      final firestore = FirebaseFirestore.instance;

      if (_userType == "host") {
        userData["creationDate"] = FieldValue.serverTimestamp();

        await firestore.collection("OwnerUser").doc(uid).set(userData);
      } else {
        await firestore.collection("StudentUser").doc(uid).set(userData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User created successfully")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign In"),
        titleTextStyle: AppTextStyles.tittleMedium,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre
              Text("Name", style: AppTextStyles.tittleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.violetBlue,
                        width: 2,
                      )),
                  filled: true,
                  fillColor: AppColors.lavenderLight,
                ),
                validator: (value) => value!.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 16),

              // Email
              Text("Email", style: AppTextStyles.tittleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: AppColors.lavenderLight,
                ),
                validator: (value) =>
                    value!.isEmpty ? "Enter a valid email" : null,
              ),
              const SizedBox(height: 16),

              // Contraseña
              Text("Password", style: AppTextStyles.tittleSmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: AppColors.lavenderLight,
                ),
                validator: (value) =>
                    value!.length < 6 ? "At least 6 characters" : null,
              ),
              const SizedBox(height: 16),

              // Fecha de nacimiento
              Text("Birth Date", style: AppTextStyles.tittleSmall),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedDay,
                      decoration: InputDecoration(
                        hintText: "Day",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: AppColors.lavenderLight,
                      ),
                      items: List.generate(
                        31,
                        (i) => DropdownMenuItem(
                            value: i + 1, child: Text("${i + 1}")),
                      ),
                      onChanged: (val) => setState(() => _selectedDay = val),
                      validator: (val) => val == null ? "Choose a day" : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedMonth,
                      decoration: InputDecoration(
                        hintText: "Month",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: AppColors.lavenderLight,
                      ),
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                            value: i + 1, child: Text("${i + 1}")),
                      ),
                      onChanged: (val) => setState(() => _selectedMonth = val),
                      validator: (val) => val == null ? "Choose a month" : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedYear,
                      decoration: InputDecoration(
                        hintText: "Year",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: AppColors.lavenderLight,
                      ),
                      items: List.generate(
                        100,
                        (i) {
                          int year = DateTime.now().year - i;
                          return DropdownMenuItem(
                              value: year, child: Text("$year"));
                        },
                      ),
                      onChanged: (val) => setState(() => _selectedYear = val),
                      validator: (val) => val == null ? "Choose a year" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Teléfono
              Text("Phone number", style: AppTextStyles.tittleSmall),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: true,
                          onSelect: (Country country) {
                            setState(() {
                              _phonePrefix = "+${country.phoneCode}";
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.lavenderLight,
                        ),
                        child: Text(
                          _phonePrefix ?? "Prefix",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "Number",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: AppColors.lavenderLight,
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Enter number" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Género
              Text("Gender", style: AppTextStyles.tittleSmall),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  hintText: "Choose a gender",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: AppColors.lavenderLight,
                ),
                items: ["Male", "Female", "Other/Prefer not to say"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _gender = val),
                validator: (val) => val == null ? "Choose a gender" : null,
              ),
              const SizedBox(height: 16),

              // Nacionalidad
              Text("Nationality", style: AppTextStyles.tittleSmall),
              const SizedBox(height: 6),
              InkWell(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: false,
                    countryListTheme: CountryListThemeData(
                      borderRadius: BorderRadius.circular(12),
                      inputDecoration: InputDecoration(
                        labelText: 'Search country',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.lavenderLight,
                      ),
                    ),
                    onSelect: (Country country) {
                      setState(() {
                        _nationality = country.name;
                      });
                    },
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.violetBlue),
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.lavenderLight,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _nationality ?? "Choose nationality",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Lenguaje
              Text("Preferred Language", style: AppTextStyles.tittleSmall),
              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: _language,
                decoration: InputDecoration(
                  hintText: "Prefered Language",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.violetBlue)),
                  filled: true,
                  fillColor: AppColors.lavenderLight,
                ),
                items: [
                  {"code": "es", "name": "Español", "flag": "🇨🇴"},
                  {"code": "en", "name": "English", "flag": "🇺🇸"},
                  {"code": "fr", "name": "Française", "flag": "🇫🇷"},
                  {"code": "de", "name": "Duitse", "flag": "🇩🇪"},
                  {"code": "it", "name": "Italiano", "flag": "🇮🇹"},
                  {"code": "pt", "name": "Português", "flag": "🇧🇷"},
                  {"code": "zh", "name": "中文", "flag": "🇨🇳"},
                  {"code": "ja", "name": "日本語", "flag": "🇯🇵"},
                ]
                    .map((lang) => DropdownMenuItem(
                          value: lang["name"],
                          child: Row(
                            children: [
                              Text(lang["flag"]!),
                              const SizedBox(width: 8),
                              Text(lang["name"]!),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _language = val),
                validator: (val) => val == null ? "Seleccione lenguaje" : null,
              ),
              const SizedBox(height: 16),
              // Tipo de usuario
              Text("Tipo de usuario", style: AppTextStyles.tittleSmall),
              Column(
                children: [
                  RadioListTile(
                    title: const Text("Student"),
                    value: "student",
                    groupValue: _userType,
                    onChanged: (val) => setState(() => _userType = val!),
                  ),
                  RadioListTile(
                    title: const Text("Host"),
                    value: "host",
                    groupValue: _userType,
                    onChanged: (val) => setState(() => _userType = val!),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.violetBlue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Save user", style: AppTextStyles.buttons),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
