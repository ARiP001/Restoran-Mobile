import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latihan_responsi/restoran_list.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  // bool _isObscure = true;

  Future<List<Map<String, String>>> _getAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsString = prefs.getStringList('accounts') ?? [];
    return accountsString.map((e) {
      final parts = e.split('||');
      return {'username': parts[0], 'password': parts[1]};
    }).toList();
  }

  Future<void> _saveAccount(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final accountsString = prefs.getStringList('accounts') ?? [];
    accountsString.add('$username||$password');
    await prefs.setStringList('accounts', accountsString);
  }

  Future<void> saveLoginState(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', username);
  }
  
  // Validate login
  void validateLogin() async {
    if (_formkey.currentState!.validate()) {
      final inputUsername = _username.text;
      final inputPassword = _password.text;
      final accounts = await _getAccounts();
      final account = accounts.firstWhere(
        (account) =>
            account['username'] == inputUsername &&
            account['password'] == inputPassword,
        orElse: () => {},
      );
      if (account.isNotEmpty) {
        await saveLoginState(inputUsername);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Berhasil')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return RestoranList(username: inputUsername);
        }));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username atau Password Salah')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formkey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child:SizedBox(
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // SizedBox(
                    //   height: 80,
                    //   child: Image.asset('assets/images/logo.png')
                    //   ),
                    Text(
                      'Selamat Datang di Aplikasi Restoran',
                      style: TextStyle(fontSize: 15),
                    ),
                    TextFormField(
                      
                      validator: (value){
                        if (value == null || value.isEmpty){
                          return "Username tidak boleh kosong";
                        }
                        return null;
                      },
                      controller: _username,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        prefixIconColor: Colors.blue,
                        border: OutlineInputBorder(),
                        labelText: "Username"
                      )
                    ),
                    TextFormField(
                      validator: (value){
                        if (value == null || value.isEmpty){
                          return "Password tidak boleh kosong";
                        }
                        return null;
                      },
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                         prefixIcon: Icon(Icons.lock),
                         prefixIconColor: Colors.blue,
                        border: OutlineInputBorder(),
                        labelText: "Password"
                      ),
                    ),
                    SizedBox(
                        child: ElevatedButton(
                        onPressed: validateLogin,
                        child: const Text('Login'),
                      ),
                      ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text('Belum punya akun? Register'),
                    ),
                  ],
                ),
              )
            )
          )
          ),
        ),
      ); 
  }
}