import 'package:chat_app/helper/helper_function.dart';
import 'package:chat_app/pages/auth/login_page.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  bool _isLoading = false;
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullName = "";
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
                  "Crie sua conta para conversar e descobrir", 
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
                Image.asset("assets/register.png"),
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                    labelText: "Nome completo",
                    prefixIcon: Icon(Icons.person, color: Theme.of(context).primaryColor,)
                  ),
                  onChanged: (val){
                    setState(() {
                      fullName = val;
                    });
                  },

                  // check the validation

                  validator: (val){
                    if(val!.isNotEmpty){
                      return null;
                    }else{
                      return "Nome não pode ser nulo";
                    }
                  },

                ),
                const SizedBox(height: 15),
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
                    child: const Text("Cadastrar", 
                      style: TextStyle(color: Colors.white, fontSize: 17  ),
                    ),
                    onPressed: () {
                      register();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    text: "Já tem uma conta?  ",
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Entre agora",
                        style: const TextStyle(
                          color: Colors.black, 
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          nextScreen(context, const LoginPage());
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

  register() async {
    if(formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
        .registerUserWithEmailandPassword(fullName, email, password)
        .then((value) async {
          if(value == true){
            // savind the shared preferences state

            await HelperFunctions.saveUserLoggedInStatus(true);
            await HelperFunctions.saveUserEmailSF(email);
            await HelperFunctions.saveUserNameSF(fullName);
            
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