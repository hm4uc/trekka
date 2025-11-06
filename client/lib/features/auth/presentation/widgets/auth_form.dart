import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final bool isLogin;
  final Function(
    String email,
    String password,
    String fullName,
    String? gender,
    int? age,
    String? job,
    List<String>? preferences,
    double? budget,
  ) onSubmit;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.onSubmit,
  });

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  String? _gender;
  final _ageController = TextEditingController();
  final _jobController = TextEditingController();
  final _preferencesController = TextEditingController();
  final _budgetController = TextEditingController();
  bool _obscurePassword = true;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;
      final fullName = _fullNameController.text;
      final gender = _gender;
      final age = _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : null;
      final job = _jobController.text.isNotEmpty ? _jobController.text : null;
      final preferences = _preferencesController.text.isNotEmpty
          ? _preferencesController.text.split(',').map((e) => e.trim()).toList()
          : null;
      final budget = _budgetController.text.isNotEmpty ? double.tryParse(_budgetController.text) : null;

      widget.onSubmit(
        email,
        password,
        fullName,
        gender,
        age,
        job,
        preferences,
        budget,
      );
    }
  }

  InputDecoration _getInputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.isLogin) ...[
            TextFormField(
              controller: _fullNameController,
              decoration: _getInputDecoration('Họ và tên', icon: Icons.person),
              validator: (value) {
                if (!widget.isLogin && (value == null || value.isEmpty)) {
                  return 'Vui lòng nhập họ và tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _emailController,
            decoration: _getInputDecoration('Email', icon: Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _getInputDecoration(
              'Mật khẩu',
              icon: Icons.lock,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
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
                return 'Vui lòng nhập mật khẩu';
              }
              if (value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự';
              }
              return null;
            },
          ),
          if (!widget.isLogin) ..._buildRegisterFields(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.isLogin ? 'Đăng nhập' : 'Đăng ký',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRegisterFields() {
    return [
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        value: _gender,
        decoration: _getInputDecoration('Giới tính', icon: Icons.people),
        items: ['male', 'female', 'other']
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender == 'male'
                      ? 'Nam'
                      : gender == 'female'
                          ? 'Nữ'
                          : 'Khác'),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _gender = value;
          });
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _ageController,
        decoration: _getInputDecoration('Tuổi', icon: Icons.cake),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final age = int.tryParse(value);
            if (age == null || age < 1 || age > 120) {
              return 'Tuổi phải từ 1 đến 120';
            }
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _jobController,
        decoration: _getInputDecoration('Nghề nghiệp', icon: Icons.work),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _preferencesController,
        decoration: _getInputDecoration(
          'Sở thích (phân cách bằng dấu phẩy)',
          icon: Icons.favorite,
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _budgetController,
        decoration: _getInputDecoration('Ngân sách', icon: Icons.attach_money),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final budget = double.tryParse(value);
            if (budget == null || budget < 0) {
              return 'Ngân sách phải là số dương';
            }
          }
          return null;
        },
      ),
    ];
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    _jobController.dispose();
    _preferencesController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}