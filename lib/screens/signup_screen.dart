import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class Dependent {
  String name;
  String role;
  Dependent({this.name = '', this.role = ''});
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _monthlyIncomeController = TextEditingController();
  final _totalFamilyIncomeController = TextEditingController();
  final _numDependentsController = TextEditingController(text: '0');

  List<Dependent> _dependents = [];

  final List<String> _roles = ['Father', 'Mother', 'Son', 'Daughter', 'Other', 'Individual'];
  String? _selectedRole;

  final List<String> _budgetTypes = ['Individual', 'Family', 'Monthly', 'Quarterly', 'Yearly'];
  String _selectedBudgetType = 'Individual';

  bool _showPassword = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _numDependentsController.addListener(_updateDependentsList);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _monthlyIncomeController.dispose();
    _totalFamilyIncomeController.dispose();
    _numDependentsController.removeListener(_updateDependentsList);
    _numDependentsController.dispose();
    super.dispose();
  }

  void _updateDependentsList() {
    if (_selectedRole == 'Individual') {
      if (_dependents.isNotEmpty) {
        setState(() => _dependents.clear());
      }
      return;
    }
    final count = int.tryParse(_numDependentsController.text) ?? 0;
    setState(() {
      if (count < 0) return;
      if (count < _dependents.length) {
        _dependents = _dependents.sublist(0, count);
      } else {
        while (_dependents.length < count) {
          _dependents.add(Dependent());
        }
      }
    });
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Minimum 8 characters required';
    if (!RegExp(r'[A-Z]').hasMatch(password)) return 'At least one uppercase letter required';
    if (!RegExp(r'[a-z]').hasMatch(password)) return 'At least one lowercase letter required';
    if (!RegExp(r'\d').hasMatch(password)) return 'At least one number required';
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) return 'At least one special character required';
    return null;
  }

  String? _validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(phone)) return 'Phone number must be exactly 10 digits';
    return null;
  }

  bool _validateDependents() {
    for (var dep in _dependents) {
      if (dep.name.trim().isEmpty || dep.role.trim().isEmpty) return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select role in family')));
      return;
    }

    if (_confirmPasswordController.text != _passwordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (_selectedRole != 'Individual') {
      if (_numDependentsController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter number of dependents')));
        return;
      }

      if (!_validateDependents()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill all dependents fields')));
        return;
      }
    }

    if (_selectedRole == 'Individual') {
      _totalFamilyIncomeController.clear();
      _numDependentsController.text = '0';
      _dependents.clear();
      _selectedBudgetType = 'Individual';
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate network call
    setState(() => _loading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => WelcomeScreen(name: _fullNameController.text.trim())),
    );
  }

  Widget _buildDependentTile(int index) {
    var dep = _dependents[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              initialValue: dep.name,
              decoration: const InputDecoration(
                labelText: "Dependent Name",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => dep.name = val,
              validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: dep.role,
              decoration: const InputDecoration(
                labelText: "Dependent Role",
                prefixIcon: Icon(Icons.work_outline),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => dep.role = val,
              validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    _dependents.removeAt(index);
                    _numDependentsController.text = _dependents.length.toString();
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFD),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 490),
            child: Card(
              elevation: 18,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              color: Colors.white.withOpacity(0.95),
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/signup_logo.png', height: 80),
                    const SizedBox(height: 10),
                    const Text(
                      "Create Account",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.4, color: Color(0xff222831)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Use proper information to continue",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 25),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _fullNameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline),
                              hintText: "Full Name",
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? "Full Name is required" : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.account_circle_outlined),
                              hintText: "Username",
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? "Username is required" : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined),
                              hintText: "Email address",
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return "Email is required";
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(val.trim())) return "Invalid email format";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.phone),
                              hintText: "Phone Number",
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            ),
                            validator: _validatePhone,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              hintText: "Password",
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                              suffixIcon: IconButton(
                                icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                                onPressed: () => setState(() => _showPassword = !_showPassword),
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline),
                              hintText: "Confirm Password",
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return "Confirm password is required";
                              if (val != _passwordController.text) return "Passwords do not match";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Role in Family",
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedRole,
                            hint: const Text("Select Role"),
                            items: _roles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedRole = val;
                                if (_selectedRole == 'Individual') {
                                  _selectedBudgetType = 'Individual';
                                  _dependents.clear();
                                  _numDependentsController.text = '0';
                                  _totalFamilyIncomeController.clear();
                                }
                              });
                            },
                            validator: (val) => val == null ? "Please select a role" : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _monthlyIncomeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.monetization_on_outlined),
                              hintText: "Monthly Income",
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return "Monthly income is required";
                              if (double.tryParse(val.trim()) == null) return "Enter a valid number";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _totalFamilyIncomeController,
                            keyboardType: TextInputType.number,
                            enabled: _selectedRole != 'Individual',
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.family_restroom_outlined),
                              hintText: "Total Family Income (Optional)",
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                              filled: _selectedRole == 'Individual',
                              fillColor: Colors.grey.shade200,
                            ),
                            validator: (val) {
                              if (_selectedRole != 'Individual' && val != null && val.trim().isNotEmpty) {
                                if (double.tryParse(val.trim()) == null) return "Enter a valid number";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _numDependentsController,
                            keyboardType: TextInputType.number,
                            enabled: _selectedRole != 'Individual',
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.group_outlined),
                              hintText: "Number of Dependents",
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                              filled: _selectedRole == 'Individual',
                              fillColor: Colors.grey.shade200,
                            ),
                            validator: (val) {
                              if (_selectedRole == 'Individual') return null;
                              if (val == null || val.trim().isEmpty) return "Enter number of dependents";
                              if (int.tryParse(val.trim()) == null || int.parse(val.trim()) < 0) return "Enter valid number";
                              if (int.tryParse(val.trim()) != _dependents.length) return "Dependents list count mismatch";
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: "Budget Type",
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedBudgetType,
                            items: _budgetTypes.map((bt) => DropdownMenuItem(value: bt, child: Text(bt))).toList(),
                            onChanged: _selectedRole == 'Individual'
                                ? null
                                : (val) {
                                    if (val != null) setState(() => _selectedBudgetType = val);
                                  },
                            disabledHint: Text(_selectedBudgetType),
                          ),
                          const SizedBox(height: 16),
                          if (_selectedRole != 'Individual' && _dependents.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text("Dependents",
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _dependents.add(Dependent());
                                          _numDependentsController.text = _dependents.length.toString();
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text("Add"),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ..._dependents.asMap().entries.map((entry) => _buildDependentTile(entry.key)).toList(),
                              ],
                            ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Create Account"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff2196F3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 7,
                                textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
