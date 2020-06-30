import 'package:adotai/modules/password/password_repository.dart';
import 'package:mobx/mobx.dart';
part 'password_controller.g.dart';

class PasswordController = _PasswordControllerBase with _$PasswordController;

abstract class _PasswordControllerBase with Store {
  PasswordRepository _repository;

  _PasswordControllerBase() {
    _repository = PasswordRepository();
  }

  @observable
  String email;

  @action
  void setEmail(value) => email = value;

  @action
  Future sendPasswordResetEmail() async {
    await _repository.sendPasswordResetEmail(email: email);
  }
}
