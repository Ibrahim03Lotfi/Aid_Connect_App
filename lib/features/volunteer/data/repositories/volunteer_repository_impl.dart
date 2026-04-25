import 'dart:math';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/volunteer_case.dart';
import '../../domain/repositories/volunteer_repository.dart';

class VolunteerRepositoryImpl implements VolunteerRepository {
  // STATIC MOCK DATA - Available Cases
  final List<VolunteerCase> _availableCases = [
    VolunteerCase(
      id: 101,
      title: 'توزيع سلال غذائية على الأسر المحتاجة',
      description: 'نحتاج متطوعين لتوزيع 50 سلة غذائية على الأسر المحتاجة في منطقة المزة. المهمة تشمل تحميل السلال من المستودع وتوزيعها على العناوين المحددة.',
      category: 'مساعدات غذائية',
      governorate: 'دمشق',
      priority: 'high',
      organizationName: 'بنك الطعام المصري',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      volunteersNeeded: 10,
      volunteersApplied: 4,
      isUrgent: true,
    ),
    VolunteerCase(
      id: 102,
      title: 'مساعدة في حملة تبرع بالدم',
      description: 'نحتاج متطوعين للتسجيل والتنظيم في حملة التبرع بالدم التي ستقام في مستشفى حلب الجامعي.',
      category: 'علاج طبي',
      governorate: 'حلب',
      priority: 'urgent',
      organizationName: 'جمعية الهلال الأحمر',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      volunteersNeeded: 6,
      volunteersApplied: 2,
      isUrgent: true,
    ),
    VolunteerCase(
      id: 103,
      title: 'تدريس الأطفال المحرومين',
      description: 'برنامج تعليمي للأطفال في المناطق النائية. نحتاج متطوعين للتدريس في المواد الأساسية (الرياضيات - العربية - الإنجليزية).',
      category: 'تعليم',
      governorate: 'حماة',
      priority: 'medium',
      organizationName: 'مؤسسة العلم للجميع',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      volunteersNeeded: 4,
      volunteersApplied: 1,
    ),
    VolunteerCase(
      id: 104,
      title: 'إعادة تأهيل منزل عائلة متضررة',
      description: 'عائلة فقدت منزلها بسبب السيول. نحتاج متطوعين للمساعدة في أعمال البناء والترميم.',
      category: 'سكن',
      governorate: 'اللاذقية',
      priority: 'high',
      organizationName: 'منظمة الخير للإغاثة',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      volunteersNeeded: 8,
      volunteersApplied: 5,
    ),
    VolunteerCase(
      id: 105,
      title: 'تنظيف شاطئ طرطوس',
      description: 'حملة تنظيف للشاطئ بالتعاون مع وزارة البيئة. نحتاج متطوعين لجمع المخلفات البلاستيكية.',
      category: 'بيئة',
      governorate: 'طرطوس',
      priority: 'low',
      organizationName: 'مؤسسة بيئتنا',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      volunteersNeeded: 20,
      volunteersApplied: 8,
    ),
    VolunteerCase(
      id: 106,
      title: 'زيارة دور المسنين',
      description: 'زيارة ترفيهية واجتماعية لدور المسنين. نحتاج متطوعين للجلوس مع المسنين والاستماع لهم.',
      category: 'دعم نفسي',
      governorate: 'حمص',
      priority: 'medium',
      organizationName: 'جمعية رعاية المسنين',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      volunteersNeeded: 5,
      volunteersApplied: 3,
    ),
  ];

  // STATIC MOCK DATA - My Applications
  final List<VolunteerApplication> _myApplications = [
    VolunteerApplication(
      id: 1001,
      caseId: 201,
      caseTitle: 'مساعدة في إغاثة عاجلة',
      status: 'accepted',
      appliedAt: DateTime.now().subtract(const Duration(days: 5)),
      organizationName: 'منظمة الخير للإغاثة',
      category: 'إغاثة عاجلة',
    ),
    VolunteerApplication(
      id: 1002,
      caseId: 202,
      caseTitle: 'توزيع ملابس شتوية',
      status: 'pending',
      appliedAt: DateTime.now().subtract(const Duration(hours: 12)),
      organizationName: 'مؤسسة الأمل',
      category: 'ملابس',
    ),
    VolunteerApplication(
      id: 1003,
      caseId: 203,
      caseTitle: 'إفطار صائم - رمضان',
      status: 'completed',
      appliedAt: DateTime.now().subtract(const Duration(days: 30)),
      organizationName: 'جمعية خيرية',
      category: 'مساعدات غذائية',
    ),
  ];

