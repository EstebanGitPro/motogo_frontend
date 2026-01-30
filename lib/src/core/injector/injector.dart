import 'package:kiwi/kiwi.dart';

// Core - Network (Dio)
import 'package:motogo_frontend/src/core/network/auth_interceptor.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/refresh_token_data_source.dart';

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

// Features - Register Branch
import 'package:motogo_frontend/src/features/register_branch/data/datasources/register_branch_data_source.dart';
import 'package:motogo_frontend/src/features/register_branch/data/repositories/branch_repository_impl.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/repositories/branch_repository.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/usecases/register_branch_usecase.dart';

// Features - Edit Branch
import 'package:motogo_frontend/src/features/edit_branch/data/datasources/edit_branch_data_source.dart';
import 'package:motogo_frontend/src/features/edit_branch/domain/usecases/update_branch_usecase.dart';

// Features - Branch Services
import 'package:motogo_frontend/src/features/branch_services/data/datasources/branch_services_datasource.dart';

// Features - Delete Branch
import 'package:motogo_frontend/src/features/delete_branch/data/datasources/delete_branch_data_source.dart';
import 'package:motogo_frontend/src/features/delete_branch/domain/repositories/delete_branch_repository.dart';
import 'package:motogo_frontend/src/features/delete_branch/domain/usecases/delete_branch_usecase.dart';

// Features - Delete Person
import 'package:motogo_frontend/src/features/delete_person/data/datasources/delete_person_data_source.dart';
import 'package:motogo_frontend/src/features/delete_person/domain/repositories/delete_person_repository.dart';
import 'package:motogo_frontend/src/features/delete_person/domain/usecases/delete_person_usecase.dart';

// Features - My Branches
import 'package:motogo_frontend/src/features/my_branches/data/datasources/my_branches_data_source.dart';
import 'package:motogo_frontend/src/features/my_branches/data/repositories/my_branches_repository_impl.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/repositories/my_branches_repository.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';

// Features - Register Franchise
import 'package:motogo_frontend/src/features/register_franchise/data/datasources/register_franchise_data_source.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/repositories/franchise_repository_impl.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/repositories/franchise_repository.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/usecases/register_franchise_usecase.dart';

// Features - Manage Franchise
import 'package:motogo_frontend/src/features/manage_franchise/data/datasources/franchise_data_source.dart';
import 'package:motogo_frontend/src/features/manage_franchise/domain/usecases/franchise_usecases.dart';

// Core - Catalogs
import 'package:motogo_frontend/src/core/catalogs/data/datasources/catalogs_data_source.dart';
import 'package:motogo_frontend/src/core/catalogs/data/repositories/catalogs_repository_impl.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';

// Core - Geocoding
import 'package:motogo_frontend/src/core/geocoding/data/datasources/geocoding_data_source.dart';

// Core - Firebase Services
import 'package:motogo_frontend/src/core/services/firebase/firebase_token_data_source.dart';
import 'package:motogo_frontend/src/core/services/firebase/storage_service.dart';

// Features - Admin Services
import 'package:motogo_frontend/src/features/admin_services/data/datasources/admin_service_datasource.dart';
import 'package:motogo_frontend/src/features/admin_services/data/repositories/admin_service_repository_impl.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/repositories/admin_service_repository.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/usecases/admin_service_usecases.dart';

// Features - Branch Schedules
import 'package:motogo_frontend/src/features/branch_schedules/data/datasources/branch_schedule_datasource.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/datasources/branch_schedule_datasource_impl.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/repositories/branch_schedule_repository_impl.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/repositories/branch_schedule_repository.dart';

// Features - Register Motorcycle
import 'package:motogo_frontend/src/features/register_motorcycle/data/datasources/motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/data/repositories/motorcycle_repository_impl.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/repositories/motorcycle_repository.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/usecases/register_motorcycle_usecase.dart';

// Features - Motorcycle References (catalog)
import 'package:motogo_frontend/src/features/motorcycle_references/data/datasources/motorcycle_reference_datasource.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/domain/usecases/get_motorcycle_references_usecase.dart';

// Features - My Motorcycles
import 'package:motogo_frontend/src/features/my_motorcycles/data/datasources/my_motorcycles_datasource.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/data/repositories/my_motorcycles_repository_impl.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/domain/repositories/my_motorcycles_repository.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/domain/usecases/get_my_motorcycles_usecase.dart';

