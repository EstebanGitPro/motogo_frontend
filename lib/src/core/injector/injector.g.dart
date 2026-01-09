// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'injector.dart';

// **************************************************************************
// KiwiInjectorGenerator
// **************************************************************************

class _$InjectorApp extends InjectorApp {
  @override
  void _configureCoreFactories() {
    final KiwiContainer container = KiwiContainer();
    container
      ..registerFactory<UserSessionRepository>(
          (c) => UserSessionRepositoryImpl(c.resolve<UserSessionDataSource>()))
      ..registerFactory<CatalogsRepository>(
          (c) => CatalogsRepositoryImpl(c.resolve<CatalogsDataSource>()));
  }

  @override
  void _configureAuthFactories() {
    final KiwiContainer container = KiwiContainer();
    container
      ..registerFactory<RegisterPersonRepository>((c) =>
          RegisterPersonRepositoryImp(c.resolve<RegisterPersonDataSource>()))
      ..registerFactory(
          (c) => RegisterPersonUseCase(c.resolve<RegisterPersonRepository>()))
      ..registerFactory((c) => RegisterPersonDataSource())
      ..registerFactory<LoginRepository>(
          (c) => LoginRepositoryImpl(c.resolve<LoginDataSource>()))
      ..registerFactory((c) => LoginUseCase(c.resolve<LoginRepository>()))
      ..registerFactory(
          (c) => LoginDataSource(c.resolve<UserSessionDataSource>()))
      ..registerFactory(
          (c) => GetPersonUsecase(c.resolve<UserSessionRepository>()))
      ..registerFactory(
          (c) => UpdatePersonUsecase(c.resolve<UserSessionRepository>()))
      ..registerFactory<EmailRecoveryVerificationRepository>((c) =>
          EmailRecoveryVerificationRepositoryImpl(
              c.resolve<EmailRecoveryVerificationDataSource>()))
      ..registerFactory((c) => VerifyRecoveryEmailUseCase(
          c.resolve<EmailRecoveryVerificationRepository>()))
      ..registerFactory<ChangePasswordRepository>((c) =>
          ChangePasswordRepositoryImpl(c.resolve<ChangePasswordDataSource>()))
      ..registerFactory(
          (c) => ChangePasswordUseCase(c.resolve<ChangePasswordRepository>()))
      ..registerFactory<BranchRepository>(
          (c) => BranchRepositoryImpl(c.resolve<RegisterBranchDataSource>()))
      ..registerFactory(
          (c) => RegisterBranchUseCase(c.resolve<BranchRepository>()))
      ..registerFactory<MyBranchesRepository>(
          (c) => MyBranchesRepositoryImpl(c.resolve<MyBranchesDataSource>()))
      ..registerFactory(
          (c) => GetBranchesUseCase(c.resolve<MyBranchesRepository>()));
  }
}
