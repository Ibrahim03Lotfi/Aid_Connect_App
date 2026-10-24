import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aid_connect/features/user/presentation/screens/request_aid_wizard_screen.dart';
import 'package:aid_connect/features/user/presentation/screens/case_tracking_screen.dart';
import 'package:aid_connect/features/user/presentation/screens/join_volunteer_screen.dart';
import 'package:aid_connect/features/user/presentation/widgets/impact_stories_reel.dart';

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

  group('Phase 2: Citizen & Donor Experience Automated Tests', () {
    testWidgets('1. Request Aid Wizard 3-Step Flow & Submission Dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const RequestAidWizardScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 1: Category Picker
      expect(find.text('رعاية صحية وعمليات'), findsOneWidget);
      expect(find.text('سلة غذائية وإطعام'), findsOneWidget);
      expect(find.text('المتابعة للخطوة التالية'), findsOneWidget);

      // Advance to Step 2
      await tester.tap(find.text('المتابعة للخطوة التالية'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 2: Family Count & Location & Urgency
      expect(find.text('عدد أفراد الأسرة المقيمين معاً'), findsOneWidget);
      expect(find.text('المحافظة'), findsOneWidget);
      expect(find.text('درجة الاستعجال'), findsOneWidget);

      // Advance to Step 3
      await tester.tap(find.text('المتابعة للخطوة التالية'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Step 3: Evidence & Attachments
      expect(find.text('إرفاق الوثائق أو رسالة صوتية'), findsOneWidget);
      expect(find.text('إرسال الطلب للاعتماد'), findsOneWidget);

      // Submit Form
      await tester.tap(find.text('إرسال الطلب للاعتماد'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Success Dialog with tracking code and actions
      expect(find.text('تم استلام طلبكم بنجاح!'), findsOneWidget);
      expect(find.text('ATHAR-REQ-2026-91'), findsOneWidget);
      expect(find.text('تتبع مسار الطلب فوراً'), findsOneWidget);
      expect(find.text('العودة للرئيسية'), findsOneWidget);
    });

    testWidgets('2. Case Delivery Tracking Screen & 4-Stage Timeline', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const CaseTrackingScreen(initialCode: 'ATHAR-REQ-2026-91')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header and Code
      expect(find.text('تتبع الحالة'), findsOneWidget);
      expect(find.text('كود التتبع: ATHAR-REQ-2026-91'), findsOneWidget);

      // Verify 4-Stage Live Tracking Timeline Steps
      expect(find.text('تقديم الطلب والتدقيق الذكي'), findsOneWidget);
      expect(find.text('الكشف الميداني من المتطوع'), findsOneWidget);
      expect(find.text('تجهيز وصرف المساعدة من المستودع'), findsOneWidget);
      expect(find.text('التسليم الميداني والتوثيق عبر البطاقة الذكية NFC'), findsOneWidget);
    });

    testWidgets('3. Join as a Volunteer Funnel Screen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const JoinVolunteerScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Volunteer Screen Header & Skills
      expect(find.text('الانضمام كمتطوع'), findsOneWidget);
      expect(find.text('مسعف / كادر تمريض'), findsOneWidget);
      expect(find.text('سائق سيارة / نقل إغاثي'), findsOneWidget);
      expect(find.text('كشف وبحث ميداني'), findsOneWidget);
      expect(find.text('إرسال طلب الانضمام لفريق أثر'), findsOneWidget);

      // Submit Volunteer Application
      await tester.tap(find.text('إرسال طلب الانضمام لفريق أثر'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Volunteer Success Dialog
      expect(find.text('أهلاً بك في عائلة أثر!'), findsOneWidget);
      expect(find.text('العودة للرئيسية'), findsOneWidget);
    });

    testWidgets('4. Top Impact Stories Reel Widget', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const Scaffold(body: ImpactStoriesReel())));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Stories Title & Content
      expect(find.text('أثر في الميدان (سلسلة أثر)'), findsOneWidget);
      expect(find.text('توثيق حي'), findsOneWidget);
      expect(find.text('دفء ريف دمشق'), findsOneWidget);
    });
  });
}
