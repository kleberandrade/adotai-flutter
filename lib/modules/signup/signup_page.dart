import 'package:adotai/modules/signup/signup_controller.dart';
import 'package:adotai/shared/widgets/email_form_field.dart';
import 'package:adotai/shared/widgets/password_form_field.dart';
import 'package:adotai/shared/widgets/submit_button.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = SignupController();

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
                label: 'Registrar',
                onTap: () {
                  final state = _formKey.currentState;
                  if (state.validate()) {
                    state.save();
                    _controller.createUser();
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