import 'package:kiwi/kiwi.dart';
// Core - Catalogs
import 'package:motogo_frontend/src/core/catalogs/data/datasources/catalogs_data_source.dart';
import 'package:motogo_frontend/src/core/catalogs/data/repositories/catalogs_repository_impl.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
// Core - Geocoding
import 'package:motogo_frontend/src/core/geocoding/data/datasources/geocoding_data_source.dart';
// Core - Network (Dio)
import 'package:motogo_frontend/src/core/network/auth_interceptor.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/refresh_token_data_source.dart';
// Core - Firebase Services
import 'package:motogo_frontend/src/core/services/firebase/firebase_token_data_source.dart';
import 'package:motogo_frontend/src/core/services/firebase/storage_service.dart';
// Core - Location Service
import 'package:motogo_frontend/src/core/services/location_service.dart';
// Core - User Session
import 'package:motogo_frontend/src/core/user/data/datasources/user_session_data_source.dart';
import 'package:motogo_frontend/src/core/user/data/repositories/user_session_repository_impl.dart';
import 'package:motogo_frontend/src/core/user/domain/repositories/user_session_repository.dart';
// Features - Admin Services
import 'package:motogo_frontend/src/features/admin_services/data/datasources/admin_service_datasource.dart';
import 'package:motogo_frontend/src/features/admin_services/data/repositories/admin_service_repository_impl.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/repositories/admin_service_repository.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/usecases/admin_service_usecases.dart';
// Features - Branch Detail
import 'package:motogo_frontend/src/features/branch_detail/data/datasources/branch_detail_datasource.dart';
import 'package:motogo_frontend/src/features/branch_detail/data/repositories/branch_detail_repository_impl.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/repositories/branch_detail_repository.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/usecases/get_branch_detail_usecase.dart';
import 'package:motogo_frontend/src/features/branch_detail/presentation/bloc/branch_detail_bloc.dart';
// Features - Branch Schedules
import 'package:motogo_frontend/src/features/branch_schedules/data/datasources/branch_schedule_datasource.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/datasources/branch_schedule_datasource_impl.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/repositories/branch_schedule_repository_impl.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/repositories/branch_schedule_repository.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_bloc.dart';
// Features - Branch Services
import 'package:motogo_frontend/src/features/branch_services/data/datasources/branch_services_datasource.dart';
// Features - Change Password
import 'package:motogo_frontend/src/features/change_password/data/datasources/change_password_data_source.dart';
import 'package:motogo_frontend/src/features/change_password/data/repositories/change_password_repository_impl.dart';
import 'package:motogo_frontend/src/features/change_password/domain/repositories/change_password_repository.dart';
import 'package:motogo_frontend/src/features/change_password/domain/usecases/change_password_usecase.dart';
import 'package:motogo_frontend/src/features/change_password/presentation/bloc/change_password_bloc.dart';
// Features - Delete Branch
import 'package:motogo_frontend/src/features/delete_branch/data/datasources/delete_branch_data_source.dart';
import 'package:motogo_frontend/src/features/delete_branch/domain/repositories/delete_branch_repository.dart';
import 'package:motogo_frontend/src/features/delete_branch/domain/usecases/delete_branch_usecase.dart';
// Features - Delete Motorcycle
import 'package:motogo_frontend/src/features/delete_motorcycle/data/datasources/delete_motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/domain/repositories/delete_motorcycle_repository.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/domain/usecases/delete_motorcycle_usecase.dart';
// Features - Delete Person
import 'package:motogo_frontend/src/features/delete_person/data/datasources/delete_person_data_source.dart';
import 'package:motogo_frontend/src/features/delete_person/domain/repositories/delete_person_repository.dart';
import 'package:motogo_frontend/src/features/delete_person/domain/usecases/delete_person_usecase.dart';
// Features - Diagnostic
import 'package:motogo_frontend/src/features/diagnostic/data/datasource/diagnostic_datasource.dart';
import 'package:motogo_frontend/src/features/diagnostic/data/repository/diagnostic_repository_impl.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/repository/diagnostic_repository.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/usecase/create_diagnostic_usecase.dart';
// Features - Diagnostic Permission
import 'package:motogo_frontend/src/features/diagnostic_permission/data/datasource/diagnostic_permission_datasource.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/data/repository/diagnostic_permission_repository_impl.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/repository/diagnostic_permission_repository.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/usecase/grant_permission_usecase.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/usecase/list_permissions_usecase.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/usecase/revoke_permission_usecase.dart';
// Features - Edit Branch
import 'package:motogo_frontend/src/features/edit_branch/data/datasources/edit_branch_data_source.dart';
import 'package:motogo_frontend/src/features/edit_branch/domain/usecases/update_branch_usecase.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_bloc.dart';
// Features - Edit Motorcycle
import 'package:motogo_frontend/src/features/edit_motorcycle/data/datasources/edit_motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/domain/usecases/update_motorcycle_usecase.dart';
// Features - Edit Profile
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/get_person_usecase.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/update_person_usecase.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/bloc/edit_profile_bloc.dart';
// Features - Login
import 'package:motogo_frontend/src/features/login/data/datasources/login_data_source.dart';
import 'package:motogo_frontend/src/features/login/data/repositories/login_repository_impl.dart';
import 'package:motogo_frontend/src/features/login/domain/repositories/login_repository.dart';
import 'package:motogo_frontend/src/features/login/domain/usecases/login_usecase.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
// Features - Manage Franchise
import 'package:motogo_frontend/src/features/manage_franchise/data/datasources/franchise_data_source.dart';
import 'package:motogo_frontend/src/features/manage_franchise/domain/usecases/franchise_usecases.dart';
// Features - Motorcycle Evidence
import 'package:motogo_frontend/src/features/motorcycle_evidence/data/datasources/motorcycle_evidence_datasource.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/data/repositories/motorcycle_evidence_repository_impl.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/repositories/motorcycle_evidence_repository.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/usecases/delete_evidence_usecase.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/usecases/get_evidence_usecase.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/usecases/upload_evidence_usecase.dart';
// Features - Motorcycle Profile Image (HU36-39)
import 'package:motogo_frontend/src/features/motorcycle_profile_image/data/datasources/profile_image_datasource.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/data/repositories/profile_image_repository_impl.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/repositories/profile_image_repository.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/usecases/delete_profile_image_usecase.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/usecases/get_profile_image_usecase.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/usecases/update_profile_image_usecase.dart';
// Features - Motorcycle References (catalog)
import 'package:motogo_frontend/src/features/motorcycle_references/data/datasources/motorcycle_reference_datasource.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/domain/usecases/get_motorcycle_references_usecase.dart';
// Features - My Branches
import 'package:motogo_frontend/src/features/my_branches/data/datasources/my_branches_data_source.dart';
import 'package:motogo_frontend/src/features/my_branches/data/repositories/my_branches_repository_impl.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/repositories/my_branches_repository.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_bloc.dart';
// Features - My Motorcycles
import 'package:motogo_frontend/src/features/my_motorcycles/data/datasources/my_motorcycles_datasource.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/data/repositories/my_motorcycles_repository_impl.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/domain/repositories/my_motorcycles_repository.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/domain/usecases/get_my_motorcycles_usecase.dart';
// Features - Password Recovery
import 'package:motogo_frontend/src/features/password_recovery/data/datasources/email_verification_datasource.dart';
import 'package:motogo_frontend/src/features/password_recovery/data/repositories/email_verification_repository_impl.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/repositories/email_verification_repository.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/usecases/verify_email_usecase.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/bloc/email_verification_bloc.dart';
// Features - Register Branch
import 'package:motogo_frontend/src/features/register_branch/data/datasources/register_branch_data_source.dart';
import 'package:motogo_frontend/src/features/register_branch/data/repositories/branch_repository_impl.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/repositories/branch_repository.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/usecases/register_branch_usecase.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/bloc/register_branch_bloc.dart';
// Features - Register Franchise
import 'package:motogo_frontend/src/features/register_franchise/data/datasources/register_franchise_data_source.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/repositories/franchise_repository_impl.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/repositories/franchise_repository.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/usecases/register_franchise_usecase.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/bloc/register_franchise_bloc.dart';
// Features - Register Motorcycle
import 'package:motogo_frontend/src/features/register_motorcycle/data/datasources/motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/data/repositories/motorcycle_repository_impl.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/repositories/motorcycle_repository.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/usecases/register_motorcycle_usecase.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/bloc/register_motorcycle_bloc.dart';
// Features - Register
import 'package:motogo_frontend/src/features/register_person/data/datasources/register_person_data_source.dart';
import 'package:motogo_frontend/src/features/register_person/data/repositories/register_repository_impl.dart';
import 'package:motogo_frontend/src/features/register_person/domain/repositories/register_person_repository.dart';
import 'package:motogo_frontend/src/features/register_person/domain/usecases/register_person_usecase.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/bloc/register_person_bloc.dart';
import 'package:motogo_frontend/src/features/request_diagnostic/presentation/bloc/request_diagnostic_bloc.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/data/datasources/search_motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/data/repositories/search_motorcycle_repository_impl.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/repositories/search_motorcycle_repository.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/search_motorcycle_by_plate_usecase.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/set_solution_usecase.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/presentation/bloc/search_motorcycle_bloc.dart';
// Features - Service Ratings
import 'package:motogo_frontend/src/features/service_ratings/data/datasources/rating_range_datasource.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/repositories/rating_range_repository_impl.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/repositories/rating_range_repository.dart';
// Features - Technical Catalogs (HU40)
import 'package:motogo_frontend/src/features/technical_catalogs/data/datasources/brand_lines_datasource.dart';
// Features - Technical Catalogs (Category Lines)
import 'package:motogo_frontend/src/features/technical_catalogs/data/datasources/category_lines_datasource.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/repositories/brand_lines_repository_impl.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/repositories/category_lines_repository_impl.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/repositories/brand_lines_repository.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/repositories/category_lines_repository.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/usecases/get_brand_lines_usecase.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/usecases/get_categories_usecase.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/usecases/get_category_lines_usecase.dart';
// Features - User Home
import 'package:motogo_frontend/src/features/user_home/data/datasources/nearby_branches_datasource.dart';
import 'package:motogo_frontend/src/features/user_home/data/repositories/nearby_branches_repository_impl.dart';
import 'package:motogo_frontend/src/features/user_home/domain/repositories/nearby_branches_repository.dart';
import 'package:motogo_frontend/src/features/user_home/domain/usecases/get_nearby_branches_usecase.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/bloc/user_home_bloc.dart';

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

    // Login - has its own Dio (public endpoint, no auth)
    container.registerFactory<LoginDataSource>(
      (c) => LoginDataSource(c.resolve<UserSessionDataSource>()),
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

    // Service Ratings - Rating Ranges (uses DioClient)
    container.registerFactory<RatingRangeDataSource>(
      (c) => RatingRangeDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<RatingRangeRepository>(
      (c) => RatingRangeRepositoryImpl(c.resolve<RatingRangeDataSource>()),
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

    // Motorcycle Profile Image - HU36-39
    container.registerFactory<ProfileImageDataSource>(
      (c) => ProfileImageDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<ProfileImageRepository>(
      (c) => ProfileImageRepositoryImpl(c.resolve<ProfileImageDataSource>()),
    );
    container.registerFactory<UpdateProfileImageUseCase>(
      (c) => UpdateProfileImageUseCase(c.resolve<ProfileImageRepository>()),
    );
    container.registerFactory<GetProfileImageUseCase>(
      (c) => GetProfileImageUseCase(c.resolve<ProfileImageRepository>()),
    );
    container.registerFactory<DeleteProfileImageUseCase>(
      (c) => DeleteProfileImageUseCase(c.resolve<ProfileImageRepository>()),
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
    container.registerFactory<UserHomeBloc>(
      (c) => UserHomeBloc(
        getNearbyBranchesUseCase: c.resolve<GetNearbyBranchesUseCase>(),
        locationService: c.resolve<LocationService>(),
      ),
    );

    // Branch Detail - uses multiple datasources
    container.registerFactory<BranchDetailDataSource>(
      (c) => BranchDetailDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<BranchDetailRepository>(
      (c) => BranchDetailRepositoryImpl(
        detailDataSource: c.resolve<BranchDetailDataSource>(),
        servicesDataSource: c.resolve<BranchServicesDataSource>(),
        scheduleDataSource: c.resolve<BranchScheduleDataSource>(),
      ),
    );
    container.registerFactory<GetBranchDetailUseCase>(
      (c) => GetBranchDetailUseCase(c.resolve<BranchDetailRepository>()),
    );
    container.registerFactory<BranchDetailBloc>(
      (c) => BranchDetailBloc(
        getBranchDetailUseCase: c.resolve<GetBranchDetailUseCase>(),
      ),
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
    container.registerFactory<SetSolutionUseCase>(
      (c) => SetSolutionUseCase(c.resolve<SearchMotorcycleRepository>()),
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

    // Technical Catalogs - Category Lines
    container.registerFactory<CategoryLinesDataSource>(
      (c) => CategoryLinesDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<CategoryLinesRepository>(
      (c) => CategoryLinesRepositoryImpl(c.resolve<CategoryLinesDataSource>()),
    );
    container.registerFactory<GetCategoriesUseCase>(
      (c) => GetCategoriesUseCase(c.resolve<CategoryLinesRepository>()),
    );
    container.registerFactory<GetCategoryLinesUseCase>(
      (c) => GetCategoryLinesUseCase(c.resolve<CategoryLinesRepository>()),
    );

    // Diagnostic Feature - DataSource, Repository, UseCase
    container.registerFactory<DiagnosticDataSource>(
      (c) => DiagnosticDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<DiagnosticRepository>(
      (c) => DiagnosticRepositoryImpl(c.resolve<DiagnosticDataSource>()),
    );
    container.registerFactory<CreateDiagnosticUseCase>(
      (c) => CreateDiagnosticUseCase(c.resolve<DiagnosticRepository>()),
    );

    // Diagnostic Permission Feature - DataSource, Repository, UseCase
    container.registerFactory<DiagnosticPermissionDataSource>(
      (c) => DiagnosticPermissionDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<DiagnosticPermissionRepository>(
      (c) => DiagnosticPermissionRepositoryImpl(
        c.resolve<DiagnosticPermissionDataSource>(),
      ),
    );
    container.registerFactory<GrantPermissionUseCase>(
      (c) =>
          GrantPermissionUseCase(c.resolve<DiagnosticPermissionRepository>()),
    );
    container.registerFactory<RevokePermissionUseCase>(
      (c) =>
          RevokePermissionUseCase(c.resolve<DiagnosticPermissionRepository>()),
    );
    container.registerFactory<ListPermissionsUseCase>(
      (c) =>
          ListPermissionsUseCase(c.resolve<DiagnosticPermissionRepository>()),
    );

    // Request Diagnostic - BLoC
    container.registerFactory<RequestDiagnosticBloc>(
      (c) => RequestDiagnosticBloc(
        getMyMotorcyclesUseCase: c.resolve<GetMyMotorcyclesUseCase>(),
        uploadEvidenceUseCase: c.resolve<UploadEvidenceUseCase>(),
        deleteEvidenceUseCase: c.resolve<DeleteEvidenceUseCase>(),
        getEvidenceUseCase: c.resolve<GetEvidenceUseCase>(),
        createDiagnosticUseCase: c.resolve<CreateDiagnosticUseCase>(),
        grantPermissionUseCase: c.resolve<GrantPermissionUseCase>(),
        listPermissionsUseCase: c.resolve<ListPermissionsUseCase>(),
      ),
    );

    // === BLoC Registrations ===

    // Login BLoC
    container.registerFactory<LoginBloc>(
      (c) => LoginBloc(loginUseCase: c.resolve<LoginUseCase>()),
    );

    // Register Person BLoC
    container.registerFactory<RegisterPersonBloc>(
      (c) => RegisterPersonBloc(
        registerUseCase: c.resolve<RegisterPersonUseCase>(),
      ),
    );

    // Edit Profile BLoC
    container.registerFactory<EditProfileBloc>(
      (c) => EditProfileBloc(
        getPersonUsecase: c.resolve<GetPersonUsecase>(),
        updatePersonUsecase: c.resolve<UpdatePersonUsecase>(),
      ),
    );

    // Email Recovery Verification BLoC
    container.registerFactory<EmailRecoveryVerificationBloc>(
      (c) => EmailRecoveryVerificationBloc(
        verifyEmailUseCase: c.resolve<VerifyRecoveryEmailUseCase>(),
      ),
    );

    // Change Password BLoC
    container.registerFactory<ChangePasswordBloc>(
      (c) => ChangePasswordBloc(
        changePasswordUseCase: c.resolve<ChangePasswordUseCase>(),
      ),
    );

    // Search Motorcycle BLoC (HU47)
    container.registerFactory<SearchMotorcycleBloc>(
      (c) => SearchMotorcycleBloc(
        searchUseCase: c.resolve<SearchMotorcycleByPlateUseCase>(),
        setSolutionUseCase: c.resolve<SetSolutionUseCase>(),
      ),
    );

    // Register Motorcycle BLoC
    container.registerFactory<RegisterMotorcycleBloc>(
      (c) => RegisterMotorcycleBloc(
        registerMotorcycleUseCase: c.resolve<RegisterMotorcycleUseCase>(),
      ),
    );

    // Register Franchise BLoC
    container.registerFactory<RegisterFranchiseBloc>(
      (c) => RegisterFranchiseBloc(
        registerFranchiseUseCase: c.resolve<RegisterFranchiseUseCase>(),
      ),
    );

    // Edit Branch BLoC
    container.registerFactory<EditBranchBloc>(
      (c) =>
          EditBranchBloc(updateBranchUseCase: c.resolve<UpdateBranchUseCase>()),
    );

    // Register Branch BLoC
    container.registerFactory<RegisterBranchBloc>(
      (c) => RegisterBranchBloc(
        registerBranchUseCase: c.resolve<RegisterBranchUseCase>(),
      ),
    );

    // Branch Schedule BLoC
    container.registerFactory<BranchScheduleBloc>(
      (c) =>
          BranchScheduleBloc(repository: c.resolve<BranchScheduleRepository>()),
    );

    // My Branches BLoC
    container.registerFactory<MyBranchesBloc>(
      (c) =>
          MyBranchesBloc(getBranchesUseCase: c.resolve<GetBranchesUseCase>()),
    );

    // Motorcycle Evidence
    container.registerFactory<MotorcycleEvidenceDataSource>(
      (c) => MotorcycleEvidenceDataSourceImpl(c.resolve<DioClient>()),
    );
    container.registerFactory<MotorcycleEvidenceRepository>(
      (c) => MotorcycleEvidenceRepositoryImpl(
        c.resolve<MotorcycleEvidenceDataSource>(),
      ),
    );
    container.registerFactory<UploadEvidenceUseCase>(
      (c) => UploadEvidenceUseCase(
        storageService: c.resolve<StorageService>(),
        repository: c.resolve<MotorcycleEvidenceRepository>(),
      ),
    );
    container.registerFactory<DeleteEvidenceUseCase>(
      (c) => DeleteEvidenceUseCase(
        repository: c.resolve<MotorcycleEvidenceRepository>(),
      ),
    );
    container.registerFactory<GetEvidenceUseCase>(
      (c) => GetEvidenceUseCase(c.resolve<MotorcycleEvidenceRepository>()),
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
