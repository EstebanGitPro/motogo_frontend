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
      ..registerFactory<EmailVerificationRepository>((c) =>
          EmailVerificationRepositoryImpl(
              remoteDataSource: c.resolve<EmailVerificationRemoteDataSource>()))
      ..registerFactory<EmailVerificationRemoteDataSource>(
          (c) => EmailVerificationRemoteDataSourceImpl())
      ..registerFactory((c) => VerifyEmailUseCase(
          repository: c.resolve<EmailVerificationRepository>()));
  }

  @override
  void _configureAuthFactories() {
    final KiwiContainer container = KiwiContainer();
    container
      ..registerFactory<RegisterRepository>(
          (c) => RegisterRepositoryImp(c.resolve<RegisterDataSource>()))
      ..registerFactory((c) => RegisterUseCase(c.resolve<RegisterRepository>()))
      ..registerFactory((c) => RegisterDataSource())
      ..registerFactory<LoginRepository>(
          (c) => LoginRepositoryImpl(c.resolve<LoginDataSource>()))
      ..registerFactory((c) => LoginUseCase(c.resolve<LoginRepository>()))
      ..registerFactory((c) => LoginDataSource())
      ..registerFactory<EditProfileRepository>((c) =>
          EditProfileRepositoryImpl(c.resolve<EditProfileRemoteDataSource>()))
      ..registerFactory(
          (c) => GetPersonUsecase(c.resolve<EditProfileRepository>()))
      ..registerFactory(
          (c) => UpdatePersonUsecase(c.resolve<EditProfileRepository>()))
      ..registerSingleton((c) => Client())
      ..registerFactory<EditProfileRemoteDataSource>(
          (c) => EditProfileRemoteDataSourceImpl(c.resolve<Client>()));
  }
}
