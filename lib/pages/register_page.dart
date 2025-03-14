import 'package:bwoken/auth/auth_service.dart';
import 'package:bwoken/components/my_button.dart';
import 'package:bwoken/components/my_textield.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  final void Function()? onTap;

  RegisterPage({super.key, this.onTap});

  void register(BuildContext context) async {
    //auth service
    final auth = AuthService();

    if (_passwordController.text == _confirmpasswordController.text) {
      try {
        await auth.signUpWithEmailPassword(
            _emailController.text, _passwordController.text);
      } catch (e) {
        showDialog(
            context: context,
            builder: ((context) => AlertDialog(
                  title: Text(e.toString()),
                )));
      }
    } else {
      showDialog(
          context: context,
          builder: ((context) => const AlertDialog(
                title: Text('password does not match'),
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Positioned(
              top: 10,
              left: 230,
              child: Container(
                width: 38,
                height: 30,
                decoration: BoxDecoration(
                    color: Colors.lightGreen, shape: BoxShape.circle),
              )),
          Positioned(
              top: 10,
              left: 270,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                    color: Colors.lightGreen, shape: BoxShape.circle),
              )),
          Positioned(
              bottom: 100,
              right: 280,
              child: Container(
                width: 38,
                height: 30,
                decoration: BoxDecoration(
                    color: Colors.lightGreen, shape: BoxShape.circle),
              )),
          Positioned(
              bottom: 10,
              right: 320,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    color: Colors.lightGreen, shape: BoxShape.circle),
              )),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CREATE ACCOUNT',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  MyTextield(
                    hintText: 'EMAIL',
                    icon: const Icon(Icons.mail_outline),
                    controller: _emailController,
                    obsecuredText: false,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyTextield(
                    hintText: 'PASSWORD',
                    icon: const Icon(Icons.lock_outline),
                    controller: _passwordController,
                    obsecuredText: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyTextield(
                    hintText: 'CONFIRM PASSWORD',
                    icon: const Icon(Icons.lock_outline),
                    controller: _confirmpasswordController,
                    obsecuredText: true,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  MyButton(
                    text: 'REGISTER',
                    onPressed: () => register(context),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Arleady have an account?'),
                      GestureDetector(
                        onTap: onTap,
                        child: Text(
                          'Login Now',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightGreen),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
