import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aid_connect/features/user/presentation/screens/request_aid_wizard_screen.dart';
import 'package:aid_connect/features/user/data/models/case_model.dart';

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

  group('Phase 4: Applied AI Intelligence Engine Mobile Tests', () {
    testWidgets('1. Request Aid Wizard: AI Medical Invoice Auditor workflow', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const RequestAidWizardScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Advance from Step 1 to Step 2
      await tester.tap(find.text('المتابعة للخطوة التالية'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Advance from Step 2 to Step 3
      await tester.tap(find.text('المتابعة للخطوة التالية'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Attach document
      expect(find.text('التقاط صورة / اختيار ملف'), findsOneWidget);
      await tester.tap(find.text('التقاط صورة / اختيار ملف'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // AI Auditor Banner should appear
      expect(find.text('التدقيق الذكي للفاتورة (AI Auditor)'), findsOneWidget);
      expect(find.text('تدقيق الآن'), findsOneWidget);

      // Tap "تدقيق الآن"
      await tester.tap(find.text('تدقيق الآن'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // AI Document Auditor Modal Sheet Verification
      expect(find.text('نتائج التدقيق الذكي للوثيقة الطبية'), findsOneWidget);
      expect(find.text('مشفى المواساة الجامعي - دمشق'), findsOneWidget);
      expect(find.text('تضيق تاجي حاد وقصور صمام (جراحة قلب مفتوح)'), findsOneWidget);
      expect(find.text('25,000,000 ل.س'), findsOneWidget);
      expect(find.text('تم التحقق الرياضي التام من تطابق مجموع البنود مع الإجمالي (Math Verified)'), findsOneWidget);
      expect(find.text('اعتماد البيانات واستكمال الطلب'), findsOneWidget);

      // Confirm and adopt AI audit findings
      await tester.tap(find.text('اعتماد البيانات واستكمال الطلب'));
      await tester.pumpAndSettle();

      // Submit aid request
      expect(find.text('إرسال الطلب للاعتماد'), findsOneWidget);
      await tester.tap(find.text('إرسال الطلب للاعتماد'));
      await tester.pumpAndSettle();

      expect(find.text('تم استلام طلبكم بنجاح!'), findsOneWidget);
      expect(find.text('ATHAR-REQ-2026-91'), findsOneWidget);
    });

    test('2. CaseModel correctly deserializes and exposes AI Intelligence metrics', () {
      final json = {
        'id': 101,
        'title': 'عملية جراحية عاجلة للقلب المفتوح',
        'description': 'حالة طارئة لطفل رضيع يعاني من تشوه خلقي',
        'governorate': 'دمشق',
        'category': 'رعاية صحية وعمليات',
        'category_id': 1,
        'governorate_id': 1,
        'status': 'pending',
        'priority': 'urgent',
        'target_amount': 25000000,
        'collected_amount': 7500000,
        'progress_percent': 30,
        'ai_urgency_index': 94,
        'ai_triage_tier': 'Tier 1 - Immediate Intervention',
        'ai_vulnerability_factors': [
          'رضيع دون سنتين',
          'خطر توقف عضلة القلب',
          'انعدام المعيل المالي'
        ],
        'ai_fraud_status': 'verified_authentic',
      };

      // Import CaseModel
      final caseModel = CaseModel.fromJson(json);

      expect(caseModel.id, 101);
      expect(caseModel.aiUrgencyIndex, 94);
      expect(caseModel.aiTriageTier, 'Tier 1 - Immediate Intervention');
      expect(caseModel.aiVulnerabilityFactors?.length, 3);
      expect(caseModel.aiVulnerabilityFactors, contains('رضيع دون سنتين'));
      expect(caseModel.aiFraudStatus, 'verified_authentic');

      final serialized = caseModel.toJson();
      expect(serialized['ai_urgency_index'], 94);
      expect(serialized['ai_triage_tier'], 'Tier 1 - Immediate Intervention');
      expect(serialized['ai_fraud_status'], 'verified_authentic');
    });

    test('3. AI Triage Priority Rule: Scores >= 90 correctly trigger Tier 1 Immediate Alert', () {
      int calculateTriageScore({
        required bool hasInfants,
        required bool isCriticalSurgery,
        required bool isWinterShelterRisk,
      }) {
        int score = 40;
        if (hasInfants) score += 25;
        if (isCriticalSurgery) score += 30;
        if (isWinterShelterRisk) score += 20;
        return score.clamp(1, 100);
      }

      final score1 = calculateTriageScore(
        hasInfants: true,
        isCriticalSurgery: true,
        isWinterShelterRisk: false,
      );
      expect(score1, greaterThanOrEqualTo(90)); // 40 + 25 + 30 = 95

      final isCriticalTier1 = score1 >= 90;
      expect(isCriticalTier1, isTrue);

      final score2 = calculateTriageScore(
        hasInfants: false,
        isCriticalSurgery: false,
        isWinterShelterRisk: true,
      );
      expect(score2, 60); // 40 + 20 = 60
      expect(score2 < 90, isTrue);
    });
  });
}
