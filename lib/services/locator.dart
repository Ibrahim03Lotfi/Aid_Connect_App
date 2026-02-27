import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/dio_client.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/user/data/repositories/user_repository_impl.dart';
import '../features/user/domain/repositories/user_repository.dart';
import '../features/user/presentation/bloc/case_details_bloc/case_details_bloc.dart';
import '../features/user/presentation/bloc/governorate_bloc/governorate_bloc.dart';
import '../features/user/presentation/bloc/home_bloc/home_bloc.dart';
import '../features/user/presentation/bloc/profile_bloc/profile_bloc.dart';
import '../features/organization/data/repositories/organization_repository_impl.dart';
import '../features/organization/domain/repositories/organization_repository.dart';
import '../features/organization/presentation/bloc/org_cases_bloc/org_cases_bloc.dart';
import '../features/volunteer/data/repositories/volunteer_repository_impl.dart';
import '../features/volunteer/domain/repositories/volunteer_repository.dart';
import 'local_storage_service.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Services
  locator.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(locator<SharedPreferences>()),
  );

  // Dio Client (needs LocalStorageService for token)
  locator.registerLazySingleton<DioClient>(
    () => DioClient(locator<LocalStorageService>()),
  );

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dioClient: locator<DioClient>(),
      localStorage: locator<LocalStorageService>(),
    ),
  );

  locator.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(dioClient: locator<DioClient>()),
  );

  locator.registerLazySingleton<OrganizationRepository>(
    () => OrganizationRepositoryImpl(),
  );

  locator.registerLazySingleton<VolunteerRepository>(
    () => VolunteerRepositoryImpl(),
  );

  // BLoCs
  locator.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: locator<AuthRepository>(),
      localStorage: locator<LocalStorageService>(),
    ),
  );

  locator.registerFactory<HomeBloc>(
    () => HomeBloc(userRepository: locator<UserRepository>()),
  );

  locator.registerFactory<GovernorateBloc>(
    () => GovernorateBloc(userRepository: locator<UserRepository>()),
  );

  locator.registerFactory<CaseDetailsBloc>(
    () => CaseDetailsBloc(userRepository: locator<UserRepository>()),
  );

  locator.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      userRepository: locator<UserRepository>(),
      authRepository: locator<AuthRepository>(),
      localStorage: locator<LocalStorageService>(),
    ),
  );

  locator.registerFactory<OrgCasesBloc>(
    () => OrgCasesBloc(repository: locator<OrganizationRepository>()),
  );
}
