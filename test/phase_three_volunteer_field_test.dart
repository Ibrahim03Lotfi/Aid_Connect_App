import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:aid_connect/services/locator.dart';
import 'package:aid_connect/core/errors/failures.dart';
import 'package:aid_connect/features/volunteer/domain/repositories/volunteer_repository.dart';
import 'package:aid_connect/features/volunteer/domain/entities/volunteer_case.dart';
import 'package:aid_connect/features/organization/domain/entities/org_case.dart';
import 'package:aid_connect/features/user/domain/entities/case.dart';
import 'package:aid_connect/features/volunteer/presentation/screens/nfc_aid_scanner_screen.dart';
import 'package:aid_connect/features/volunteer/presentation/screens/field_assessment_screen.dart';
import 'package:aid_connect/features/volunteer/presentation/screens/volunteer_passport_screen.dart';
import 'package:aid_connect/features/volunteer/presentation/screens/volunteer_main_screen.dart';
import 'package:aid_connect/features/volunteer/presentation/screens/emergency_missions_screen.dart';

class FakeVolunteerRepository implements VolunteerRepository {
  bool submitFieldAssessmentCalled = false;
  bool verifyAndDeliverAidCalled = false;
  int offlineQueueCount = 0;

  @override
  Future<Either<Failure, Map<String, dynamic>>> lookupBeneficiary(String token) async {
    return Right({
      'id': 1,
      'full_name': 'عائلة أحمد الشامي',
      'national_id': '01020304050',
      'phone': '+963 933 111 222',
      'family_members_count': 6,
      'governorate': {'name_ar': 'دمشق'},
      'status': 'verified',
      'eligible_aid_type': 'سلة غذائية عاجلة + حقيبة شتاء',
      'last_received_at': 'لم تستلم هذا الشهر',
      'card_uid': token,
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getActiveCampaigns() async {
    return Right([
      {
        'id': 1,
        'title': 'حملة دفء الشتاء 2026',
        'type': 'سلال غذائية ووقود تدفئة',
        'governorate': 'ريف دمشق',
        'beneficiaries_target': 500,
        'beneficiaries_served': 342,
      },
    ]);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyAndDeliverAid({
    required int campaignId,
    required String token,
    required String verificationMethod,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    verifyAndDeliverAidCalled = true;
    return Right({
      'status': 'delivered',
      'receipt_number': 'ATHAR-REC-2026-9921',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitFieldAssessment({
    required int beneficiaryId,
    required int livingConditionScore,
    required String housingType,
    required bool heatingAvailable,
    double? monthlyIncome,
    String? incomeSource,
    String? inspectorNotes,
    String? urgencyRating,
  }) async {
    submitFieldAssessmentCalled = true;
    return Right({
      'success': true,
      'assessment_id': 88,
      'living_condition_score': livingConditionScore,
      'status': 'submitted',
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getEmergencyMissions() async {
    return Right([
      {
        'id': 5,
        'title': 'نداء إغاثة طارئ: عاصفة ثلجية في مخيمات الشمال',
        'district': 'ريف حلب الغربي',
        'urgency': 'critical',
        'volunteers_needed': 15,
        'volunteers_joined': 9,
        'status': 'open',
      },
    ]);
  }

  @override
  Future<Either<Failure, void>> joinEmergencyMission(int missionId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> checkInEmergencyMission(int missionId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getVolunteerPassport() async {
    return Right({
      'id': 101,
      'name': 'إبراهيم لطفي',
      'email': 'ibrahim@athar.ngo',
      'phone': '+963 944 123 456',
      'rank': 'قائد فريق ميداني',
      'points': 640,
      'hours': 120.5,
      'missions_count': 18,
      'families_helped': 42,
      'badges': [
        {
          'id': 'first_aid',
          'title': 'المستجيب السريع',
          'description': 'استجابة لأكثر من 5 نداءات استغاثة فورية',
          'unlocked': true,
          'icon': Icons.flash_on_rounded,
          'color': Colors.amber,
        },
        {
          'id': 'nfc_master',
          'title': 'موثق البطاقات الذكية',
          'description': 'توثيق وتسليم أكثر من 20 سلة بالبطاقة الذكية',
          'unlocked': true,
          'icon': Icons.nfc_rounded,
          'color': const Color(0xFF1E7ABF),
        },
        {
          'id': 'century',
          'title': 'نادي المئة ساعة',
          'description': 'تجاوز 100 ساعة عمل تطوعي موثقة في الميدان',
          'unlocked': true,
          'icon': Icons.military_tech_rounded,
          'color': const Color(0xFFD4AF37),
        },
      ],
      'certificate_verification_url': 'https://athar.ngo/verify/volunteer/101',
    });
  }

  @override
  Future<int> getPendingOfflineDistributionsCount() async {
    return offlineQueueCount;
  }

  @override
  Future<Either<Failure, int>> syncOfflineDistributions() async {
    final synced = offlineQueueCount;
    offlineQueueCount = 0;
    return Right(synced);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProfile() async {
    return Right({
      'name': 'إبراهيم لطفي',
      'email': 'ibrahim@athar.ngo',
      'phone': '+963 944 123 456',
      'bio': 'متطوع ميداني معتمد',
      'skills': ['إسعاف أولي', 'مسح سكني', 'توزيع إغاثي'],
      'joinedAt': '2025-01-10',
      'completedCases': 14,
      'activeCases': 2,
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboard() async {
    return Right({
      'my_posted_cases_count': 14,
      'all_volunteer_cases_count': 128,
    });
  }

  @override
  Future<Either<Failure, List<VolunteerCase>>> getAvailableCases({
    int page = 1,
    String? category,
    String? governorate,
  }) async => const Right([]);

  @override
  Future<Either<Failure, List<VolunteerApplication>>> getMyApplications({
    int page = 1,
    String? status,
  }) async => const Right([]);

  @override
  Future<Either<Failure, void>> applyToCase(int caseId) async => const Right(null);

  @override
  Future<Either<Failure, void>> cancelApplication(int applicationId) async => const Right(null);

  @override
  Future<Either<Failure, VolunteerCase>> getCaseDetails(int caseId) async {
    return Left(ServerFailure('Not needed'));
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? bio,
    List<String>? skills,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => const Right(null);

  @override
  Future<Either<Failure, List<Case>>> getVolunteerFeed({
    int page = 1,
    String? query,
  }) async => const Right([]);

  @override
  Future<Either<Failure, List<OrgCase>>> getMyCases({int page = 1}) async => const Right([]);

  @override
  Future<Either<Failure, void>> createMyCase({
    required String title,
    required String description,
    required int categoryId,
    required int governorateId,
    required String priority,
    List<String> imagePaths = const [],
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> updateMyCase({
    required int caseId,
    required String title,
    required String description,
    required int categoryId,
    required int governorateId,
    required String priority,
    List<String> existingImageUrls = const [],
    List<String> imagePaths = const [],
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteMyCase(int caseId) async => const Right(null);
}

Widget createTestApp(Widget child) {
  return MaterialApp(
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeVolunteerRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeVolunteerRepository();
    if (locator.isRegistered<VolunteerRepository>()) {
      locator.unregister<VolunteerRepository>();
    }
    locator.registerSingleton<VolunteerRepository>(fakeRepository);
  });

  group('Phase 3: Volunteer Field Mode & NFC Smart Cards Automated Tests', () {
    testWidgets('1. NfcAidScannerScreen: renders dual modes, simulation chips & beneficiary modal', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const NfcAidScannerScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // Check header and tabs
      expect(find.text('ماسح الإغاثة والبطاقات الذكية'), findsOneWidget);
      expect(find.text('بطاقة NFC الذكية'), findsOneWidget);
      expect(find.text('كاميرا مسح QR'), findsOneWidget);

      // Verify demo simulation chips are present
      expect(find.text('محاكاة تلامس البطاقات للتجربة والمناقشة:'), findsOneWidget);
      expect(find.text('عائلة أبو أحمد (001)'), findsOneWidget);
      expect(find.text('عائلة أم محمود (002)'), findsOneWidget);
      expect(find.text('عائلة الرفاعي (003)'), findsOneWidget);

      // Tap simulation chip to trigger beneficiary lookup
      await tester.tap(find.text('عائلة أبو أحمد (001)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Beneficiary Modal should open
      expect(find.text('عائلة مستفيدة'), findsOneWidget);
      expect(find.text('تأكيد التسليم الفوري للعائلة'), findsOneWidget);

      // Confirm distribution
      await tester.tap(find.text('تأكيد التسليم الفوري للعائلة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeRepository.verifyAndDeliverAidCalled, isTrue);
    });

    testWidgets('2. FieldAssessmentScreen: renders survey, slider, chips & submittal with reward', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const FieldAssessmentScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      // Check assessment headers
      expect(find.text('استمارة الكشف الميداني'), findsOneWidget);
      expect(find.text('مستوى المعيشة العام (1 - 10)'), findsOneWidget);
      expect(find.text('نوع السكن ومواصفاته'), findsOneWidget);
      expect(find.text('توفر التدفئة والمحروقات'), findsOneWidget);
      expect(find.text('درجة الاستجابة المطلوبة'), findsOneWidget);
      expect(find.text('ملاحظات وتوصيات الباحث الميداني'), findsOneWidget);

      // Quick beneficiary chip selection
      expect(find.text('فاطمة العلي'), findsOneWidget);
      await tester.tap(find.text('فاطمة العلي'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('عائلة فاطمة العلي'), findsOneWidget);

      // Test validation: empty notes warning
      await tester.tap(find.text('اعتماد وإرسال التقرير الميداني'));
      await tester.pump();
      expect(find.text('يرجى تدوين الملاحظات والتوصيات الميدانية للزيارة'), findsOneWidget);

      // Enter inspector notes
      await tester.enterText(
        find.widgetWithText(TextFormField, 'سجل أدق التفاصيل حول حالة المسكن، احتياجات الأطفال والمسنين، والأدوية الضرورية...'),
        'تمت الزيارة الميدانية. المسكن بحاجة ماسة لترميم السقف وتوفير وقود التدفئة لأربعة أطفال.',
      );
      await tester.pump();

      // Submit assessment
      await tester.tap(find.text('اعتماد وإرسال التقرير الميداني'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(fakeRepository.submitFieldAssessmentCalled, isTrue);

      // Success reward dialog (+30 points & +1.5 hours)
      expect(find.text('تم رفع تقرير الكشف بنجاح!'), findsOneWidget);
      expect(find.text('+30 نقطة'), findsOneWidget);
      expect(find.text('+1.5 ساعة تطوعية'), findsOneWidget);
      expect(find.text('العودة للوحة الميدان'), findsOneWidget);
    });

    testWidgets('3. VolunteerPassportScreen: displays credentials, metrics, badges & official certificate', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const VolunteerPassportScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check header and credentials
      expect(find.text('جواز التطوع الرقمي المعتمد'), findsOneWidget);
      expect(find.text('إبراهيم لطفي'), findsOneWidget);
      expect(find.text('قائد فريق ميداني'), findsOneWidget);

      // Check metrics
      expect(find.text('ساعات تطوعية موثقة'), findsOneWidget);
      expect(find.text('120.5 س'), findsOneWidget);
      expect(find.text('عائلات تم إغاثتها'), findsOneWidget);
      expect(find.text('42 عائلة'), findsOneWidget);
      expect(find.text('640 نقطة'), findsOneWidget);

      // Check Badges
      expect(find.text('أوسمة الشرف والكفاءة الميدانية'), findsOneWidget);
      expect(find.text('المستجيب السريع'), findsOneWidget);
      expect(find.text('موثق البطاقات الذكية'), findsOneWidget);
      expect(find.text('نادي المئة ساعة'), findsOneWidget);

      // Open Official Certificate modal
      expect(find.text('استعراض وتصدير شهادة الخبرة'), findsOneWidget);
      await tester.tap(find.text('استعراض وتصدير شهادة الخبرة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Certificate content
      expect(find.text('شهادة خبرة وتقدير تطوعي'), findsOneWidget);
      expect(find.text('التحقق المشفر الفوري'), findsOneWidget);
      expect(find.text('رمز الوثيقة: ATHAR-CERT-2026-101'), findsOneWidget);
      expect(find.text('مشاركة الشهادة'), findsOneWidget);
    });

    testWidgets('4. VolunteerMainScreen & VolunteerDashboardScreen: 5-Tab field mode navigation', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const VolunteerMainScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify 5 navigation tabs
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('الماسح'), findsOneWidget);
      expect(find.text('الكشف'), findsOneWidget);
      expect(find.text('الجواز'), findsOneWidget);
      expect(find.text('الملف'), findsOneWidget);

      // Dashboard should display emergency mission alert and field operations hub
      expect(find.text('لوحة العمليات الميدانية'), findsOneWidget);
      expect(find.text('نداء استغاثة طارئ نشط'), findsOneWidget);
      expect(find.text('غرفة العمليات الميدانية'), findsOneWidget);
      expect(find.text('ماسح الإغاثة NFC'), findsOneWidget);
      expect(find.text('الكشف الميداني'), findsOneWidget);

      // Switch tab to 'الماسح'
      await tester.tap(find.text('الماسح'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('ماسح الإغاثة والبطاقات الذكية'), findsOneWidget);

      // Switch tab to 'الكشف'
      await tester.tap(find.text('الكشف'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('استمارة الكشف الميداني'), findsOneWidget);

      // Switch tab to 'الجواز'
      await tester.tap(find.text('الجواز'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('جواز التطوع الرقمي المعتمد'), findsOneWidget);
    });

    testWidgets('5. EmergencyMissionsScreen: renders active missions and handles join and check-in', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const EmergencyMissionsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('نداءات الطوارئ والاستجابة السريعة'), findsOneWidget);
      expect(find.text('نداء إغاثة طارئ: عاصفة ثلجية في مخيمات الشمال'), findsOneWidget);
      expect(find.text('حرج جداً'), findsOneWidget);
      expect(find.text('انضمام للمهمة'), findsOneWidget);
      expect(find.text('تسجيل وصول'), findsOneWidget);

      // Tap join
      await tester.tap(find.text('انضمام للمهمة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('تم انضمامك إلى مهمة الطوارئ الميدانية بنجاح!'), findsOneWidget);

      // Tap check-in
      await tester.tap(find.text('تسجيل وصول'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('تم تأكيد الوصول الميداني!'), findsOneWidget);
    });
  });
}
