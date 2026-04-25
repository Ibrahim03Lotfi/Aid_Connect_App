import 'dart:math';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/org_case.dart';
import '../../domain/repositories/organization_repository.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  // STATIC MOCK DATA - no dio needed for static phase
  final List<OrgCase> _mockCases = [
    OrgCase(
      id: 1,
      title: 'مساعدة عاجلة لعائلة متضررة',
      description: 'عائلة مكونة من 5 أفراد بحاجة لمساعدة عاجلة للإيجار والطعام.',
      status: 'approved',
      priority: 'urgent',
      category: 'إغاثة عاجلة',
      governorate: 'دمشق',
      views: 120,
      donationsCount: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    OrgCase(
      id: 2,
      title: 'علاج طبي لطفل مصاب',
      description: 'طفل يعاني من مرض نادر ويحتاج لعملية جراحية عاجلة.',
      status: 'pending',
      priority: 'high',
      category: 'علاج طبي',
      governorate: 'حلب',
      views: 45,
      donationsCount: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    OrgCase(
      id: 3,
      title: 'مساعدات غذائية لأسرة',
      description: 'أسرة مكونة من 7 أفراد بحاجة لسلة غذائية شهرية.',
      status: 'rejected',
      priority: 'medium',
      category: 'مساعدات غذائية',
      governorate: 'حمص',
      views: 0,
      donationsCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      rejectionReason: 'البيانات غير كاملة، يرجى إرفاق صور توضح حالة الأسرة',
    ),
    OrgCase(
      id: 4,
      title: 'دعم تعليمي لطالب',
      description: 'طالب متفوق يحتاج لدعم مالي لاستكمال دراسته.',
      status: 'approved',
      priority: 'medium',
      category: 'تعليم',
      governorate: 'حماة',
      views: 89,
      donationsCount: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    OrgCase(
      id: 5,
      title: 'إعادة تأهيل منزل',
      description: 'منزل تضرر بسبب الأمطار ويحتاج لإصلاحات.',
      status: 'pending',
      priority: 'high',
      category: 'سكن',
      governorate: 'اللاذقية',
      views: 23,
      donationsCount: 1,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    OrgCase(
      id: 6,
      title: 'ملابس شتوية للأطفال',
      description: '20 طفل يحتاجون ملابس شتوية دافئة.',
      status: 'approved',
      priority: 'medium',
      category: 'ملابس',
      governorate: 'طرطوس',
      views: 156,
      donationsCount: 34,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    OrgCase(
      id: 7,
      title: 'إغاثة عاجلة لمصابي حادث',
      description: 'مساعدة طبية وغذائية لمصابي حادث طريق.',
      status: 'pending',
      priority: 'urgent',
      category: 'إغاثة عاجلة',
      governorate: 'دمشق',
      views: 8,
      donationsCount: 0,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    OrgCase(
      id: 8,
      title: 'معدات مدرسية',
      description: 'طلب كتب وقرطاسية لمدرسة في قرية نائية.',
      status: 'rejected',
      priority: 'low',
      category: 'تعليم',
      governorate: 'حمص',
      views: 0,
      donationsCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      rejectionReason: 'يرجى تقديم خطاب رسمي من المدرسة',
    ),
    OrgCase(
      id: 9,
      title: 'إصلاح بئر ماء',
      description: 'بئر ماء معطل في قرية يحتاج لإصلاح عاجل.',
      status: 'approved',
      priority: 'high',
      category: 'مياه',
      governorate: 'اللاذقية',
      views: 234,
      donationsCount: 67,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    OrgCase(
      id: 10,
      title: 'دعم أرامل',
      description: 'مساعدة شهرية لـ 3 أرامل بلا معيل.',
      status: 'pending',
      priority: 'medium',
      category: 'دعم نفسي',
      governorate: 'حلب',
      views: 56,
      donationsCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<Either<Failure, List<OrgCase>>> getOrganizationCases({
    int page = 1,
    String? status,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Filter by status if provided
    var filteredCases = _mockCases;
    if (status != null && status.isNotEmpty) {
      filteredCases = _mockCases.where((c) => c.status == status).toList();
    }

    // Simulate pagination (10 items per page)
    const itemsPerPage = 10;
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = min(startIndex + itemsPerPage, filteredCases.length);

    if (startIndex >= filteredCases.length) {
      return const Right([]);
    }

    final paginatedCases = filteredCases.sublist(startIndex, endIndex);
    return Right(paginatedCases);
  }

  @override
  Future<Either<Failure, OrgCase>> getCaseDetails(int caseId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final caseItem = _mockCases.firstWhere(
      (c) => c.id == caseId,
      orElse: () => _mockCases.first,
    );
    return Right(caseItem);
  }

  @override
  Future<Either<Failure, void>> createCase({
    required String title,
    required String description,
    required int categoryId,
    required int governorateId,
    required String priority,
    required List<String> images,
    List<String>? attachments,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    final newCase = OrgCase(
      id: _mockCases.length + 1,
      title: title,
      description: description,
      status: 'pending',
      priority: priority,
      category: 'قسم $_getCategoryName(categoryId)',
      governorate: 'محافظة $_getGovernorateName(governorateId)',
      views: 0,
      donationsCount: 0,
      createdAt: DateTime.now(),
      images: images,
    );

    _mockCases.insert(0, newCase);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateCase({
    required int caseId,
    String? title,
    String? description,
    String? priority,
    List<String>? images,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockCases.indexWhere((c) => c.id == caseId);
    if (index == -1) {
      return Left(NotFoundFailure('الحالة غير موجودة'));
    }

    final existingCase = _mockCases[index];
    final updatedCase = OrgCase(
      id: existingCase.id,
      title: title ?? existingCase.title,
      description: description ?? existingCase.description,
      status: existingCase.status,
      priority: priority ?? existingCase.priority,
      category: existingCase.category,
      governorate: existingCase.governorate,
      views: existingCase.views,
      donationsCount: existingCase.donationsCount,
      createdAt: existingCase.createdAt,
      thumbnail: existingCase.thumbnail,
      rejectionReason: existingCase.rejectionReason,
      images: images ?? existingCase.images,
    );

    _mockCases[index] = updatedCase;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteCase(int caseId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _mockCases.indexWhere((c) => c.id == caseId);
    if (index == -1) {
      return Left(NotFoundFailure('الحالة غير موجودة'));
    }

    _mockCases.removeAt(index);
    return const Right(null);
  }

  String _getCategoryName(int id) {
    final categories = {
      1: 'إغاثة عاجلة',
      2: 'مساعدات غذائية',
      3: 'علاج طبي',
      4: 'تعليم',
      5: 'سكن',
      6: 'ملابس',
    };
    return categories[id] ?? 'أخرى';
  }

  String _getGovernorateName(int id) {
    final governorates = {
      1: 'دمشق',
      2: 'حلب',
      3: 'حمص',
      4: 'حماة',
      5: 'اللاذقية',
      6: 'طرطوس',
      7: 'درعا',
      8: 'السويداء',
      9: 'دير الزور',
      10: 'الرقة',
      11: 'الحسكة',
      12: 'إدلب',
      13: 'القنيطرة',
      14: 'ريف دمشق',
    };
    return governorates[id] ?? 'أخرى';
  }
}
