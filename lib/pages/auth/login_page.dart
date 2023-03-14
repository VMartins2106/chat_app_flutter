import 'package:chat_app/pages/auth/register_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../helper/helper_function.dart';
import '../home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
      ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)) 
      : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "USJT Grupos",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Entre agora para descobrir o que estão falando!", 
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
                Image.asset("assets/login.png"),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor,)
                  ),
                  onChanged: (val){
                    setState(() {
                      email = val;
                    });
                  },

                  // check the validation

                  validator: (val){
                    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(val!) ? null : "Coloque um email válido";
                  },

                ),
                const SizedBox(height: 15),
                TextFormField(
                  obscureText: true,
                  decoration: textInputDecoration.copyWith(
                    labelText: "Senha",
                    prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor,)
                  ),
                  validator: (val){
                    if(val!.length < 6){
                      return "A senha deve ter no mínimo 6 caracteres";
                    } else{
                      return null;
                    }
                  },
                onChanged: (val){
                  setState(() {
                      password = val;
                    });
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                    ),
                    child: const Text("Entrar", 
                      style: TextStyle(color: Colors.white, fontSize: 17  ),
                    ),
                    onPressed: () {
                      login();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    text: "Não tem uma conta?  ",
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Registre-se aqui",
                        style: const TextStyle(
                          color: Colors.black, 
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          nextScreen(context, const RegisterPage());
                        }
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  login() async {
    if(formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
        .loginWithUserEmailandPassword(email, password)
        .then((value) async {
          if(value == true){
            // savind the shared preferences state

            QuerySnapshot snapshot = await DatabaseService(
              uid: FirebaseAuth.instance.currentUser!.uid)
                .gettingUserData(email);

            // saving the values to out SHARED PREFERENCES

            await HelperFunctions.saveUserLoggedInStatus(true);
            await HelperFunctions.saveUserEmailSF(email);
            await HelperFunctions.saveUserNameSF(snapshot.docs[0]['fullName']);

            nextScreenReplace(context, const HomePage());

          }
          else{
            showSnackBar(context, Colors.red, value);
            setState(() {
              _isLoading = false;
            });
          }
        });
    }
  }

}