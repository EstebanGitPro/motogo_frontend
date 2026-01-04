import 'package:http/http.dart';
import 'package:kiwi/kiwi.dart';

// Core - User Session
import 'package:motogo_frontend/src/core/user/data/datasources/user_session_data_source.dart';
import 'package:motogo_frontend/src/core/user/data/repositories/user_session_repository_impl.dart';
import 'package:motogo_frontend/src/core/user/domain/repositories/user_session_repository.dart';

// Features - Edit Profile
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/get_person_usecase.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/update_person_usecase.dart';

// Features - Password Recovery
import 'package:motogo_frontend/src/features/password_recovery/data/datasources/email_verification_datasource.dart';
import 'package:motogo_frontend/src/features/password_recovery/data/repositories/email_verification_repository_impl.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/repositories/email_verification_repository.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/usecases/verify_email_usecase.dart';

// Features - Login
import 'package:motogo_frontend/src/features/login/data/datasources/login_data_source.dart';
import 'package:motogo_frontend/src/features/login/data/repositories/login_repository_impl.dart';
import 'package:motogo_frontend/src/features/login/domain/repositories/login_repository.dart';
import 'package:motogo_frontend/src/features/login/domain/usecases/login_usecase.dart';

// Features - Register
import 'package:motogo_frontend/src/features/register_person/data/datasources/register_person_data_source.dart';
import 'package:motogo_frontend/src/features/register_person/data/repositories/register_repository_impl.dart';
import 'package:motogo_frontend/src/features/register_person/domain/repositories/register_person_repository.dart';
import 'package:motogo_frontend/src/features/register_person/domain/usecases/register_person_usecase.dart';

// Features - Change Password
import 'package:motogo_frontend/src/features/change_password/data/datasources/change_password_data_source.dart';
import 'package:motogo_frontend/src/features/change_password/data/repositories/change_password_repository_impl.dart';
import 'package:motogo_frontend/src/features/change_password/domain/repositories/change_password_repository.dart';
import 'package:motogo_frontend/src/features/change_password/domain/usecases/change_password_usecase.dart';

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

  // Core - HTTP Client and User Session (centralized)
  @Register.singleton(Client)
  @Register.factory(UserSessionDataSource, from: UserSessionDataSourceImpl)
  @Register.factory(UserSessionRepository, from: UserSessionRepositoryImpl)
  void _configureCoreFactories();

  // Features - Login, Register, Edit Profile, Password Recovery
  @Register.factory(RegisterPersonRepository, from: RegisterPersonRepositoryImp)
  @Register.factory(RegisterPersonUseCase)
  @Register.factory(RegisterPersonDataSource)
  @Register.factory(LoginRepository, from: LoginRepositoryImpl)
  @Register.factory(LoginUseCase)
  @Register.factory(LoginDataSource)
  @Register.factory(GetPersonUsecase)
  @Register.factory(UpdatePersonUsecase)
  @Register.factory(
    EmailRecoveryVerificationRepository,
    from: EmailRecoveryVerificationRepositoryImpl,
  )
  @Register.factory(VerifyRecoveryEmailUseCase)
  @Register.factory(EmailRecoveryVerificationDataSource)
  @Register.factory(
    ChangePasswordRepository,
    from: ChangePasswordRepositoryImpl,
  )
  @Register.factory(ChangePasswordUseCase)
  @Register.factory(
    ChangePasswordDataSource,
    from: ChangePasswordDataSourceImpl,
  )
  void _configureAuthFactories();
}
