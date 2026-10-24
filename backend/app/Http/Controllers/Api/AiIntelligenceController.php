<?php

namespace App\Http\Controllers\Api;

use App\Models\AidCase;
use App\Models\EmergencyMission;
use App\Services\Ai\ArabicTriageClassifierService;
use App\Services\Ai\DocumentAuditorService;
use App\Services\Ai\ImageFingerprintService;
use App\Services\Ai\ShelterVisualAnalyzerService;
use App\Services\Ai\VolunteerMatchmakerService;
use Illuminate\Http\Request;

class AiIntelligenceController extends ApiController
{
    public function __construct(
        protected DocumentAuditorService $documentAuditor,
        protected ShelterVisualAnalyzerService $shelterAnalyzer,
        protected ArabicTriageClassifierService $triageClassifier,
        protected ImageFingerprintService $fingerprintService,
        protected VolunteerMatchmakerService $matchmaker
    ) {}

    /**
     * 4.1 Audit printed medical invoice / hospital document.
     */
    public function auditInvoice(Request $request)
    {
        $request->validate([
            'document' => 'required|file|mimes:jpeg,png,jpg,webp,pdf|max:10240',
            'context_hint' => 'nullable|string|max:255',
        ]);

        $file = $request->file('document');
        $hint = $request->input('context_hint');

        $result = $this->documentAuditor->auditDocument($file, $hint);

        return $this->successResponse($result, 'تم تدقيق الوثيقة الطبية واستخراج البيانات آلياً بنجاح');
    }

    /**
     * 4.2 Analyze shelter and structural damage photos.
     */
    public function analyzeShelter(Request $request)
    {
        $request->validate([
            'photos' => 'nullable|array',
            'photos.*' => 'file|mimes:jpeg,png,jpg,webp|max:10240',
            'living_condition_score' => 'nullable|integer|min:1|max:10',
            'housing_type' => 'nullable|string|max:100',
            'heating_available' => 'nullable|boolean',
            'inspector_notes' => 'nullable|string',
        ]);

        $photos = $request->file('photos') ?? [];
        $metadata = $request->only([
            'living_condition_score',
            'housing_type',
            'heating_available',
            'inspector_notes',
        ]);

        $result = $this->shelterAnalyzer->analyzeShelterPhotos($photos, $metadata);

        return $this->successResponse($result, 'تم تحليل صور المسكن وتقييم مستوى الخطر الإنشائي بنجاح');
    }

    /**
     * 4.3 Arabic NLP Urgency & Triage Classifier.
     */
    public function triageCase(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'target_amount' => 'nullable|numeric',
            'category_id' => 'nullable|integer',
            'governorate_id' => 'nullable|integer',
        ]);

        $result = $this->triageClassifier->classifyCase(
            $request->input('title'),
            $request->input('description'),
            $request->only(['target_amount', 'category_id', 'governorate_id'])
        );

        return $this->successResponse($result, 'تم حساب مؤشر الأولوية الإنساني وتصنيف الحالة بنجاح');
    }

    /**
     * 4.4 Perceptual Image Fingerprinting & Fraud Detection.
     */
    public function checkImageFraud(Request $request)
    {
        $request->validate([
            'image' => 'required|file|mimes:jpeg,png,jpg,webp|max:10240',
            'case_id' => 'nullable|integer',
        ]);

        $file = $request->file('image');
        $excludeCaseId = $request->input('case_id');

        $result = $this->fingerprintService->checkFraud($file, $excludeCaseId);

        return $this->successResponse($result, 'تم فحص البصمة البصرية الرقمية للصورة والتأكد من عدم تكرارها');
    }

    /**
     * 4.5 Intelligent Volunteer Matchmaker.
     */
    public function matchVolunteers($missionId)
    {
        $mission = EmergencyMission::with('governorate')->findOrFail($missionId);

        $result = $this->matchmaker->matchVolunteersForMission($mission);

        return $this->successResponse($result, 'تم ترشيح أفضل المتطوعين للمهمة الطارئة وفق المهارات والقرب الجغرافي');
    }

    /**
     * 4.6 Full Comprehensive AI Audit on an existing case.
     */
    public function fullCaseAiAudit($caseId)
    {
        $case = AidCase::with(['category', 'governorate', 'images', 'attachments'])->findOrFail($caseId);

        // 1. NLP Triage
        $triage = $this->triageClassifier->classifyCase(
            $case->title,
            $case->description,
            ['target_amount' => $case->target_amount]
        );

        // Update case with triage score
        $case->update([
            'ai_urgency_index' => $triage['urgency_index'],
            'ai_triage_tier' => $triage['triage_tier'],
            'ai_vulnerability_factors' => $triage['key_vulnerability_factors'],
        ]);

        return $this->successResponse([
            'case_id' => $case->id,
            'title' => $case->title,
            'ai_triage' => $triage,
            'fraud_status' => $case->ai_fraud_status,
            'invoice_data' => $case->ai_invoice_data,
        ], 'تم إجراء التدقيق الذكي الشامل للحالة بنجاح');
    }
}
