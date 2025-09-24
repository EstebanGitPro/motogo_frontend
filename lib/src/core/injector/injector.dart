import 'package:http/http.dart';
import 'package:kiwi/kiwi.dart';
import 'package:motogo_frontend/src/features/edit_profile/data/datasources/edit_profile_data_source.dart';
import 'package:motogo_frontend/src/features/edit_profile/data/repositories/edit_profile_repository_impl.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/repositories/edit_profile_repository.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/get_person_usecase.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/update_person_usecase.dart'
    show UpdatePersonUsecase;
import 'package:motogo_frontend/src/features/password_recovery/data/datasources/code_validation_datasource.dart';
import 'package:motogo_frontend/src/features/password_recovery/data/datasources/email_verification_datasource.dart';
import 'package:motogo_frontend/src/features/password_recovery/data/datasources/password_reset_data_source.dart';
import 'package:motogo_frontend/src/features/password_recovery/data/repositories/code_validation_repository_impl.dart';
import 'package:motogo_frontend/src/features/password_recovery/data/repositories/email_verification_repository_impl.dart';
import 'package:motogo_frontend/src/features/password_recovery/data/repositories/password_reset_repository_impl.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/repositories/code_validation_repository.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/repositories/email_verification_repository.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/repositories/password_reset_repository.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/usecases/reset_password_usecase.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/usecases/validate_code_usecase.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/usecases/verify_email_usecase.dart';

import 'package:motogo_frontend/src/features/verify_email/data/datasources/email_verification_remote_data_source.dart';
import 'package:motogo_frontend/src/features/verify_email/data/repositories/email_verification_repository_impl.dart';
import 'package:motogo_frontend/src/features/verify_email/domain/repositories/email_verification_repository.dart';
import 'package:motogo_frontend/src/features/verify_email/domain/usecases/verify_email_usecase.dart';
import 'package:motogo_frontend/src/features/login/data/datasources/login_data_source.dart';
import 'package:motogo_frontend/src/features/login/data/repositories/login_repository_impl.dart';
import 'package:motogo_frontend/src/features/login/domain/repositories/login_repository.dart';
import 'package:motogo_frontend/src/features/login/domain/usecases/login_usecase.dart';
import 'package:motogo_frontend/src/features/register_person/data/datasources/register_person_data_source.dart';
import 'package:motogo_frontend/src/features/register_person/data/repositories/register_repository_impl.dart';
import 'package:motogo_frontend/src/features/register_person/domain/repositories/register_person_repository.dart';
import 'package:motogo_frontend/src/features/register_person/domain/usecases/register_person_usecase.dart';

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

 
  @Register.factory(RegisterPersonRepository, from: RegisterPersonRepositoryImp)
  @Register.factory(RegisterPersonUseCase)
  @Register.factory(RegisterPersonDataSource)
  @Register.factory(LoginRepository, from: LoginRepositoryImpl)
  @Register.factory(LoginUseCase)
  @Register.factory(LoginDataSource)
  @Register.factory(EditProfileRepository, from: EditProfileRepositoryImpl)
  @Register.factory(GetPersonUsecase)
  @Register.factory(UpdatePersonUsecase)
  @Register.singleton(Client)
  @Register.factory(
    EditProfileRemoteDataSource,
    from: EditProfileRemoteDataSourceImpl,
  )
  @Register.factory(
    CodeValidationRepository,
    from: CodeValidationRepositoryImpl,
  )
  @Register.factory(ValidateCodeUseCase)
  @Register.factory(CodeValidationDataSource)
  @Register.factory(
    EmailRecoveryVerificationRepository,
    from: EmailRecoveryVerificationRepositoryImpl,
  )
  @Register.factory(VerifyRecoveryEmailUseCase)
  @Register.factory(EmailRecoveryVerificationDataSource)
  @Register.factory(PasswordResetRepository, from: PasswordResetRepositoryImpl)
  @Register.factory(PasswordResetUseCase)
  @Register.factory(PasswordResetDataSource)
  void _configureAuthFactories();
}
