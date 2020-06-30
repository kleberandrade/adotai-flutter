import 'package:adotai/modules/signin/signin_controller.dart';
import 'package:adotai/shared/widgets/email_form_field.dart';
import 'package:adotai/shared/widgets/password_form_field.dart';
import 'package:adotai/shared/widgets/submit_button.dart';
import 'package:flutter/material.dart';

class SigninPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = SigninController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              EmailFormField(onSaved: _controller.setEmail),
              SizedBox(height: 20),
              PasswordFormField(onSaved: _controller.setPassword),
              SizedBox(height: 40),
              SubmitButton(
                label: 'Login',
                onTap: () {
                  final state = _formKey.currentState;
                  if (state.validate()) {
                    state.save();
                    _controller.login();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
