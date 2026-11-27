import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoginTab = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.length < 4) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'እባክዎ ትክክለኛ ኢሜይል እና ቢያንስ 4 ፊደል የይለፍ ቃል ያስገቡ።';
      });
      return;
    }

    bool success = false;
    if (_isLoginTab) {
      success = await AuthService.login(email: email, password: password);
    } else {
      success = await AuthService.register(
        name: _nameController.text.trim(),
        email: email,
        password: password,
        farmLocation: _locationController.text.trim(),
      );
    }

    setState(() => _isLoading = false);

    if (success) {
      widget.onLoginSuccess();
    } else {
      setState(() => _errorMessage = 'ስህተት ተከስቷል፡ እባክዎ እንደገና ይሞክሩ።');
    }
  }

  void _continueAsGuest() async {
    await AuthService.register(
      name: 'እንግዳ አርሶ አደር (Guest)',
      email: 'guest@coffee.et',
      password: 'guest',
      farmLocation: 'ኢትዮጵያ',
    );
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E5E3A).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco_rounded, size: 64, color: Color(0xFF1E5E3A)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Coffee Leaf Doctor',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A)),
                ),
                const Text('የቡና ቅጠል በሽታ መለያ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 28),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isLoginTab = true),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _isLoginTab ? const Color(0xFF1E5E3A) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'ግባ (Login)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _isLoginTab ? Colors.white : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _isLoginTab = false),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: !_isLoginTab ? const Color(0xFF1E5E3A) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'ተመዝገብ (Sign Up)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: !_isLoginTab ? Colors.white : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                          Text(_errorMessage!, style: TextStyle(color: Colors.red.shade800, fontSize: 12)),
                        if (!_isLoginTab) ...[
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'ሙሉ ስም',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'የእርሻ ቦታ (ለምሳሌ ጅማ፣ ሲዳማ)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'ኢሜይል',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'የይለፍ ቃል',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E5E3A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(_isLoginTab ? 'ግባ (Sign In)' : 'ይመዝገቡ (Create Account)'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _continueAsGuest,
                          child: const Text('እንደ እንግዳ ቀጥል (Guest Mode)', style: TextStyle(color: Colors.grey)),
                        ),
                      ],
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