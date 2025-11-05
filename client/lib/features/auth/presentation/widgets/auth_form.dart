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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!widget.isLogin)
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Họ và tên',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (!widget.isLogin && (value == null || value.isEmpty)) {
                  return 'Vui lòng nhập họ và tên';
                }
                return null;
              },
            ),
          if (!widget.isLogin) const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
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
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu',
              border: OutlineInputBorder(),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: Text(widget.isLogin ? 'Đăng nhập' : 'Đăng ký'),
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
        initialValue: _gender,
        decoration: const InputDecoration(
          labelText: 'Giới tính',
          border: OutlineInputBorder(),
        ),
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
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Tuổi',
          border: OutlineInputBorder(),
        ),
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
        decoration: const InputDecoration(
          labelText: 'Nghề nghiệp',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _preferencesController,
        decoration: const InputDecoration(
          labelText: 'Sở thích (phân cách bằng dấu phẩy)',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _budgetController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Ngân sách',
          border: OutlineInputBorder(),
        ),
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