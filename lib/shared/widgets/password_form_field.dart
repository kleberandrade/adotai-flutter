import 'package:flutter/material.dart';

class PasswordFormField extends StatelessWidget {
  final Function(String) onSaved;

  const PasswordFormField({
    Key key,
    this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: false,
      decoration: InputDecoration(
        labelText: 'Senha',
        filled: true,
        border: InputBorder.none,
      ),
      onSaved: onSaved,
    );
  }
}
