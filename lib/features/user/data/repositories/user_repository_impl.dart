import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/case.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/governorate.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/case_model.dart';
import '../models/category_model.dart';
import '../models/governorate_model.dart';

class UserRepositoryImpl implements UserRepository {
  // STATIC MOCK DATA
  final List<CategoryModel> _mockCategories = [
    CategoryModel(id: 1, name: 'إغاثة عاجلة', icon: 'emergency', casesCount: 12),
    CategoryModel(id: 2, name: 'مساعدات غذائية', icon: 'food', casesCount: 25),
    CategoryModel(id: 3, name: 'علاج طبي', icon: 'medical', casesCount: 18),
    CategoryModel(id: 4, name: 'تعليم', icon: 'education', casesCount: 9),
    CategoryModel(id: 5, name: 'سكن', icon: 'housing', casesCount: 15),
    CategoryModel(id: 6, name: 'ملابس', icon: 'clothes', casesCount: 20),
  ];

  final List<GovernorateModel> _mockGovernorates = [
    GovernorateModel(id: 1, name: 'القاهرة', casesCount: 45),
    GovernorateModel(id: 2, name: 'الإسكندرية', casesCount: 32),
    GovernorateModel(id: 3, name: 'الجيزة', casesCount: 28),
    GovernorateModel(id: 4, name: 'المنصورة', casesCount: 19),
    GovernorateModel(id: 5, name: 'أسوان', casesCount: 14),
    GovernorateModel(id: 6, name: 'الأقصر', casesCount: 11),
  ];

  final List<CaseModel> _mockCases = [
    CaseModel(
      id: 1,
      title: 'مساعدة عاجلة لعائلة متضررة',
      description: 'عائلة مكونة من 5 أفراد بحاجة لمساعدة عاجلة للإيجار والطعام بعد فقدان مصدر الدخل.',
      status: 'active',
      priority: 'high',
      categoryId: 1,
      category: 'إغاثة عاجلة',
      governorateId: 1,
      governorate: 'القاهرة',
      views: 120,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    CaseModel(
      id: 2,
      title: 'علاج طبي لطفل مصاب',
      description: 'طفل يعاني من مرض نادر ويحتاج لعملية جراحية عاجلة.',
      status: 'active',
      priority: 'urgent',
      categoryId: 3,
      category: 'علاج طبي',
      governorateId: 2,
      governorate: 'الإسكندرية',
      views: 230,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    CaseModel(
      id: 3,
      title: 'مساعدات غذائية لأسرة فقيرة',
      description: 'أسرة مكونة من 7 أفراد بحاجة لسلة غذائية شهرية.',
      status: 'active',
      priority: 'medium',
      categoryId: 2,
      category: 'مساعدات غذائية',
      governorateId: 3,
      governorate: 'الجيزة',
      views: 89,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    CaseModel(
      id: 4,
      title: 'دعم تعليمي لطالب مجتهد',
      description: 'طالب متفوق يحتاج لدعم مالي لاستكمال دراسته الجامعية.',
      status: 'active',
      priority: 'medium',
      categoryId: 4,
      category: 'تعليم',
      governorateId: 1,
      governorate: 'القاهرة',
      views: 156,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    CaseModel(
      id: 5,
      title: 'إعادة تأهيل منزل متضرر',
      description: 'منزل تضرر بسبب الأمطار ويحتاج لإصلاحات عاجلة.',
      status: 'active',
      priority: 'high',
      categoryId: 5,
      category: 'سكن',
      governorateId: 4,
      governorate: 'المنصورة',
      views: 67,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Track favorites in memory
  final Set<int> _favoriteCaseIds = {};

  UserRepositoryImpl({required dynamic dioClient});

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    // STATIC - return mock categories
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(_mockCategories);
  }

  @override
  Future<Either<Failure, List<Case>>> getLatestCases({int page = 1}) async {
    // STATIC - return mock cases
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(_mockCases);
  }

  @override
  Future<Either<Failure, List<Case>>> getCasesByGovernorate(
    int governorateId, {
    int? categoryId,
    int page = 1,
  }) async {
    // STATIC - filter mock cases
    await Future.delayed(const Duration(milliseconds: 300));
    var filtered = _mockCases.where((c) => c.governorateId == governorateId).toList();
    if (categoryId != null) {
      filtered = filtered.where((c) => c.categoryId == categoryId).toList();
    }
    return Right(filtered);
  }

  @override
  Future<Either<Failure, Case>> getCaseDetails(int caseId) async {
    // STATIC - find case by id
    await Future.delayed(const Duration(milliseconds: 200));
    final caseItem = _mockCases.firstWhere(
      (c) => c.id == caseId,
      orElse: () => _mockCases.first,
    );
    return Right(caseItem);
  }

  @override
  Future<Either<Failure, void>> incrementCaseViews(int caseId) async {
    // STATIC - no-op
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Governorate>>> getGovernorates() async {
    // STATIC - return mock governorates
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(_mockGovernorates);
  }

  @override
  Future<Either<Failure, List<Case>>> getFavorites() async {
    // STATIC - return favorited cases
    await Future.delayed(const Duration(milliseconds: 200));
    final favorites = _mockCases.where((c) => _favoriteCaseIds.contains(c.id)).toList();
    return Right(favorites);
  }

  @override
  Future<Either<Failure, void>> addToFavorites(int caseId) async {
    // STATIC - add to memory
    _favoriteCaseIds.add(caseId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(int caseId) async {
    // STATIC - remove from memory
    _favoriteCaseIds.remove(caseId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? avatar,
  }) async {
    // STATIC - always succeed
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // STATIC - always succeed
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(null);
  }
}
