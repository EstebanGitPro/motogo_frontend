import 'package:http/http.dart';
import 'package:kiwi/kiwi.dart';
import 'package:motogo_frontend/src/features/edit_profile/data/datasources/edit_profile_data_source.dart';
import 'package:motogo_frontend/src/features/edit_profile/data/repositories/edit_profile_repository_impl.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/repositories/edit_profile_repository.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/get_person_usecase.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/update_person_usecase.dart'
    show UpdatePersonUsecase;

import 'package:motogo_frontend/src/features/verify_email/data/datasources/email_verification_remote_data_source.dart';
import 'package:motogo_frontend/src/features/verify_email/data/repositories/email_verification_repository_impl.dart';
import 'package:motogo_frontend/src/features/verify_email/domain/repositories/email_verification_repository.dart';
import 'package:motogo_frontend/src/features/verify_email/domain/usecases/verify_email_usecase.dart';
import 'package:motogo_frontend/src/features/login/data/datasources/login_data_source.dart';
import 'package:motogo_frontend/src/features/login/data/repositories/login_repository_impl.dart';
import 'package:motogo_frontend/src/features/login/domain/repositories/login_repository.dart';
import 'package:motogo_frontend/src/features/login/domain/usecases/login_usecase.dart';
import 'package:motogo_frontend/src/features/register/data/datasources/register_data_source.dart';
import 'package:motogo_frontend/src/features/register/data/repositories/register_repository_impl.dart';
import 'package:motogo_frontend/src/features/register/domain/repositories/register_repository.dart';
import 'package:motogo_frontend/src/features/register/domain/usecases/register_usecase.dart';


part 'injector.g.dart';

abstract class InjectorApp {
  static KiwiContainer container = KiwiContainer();
  static void setup() {
    var injector = _$InjectorApp();
    injector._configure();
  }

  static final resolve = container.resolve;

  void _configure() {
    _configureCore();
    _configureAuth();
  }

  void _configureCore() {
    _configureCoreFactories();
  }

  void _configureAuth() {
    _configureAuthFactories();
  }

  // Core
  @Register.factory(
    EmailVerificationRepository,
    from: EmailVerificationRepositoryImpl,
  )
  @Register.factory(
    EmailVerificationRemoteDataSource,
    from: EmailVerificationRemoteDataSourceImpl,
  )
  @Register.factory(VerifyEmailUseCase)
  void _configureCoreFactories();

  // Features
  @Register.factory(RegisterRepository, from: RegisterRepositoryImp)
  @Register.factory(RegisterUseCase)
  @Register.factory(RegisterDataSource)

  @Register.factory(LoginRepository, from: LoginRepositoryImpl)
  @Register.factory(LoginUseCase)
  @Register.factory(LoginDataSource)

  @Register.factory(EditProfileRepository, from: EditProfileRepositoryImpl)
  @Register.factory(GetPersonUsecase)
  @Register.factory(UpdatePersonUsecase)
  @Register.singleton(Client)  
  @Register.factory(EditProfileRemoteDataSource, from: EditProfileRemoteDataSourceImpl)
  void _configureAuthFactories();
}