  @override
  Future<Either<Failure, List<VolunteerCase>>> getAvailableCases({
    int page = 1,
    String? category,
    String? governorate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    var filteredCases = _availableCases;

    if (category != null && category.isNotEmpty) {
      filteredCases = filteredCases.where((c) => c.category == category).toList();
    }
    if (governorate != null && governorate.isNotEmpty) {
      filteredCases = filteredCases.where((c) => c.governorate == governorate).toList();
    }

    // Simulate pagination
    const itemsPerPage = 10;
    final startIndex = (page - 1) * itemsPerPage;
    final endIndex = min(startIndex + itemsPerPage, filteredCases.length);

    if (startIndex >= filteredCases.length) {
      return const Right([]);
    }

    return Right(filteredCases.sublist(startIndex, endIndex));
  }

  @override
  Future<Either<Failure, List<VolunteerApplication>>> getMyApplications({
    int page = 1,
    String? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    var filtered = _myApplications;
    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((a) => a.status == status).toList();
    }

    return Right(filtered);
  }

  @override
  Future<Either<Failure, void>> applyToCase(int caseId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final caseIndex = _availableCases.indexWhere((c) => c.id == caseId);
    if (caseIndex == -1) {
      return Left(NotFoundFailure('الحالة غير موجودة'));
    }

    final volunteerCase = _availableCases[caseIndex];
    if (volunteerCase.isFull) {
      return Left(ServerFailure('لا توجد أماكن متاحة'));
    }

    // Update volunteers applied count
    final updatedCase = VolunteerCase(
      id: volunteerCase.id,
      title: volunteerCase.title,
      description: volunteerCase.description,
      category: volunteerCase.category,
      governorate: volunteerCase.governorate,
      priority: volunteerCase.priority,
      organizationName: volunteerCase.organizationName,
      createdAt: volunteerCase.createdAt,
      volunteersNeeded: volunteerCase.volunteersNeeded,
      volunteersApplied: volunteerCase.volunteersApplied + 1,
      thumbnail: volunteerCase.thumbnail,
      isUrgent: volunteerCase.isUrgent,
    );
    _availableCases[caseIndex] = updatedCase;

    // Add to my applications
    _myApplications.insert(0, VolunteerApplication(
      id: DateTime.now().millisecondsSinceEpoch,
      caseId: caseId,
      caseTitle: volunteerCase.title,
      status: 'pending',
      appliedAt: DateTime.now(),
      organizationName: volunteerCase.organizationName,
      category: volunteerCase.category,
    ));

    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> cancelApplication(int applicationId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _myApplications.indexWhere((a) => a.id == applicationId);
    if (index == -1) {
      return Left(NotFoundFailure('الطلب غير موجود'));
    }

    _myApplications.removeAt(index);
    return const Right(null);
  }

  @override
  Future<Either<Failure, VolunteerCase>> getCaseDetails(int caseId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final caseItem = _availableCases.firstWhere(
      (c) => c.id == caseId,
      orElse: () => _availableCases.first,
    );
    return Right(caseItem);
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? bio,
    List<String>? skills,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right({
      'name': 'أحمد محمد',
      'email': 'ahmed@example.com',
      'phone': '01012345678',
      'bio': 'متطوع متخصص في العمل الخيري والإغاثي منذ 3 سنوات',
      'skills': ['إغاثة', 'تدريس', 'تنظيم فعاليات'],
      'joinedAt': '2022',
      'completedCases': 12,
      'activeCases': 2,
    });
  }
}
