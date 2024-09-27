import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_in405109/main.dart';
import 'signup_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({Key? key}) : super(key: key);

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _signin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        Navigator.pushReplacement(
            // context, MaterialPageRoute(builder: (context) => const TodoApp()));
            context,
            MaterialPageRoute(builder: (context) => const ExpenseTrackerApp()));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Sign in failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50], // สีพื้นหลัง
      appBar: AppBar(
        title: const Text(
          'TODO',
          style: TextStyle(
            fontSize: 24, // ขนาดตัวอักษร
            fontWeight: FontWeight.bold, // ตัวหนา
          ),
        ),
        centerTitle: true, // จัดตำแหน่งข้อความตรงกลาง
        backgroundColor: const Color(0xFF03a9f4), // สีแถบด้านบน
      ),
      body: Center(
        child: Container(
          width: 320, // กำหนดความกว้าง แต่ลบความสูงออกเพื่อให้อัตโนมัติ
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white, // สีพื้นหลังของฟอร์ม
            borderRadius: BorderRadius.circular(20.0), // ขอบโค้ง
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // แรเงา
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TODO',
                style: TextStyle(
                  fontSize: 40, // ขนาดตัวอักษรของ "TODO"
                  fontWeight: FontWeight.bold, // ตัวหนา
                  color: Color.fromARGB(255, 0, 0, 0), // สีของข้อความ
                ),
              ),
              const SizedBox(height: 20), // ระยะห่างระหว่าง "TODO" และฟอร์ม
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your email' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter your password' : null,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // จัดให้อยู่ตรงกลาง
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20.0), // ขอบปุ่มโค้ง
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignupScreen()));
                          },
                          child: const Text(
                            'Sign Up',
                            style:
                                TextStyle(fontSize: 18), // ขนาดตัวอักษรในปุ่ม
                          ),
                        ),
                        const SizedBox(width: 20), // ระยะห่างระหว่างปุ่ม
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20.0), // ขอบปุ่มโค้ง
                            ),
                          ),
                          onPressed: _signin,
                          child: const Text(
                            'Sign In',
                            style:
                                TextStyle(fontSize: 18), // ขนาดตัวอักษรในปุ่ม
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
