import 'package:adotai/modules/password/password_controller.dart';
import 'package:adotai/shared/widgets/email_form_field.dart';
import 'package:adotai/shared/widgets/submit_button.dart';
import 'package:flutter/material.dart';

class PasswordPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _controller = PasswordController();

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
              Text(
                'Por favor, informe o E-mail associado a sua conta, que enviaremos um link para o mesmo com as instruções para troca de sua senha.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              EmailFormField(onSaved: _controller.setEmail),
              SizedBox(height: 40),
              SubmitButton(
                label: 'Enviar',
                onTap: () {
                  final state = _formKey.currentState;
                  if (state.validate()) {
                    state.save();
                    _controller.sendPasswordResetEmail();
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