// Features - Edit Motorcycle
import 'package:motogo_frontend/src/features/edit_motorcycle/data/datasources/edit_motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/domain/usecases/update_motorcycle_usecase.dart';

// Features - Delete Motorcycle
import 'package:motogo_frontend/src/features/delete_motorcycle/data/datasources/delete_motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/domain/repositories/delete_motorcycle_repository.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/domain/usecases/delete_motorcycle_usecase.dart';

// Features - User Home
import 'package:motogo_frontend/src/features/user_home/data/datasources/nearby_branches_datasource.dart';
import 'package:motogo_frontend/src/features/user_home/data/repositories/nearby_branches_repository_impl.dart';
import 'package:motogo_frontend/src/features/user_home/domain/repositories/nearby_branches_repository.dart';
import 'package:motogo_frontend/src/features/user_home/domain/usecases/get_nearby_branches_usecase.dart';

// Core - Location Service
import 'package:motogo_frontend/src/core/services/location_service.dart';

// Features - Search Motorcycle by Plate (HU47)
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/data/datasources/search_motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/data/repositories/search_motorcycle_repository_impl.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/repositories/search_motorcycle_repository.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/search_motorcycle_by_plate_usecase.dart';

// Features - Technical Catalogs (HU40)
import 'package:motogo_frontend/src/features/technical_catalogs/data/datasources/brand_lines_datasource.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/repositories/brand_lines_repository_impl.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/repositories/brand_lines_repository.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/usecases/get_brand_lines_usecase.dart';

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
    // Manual registration for Dio infrastructure
    _configureDioClient();
    // Manual registration for Dio-based datasources
    _configureDioDataSources();
    // Manual registration for services that need Firebase instances
    _configureFirebaseServices();
  }

  /// Configures DioClient with AuthInterceptor for automatic token refresh.
  void _configureDioClient() {
    // Register RefreshTokenDataSource first
    container.registerSingleton<RefreshTokenDataSource>(
      (c) => RefreshTokenDataSourceImpl(),
    );

    // Register AuthInterceptor with RefreshTokenDataSource
    container.registerSingleton<AuthInterceptor>(
      (c) => AuthInterceptor(c.resolve<RefreshTokenDataSource>()),
    );

    // Register DioClient with AuthInterceptor
    container.registerSingleton<DioClient>(
      (c) => DioClient(authInterceptor: c.resolve<AuthInterceptor>()),
    );
  }

  /// Registers datasources that have been migrated to use DioClient or have their own Dio.
  void _configureDioDataSources() {
    // === Core DataSources ===

    // Catalogs - uses DioClient
    container.registerFactory<CatalogsDataSource>(
      (c) => CatalogsDataSourceImpl(c.resolve<DioClient>()),
    );

    // UserSession - has its own Dio (receives token as parameter)
    container.registerFactory<UserSessionDataSource>(
      (c) => UserSessionDataSourceImpl(),
    );

    // FirebaseToken - uses DioClient
    container.registerFactory<FirebaseTokenDataSource>(
      (c) => FirebaseTokenDataSourceImpl(c.resolve<DioClient>()),
    );

    // Geocoding - uses DioClient
    container.registerFactory<GeocodingDataSource>(
      (c) => GeocodingDataSourceImpl(c.resolve<DioClient>()),
    );

    // === Feature DataSources ===

    // Register Branch - uses DioClient
    container.registerFactory<RegisterBranchDataSource>(
      (c) => RegisterBranchDataSourceImpl(c.resolve<DioClient>()),
    );

    // Edit Branch - uses DioClient
    container.registerFactory<EditBranchDataSource>(
      (c) => EditBranchDataSourceImpl(c.resolve<DioClient>()),
    );

    // Delete Branch - uses DioClient
    container.registerFactory<DeleteBranchDataSource>(
      (c) => DeleteBranchDataSourceImpl(c.resolve<DioClient>()),
    );

    // Branch Services - uses DioClient
    container.registerFactory<BranchServicesDataSource>(
      (c) => BranchServicesDataSourceImpl(c.resolve<DioClient>()),
    );

    // My Branches - uses DioClient
    container.registerFactory<MyBranchesDataSource>(
      (c) => MyBranchesDataSourceImpl(c.resolve<DioClient>()),
    );

    // Delete Person - uses DioClient
    container.registerFactory<DeletePersonDataSource>(
      (c) => DeletePersonDataSourceImpl(c.resolve<DioClient>()),
    );

    // Change Password - has its own Dio (receives token as parameter)
    container.registerFactory<ChangePasswordDataSource>(
      (c) => ChangePasswordDataSourceImpl(),
    );

    // Email Recovery - has its own Dio (public endpoint, no auth)
    container.registerFactory<EmailRecoveryVerificationDataSource>(
      (c) => EmailRecoveryVerificationDataSource(),
    );

    // Register Franchise - uses DioClient
    container.registerFactory<RegisterFranchiseDataSource>(
      (c) => RegisterFranchiseDataSourceImpl(c.resolve<DioClient>()),
    );

    // Manage Franchise - uses DioClient
    container.registerFactory<FranchiseDataSource>(
      (c) => FranchiseDataSourceImpl(c.resolve<DioClient>()),
    );

    // Manage Franchise Use Cases
    container.registerFactory<GetFranchiseUseCase>(
      (c) => GetFranchiseUseCase(c.resolve<FranchiseDataSource>()),
    );
    container.registerFactory<ListFranchisesUseCase>(
      (c) => ListFranchisesUseCase(c.resolve<FranchiseDataSource>()),
    );
    container.registerFactory<UpdateFranchiseUseCase>(
      (c) => UpdateFranchiseUseCase(c.resolve<FranchiseDataSource>()),
    );
    container.registerFactory<DeleteFranchiseUseCase>(
      (c) => DeleteFranchiseUseCase(c.resolve<FranchiseDataSource>()),
    );
    container.registerFactory<LinkBranchToFranchiseUseCase>(
      (c) => LinkBranchToFranchiseUseCase(c.resolve<FranchiseDataSource>()),
    );
    container.registerFactory<UnlinkBranchFromFranchiseUseCase>(
      (c) => UnlinkBranchFromFranchiseUseCase(c.resolve<FranchiseDataSource>()),
    );

    // Admin Services - uses DioClient
    container.registerFactory<AdminServiceDataSource>(
      (c) => AdminServiceDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<AdminServiceRepository>(
      (c) => AdminServiceRepositoryImpl(c.resolve<AdminServiceDataSource>()),
    );
    container.registerFactory<GetServicesCatalogUseCase>(
      (c) => GetServicesCatalogUseCase(c.resolve<AdminServiceRepository>()),
    );
    container.registerFactory<UpdateServiceUseCase>(
      (c) => UpdateServiceUseCase(c.resolve<AdminServiceRepository>()),
    );
    container.registerFactory<ActivateServiceUseCase>(
      (c) => ActivateServiceUseCase(c.resolve<AdminServiceRepository>()),
    );
    container.registerFactory<DeactivateServiceUseCase>(
      (c) => DeactivateServiceUseCase(c.resolve<AdminServiceRepository>()),
    );

    // Branch Schedules - uses DioClient
    container.registerFactory<BranchScheduleDataSource>(
      (c) => BranchScheduleDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<BranchScheduleRepository>(
      (c) =>
          BranchScheduleRepositoryImpl(c.resolve<BranchScheduleDataSource>()),
    );

    // Register Motorcycle - uses DioClient
    container.registerFactory<MotorcycleDataSource>(
      (c) => MotorcycleDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<MotorcycleRepository>(
      (c) => MotorcycleRepositoryImpl(c.resolve<MotorcycleDataSource>()),
    );
    container.registerFactory<RegisterMotorcycleUseCase>(
      (c) => RegisterMotorcycleUseCase(c.resolve<MotorcycleRepository>()),
    );

    // Motorcycle References - catalog
    container.registerFactory<MotorcycleReferenceDataSource>(
      (c) => MotorcycleReferenceDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<GetMotorcycleReferencesUseCase>(
      (c) => GetMotorcycleReferencesUseCase(
        c.resolve<MotorcycleReferenceDataSource>(),
      ),
    );

    // My Motorcycles - list user's motorcycles
    container.registerFactory<MyMotorcyclesDataSource>(
      (c) => MyMotorcyclesDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<MyMotorcyclesRepository>(
      (c) => MyMotorcyclesRepositoryImpl(c.resolve<MyMotorcyclesDataSource>()),
    );
    container.registerFactory<GetMyMotorcyclesUseCase>(
      (c) => GetMyMotorcyclesUseCase(c.resolve<MyMotorcyclesRepository>()),
    );

    // Edit Motorcycle - update motorcycle
    container.registerFactory<EditMotorcycleDataSource>(
      (c) => EditMotorcycleDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<UpdateMotorcycleUseCase>(
      (c) => UpdateMotorcycleUseCase(c.resolve<EditMotorcycleDataSource>()),
    );

    // Delete Motorcycle - soft delete motorcycle
    container.registerFactory<DeleteMotorcycleDataSource>(
      (c) => DeleteMotorcycleDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<DeleteMotorcycleRepository>(
      (c) => DeleteMotorcycleRepositoryImpl(
        c.resolve<DeleteMotorcycleDataSource>(),
      ),
    );
    container.registerFactory<DeleteMotorcycleUseCase>(
      (c) => DeleteMotorcycleUseCase(c.resolve<DeleteMotorcycleRepository>()),
    );

    // User Home - Nearby Branches
    container.registerFactory<NearbyBranchesDataSource>(
      (c) => NearbyBranchesDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<NearbyBranchesRepository>(
      (c) =>
          NearbyBranchesRepositoryImpl(c.resolve<NearbyBranchesDataSource>()),
    );
    container.registerFactory<GetNearbyBranchesUseCase>(
      (c) => GetNearbyBranchesUseCase(c.resolve<NearbyBranchesRepository>()),
    );
    container.registerSingleton<LocationService>(
      (c) => LocationService.instance,
    );

    // Search Motorcycle by Plate (HU47)
    container.registerFactory<SearchMotorcycleDataSource>(
      (c) => SearchMotorcycleDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<SearchMotorcycleRepository>(
      (c) => SearchMotorcycleRepositoryImpl(
        c.resolve<SearchMotorcycleDataSource>(),
      ),
    );
    container.registerFactory<SearchMotorcycleByPlateUseCase>(
      (c) => SearchMotorcycleByPlateUseCase(
        c.resolve<SearchMotorcycleRepository>(),
      ),
    );

    // Technical Catalogs - Brand Lines (HU40)
    container.registerFactory<BrandLinesDataSource>(
      (c) => BrandLinesDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<BrandLinesRepository>(
      (c) => BrandLinesRepositoryImpl(c.resolve<BrandLinesDataSource>()),
    );
    container.registerFactory<GetBrandLinesUseCase>(
      (c) => GetBrandLinesUseCase(c.resolve<BrandLinesRepository>()),
    );
  }

  void _configureFirebaseServices() {
    // StorageService needs FirebaseAuth and FirebaseStorage
    // which aren't in the DI container, so we register manually
    container.registerFactory<StorageService>(
      (c) =>
          StorageService(tokenDataSource: c.resolve<FirebaseTokenDataSource>()),
    );
  }

  void _configureAuth() {
    _configureAuthFactories();
  }

  // Core - Repositories only (DataSources are registered manually in _configureDioDataSources)
  @Register.factory(UserSessionRepository, from: UserSessionRepositoryImpl)
  @Register.factory(CatalogsRepository, from: CatalogsRepositoryImpl)
  void _configureCoreFactories();

  // Features - Repositories, UseCases, and remaining DataSources
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
  @Register.factory(
    ChangePasswordRepository,
    from: ChangePasswordRepositoryImpl,
  )
  @Register.factory(ChangePasswordUseCase)
  // Features - Register/Edit Branch (Repository and UseCases)
  @Register.factory(BranchRepository, from: BranchRepositoryImpl)
  @Register.factory(RegisterBranchUseCase)
  @Register.factory(UpdateBranchUseCase)
  // Features - Delete Branch (Repository and UseCase)
  @Register.factory(DeleteBranchRepository, from: DeleteBranchRepositoryImpl)
  @Register.factory(DeleteBranchUseCase)
  // Features - My Branches (Repository and UseCase only)
  @Register.factory(MyBranchesRepository, from: MyBranchesRepositoryImpl)
  @Register.factory(GetBranchesUseCase)
  // Features - Delete Person (Repository and UseCase)
  @Register.factory(DeletePersonRepository, from: DeletePersonRepositoryImpl)
  @Register.factory(DeletePersonUseCase)
  // Features - Register Franchise (Repository and UseCase)
  @Register.factory(FranchiseRepository, from: FranchiseRepositoryImpl)
  @Register.factory(RegisterFranchiseUseCase)
  void _configureAuthFactories();
}
