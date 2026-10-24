@extends('layouts.dashboard')

@section('title', 'مختبر الذكاء الاصطناعي ومكافحة الاحتيال')
@section('page_title', 'مختبر الذكاء الاصطناعي وكشف التزوير (AI Intelligence Lab)')

@section('content')
<div class="space-y-6">

    <!-- 4 Core AI Engine Architectures -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <!-- Engine 1 -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1.5">
            <div class="flex items-center justify-between text-xs text-zinc-500 font-medium">
                <span>بصمة الصورة الإدراكية</span>
                <span class="w-2 h-2 rounded-full bg-emerald-600"></span>
            </div>
            <div class="text-xl font-semibold font-num text-zinc-900 dark:text-zinc-100">64-bit dHash Engine</div>
            <div class="text-[11px] text-zinc-400">
                حساب المسافة الرياضية (Hamming Distance) لكشف الصور المكررة والمعدلة.
            </div>
            <div class="text-[10px] font-num text-zinc-500 pt-1 border-t border-zinc-100 dark:border-zinc-800">
                {{ $totalFingerprints }} بصمة مسجلة في السجل
            </div>
        </div>

        <!-- Engine 2 -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1.5">
            <div class="flex items-center justify-between text-xs text-zinc-500 font-medium">
                <span>مصنف الفرز الذكي (NLP)</span>
                <span class="w-2 h-2 rounded-full bg-emerald-600"></span>
            </div>
            <div class="text-xl font-semibold font-num text-zinc-900 dark:text-zinc-100">Arabic Urgency NLP</div>
            <div class="text-[11px] text-zinc-400">
                تحليل لغوي لسياق الاستغاثة واستخراج مؤشرات الخطر وتقسيم الحالات إلى Tiers.
            </div>
            <div class="text-[10px] font-num text-zinc-500 pt-1 border-t border-zinc-100 dark:border-zinc-800">
                {{ $highRiskCases }} حالة مصنفة كـ High/Critical
            </div>
        </div>

        <!-- Engine 3 -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1.5">
            <div class="flex items-center justify-between text-xs text-zinc-500 font-medium">
                <span>مدقق الوثائق والفواتير</span>
                <span class="w-2 h-2 rounded-full bg-emerald-600"></span>
            </div>
            <div class="text-xl font-semibold font-num text-zinc-900 dark:text-zinc-100">Multimodal OCR & Math</div>
            <div class="text-[11px] text-zinc-400">
                تدقيق الفواتير الطبية والعمليات الجراحية والتحقق الرياضي من صحة البنود.
            </div>
            <div class="text-[10px] font-num text-zinc-500 pt-1 border-t border-zinc-100 dark:border-zinc-800">
                Gemini 1.5 Vision Core API
            </div>
        </div>

        <!-- Engine 4 -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1.5">
            <div class="flex items-center justify-between text-xs text-zinc-500 font-medium">
                <span>محرك المطابقة التوزيعية</span>
                <span class="w-2 h-2 rounded-full bg-emerald-600"></span>
            </div>
            <div class="text-xl font-semibold font-num text-zinc-900 dark:text-zinc-100">Heuristic Dispatch</div>
            <div class="text-[11px] text-zinc-400">
                مطابقة مهارات المتطوعين والموقع الجغرافي لمهام الطوارئ والكشوفات.
            </div>
            <div class="text-[10px] font-num text-zinc-500 pt-1 border-t border-zinc-100 dark:border-zinc-800">
                خوارزمية الإسناد الميداني الذكي
            </div>
        </div>
    </div>

    <!-- Live Interactive AI Triage Simulator (Test Bench) -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-6 space-y-4">
        <div class="border-b border-zinc-200 dark:border-zinc-800 pb-3 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">منصة الفحص والتدقيق المباشر لمحرك الفرز اللغوي (Live AI Triage Engine)</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">نظام تدقيق وتحليل فوري لنصوص الحالات الإنسانية لتقييم درجة الخطورة ومؤشر الاستعجال آلياً</p>
            </div>
            <span class="text-[10px] font-num text-zinc-400">v1.2.0 • Real-time Heuristic</span>
        </div>

        <form action="{{ route('dashboard.ai.simulate') }}" method="POST" class="space-y-3">
            @csrf
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                <div class="sm:col-span-1">
                    <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">عنوان الحالة</label>
                    <input type="text" name="title" required value="{{ old('title', $simulatedInput['title'] ?? 'حالة طارئة: طفل رضيع بحاجة عملية قلب مفتوح عاجلة') }}" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 outline-none">
                </div>
                <div class="sm:col-span-2">
                    <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">وصف الحالة والتفاصيل الإنسانية</label>
                    <input type="text" name="description" required value="{{ old('description', $simulatedInput['description'] ?? 'انهيار سقف المنزل بفعل السيول، والعائلة أيتام دون معيل مع وجود طفل رضيع يعاني من برد قارس ونقص حاد في العلاج') }}" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 outline-none">
                </div>
            </div>

            <div class="flex items-center justify-end">
                <button type="submit" class="px-4 py-2 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-xs font-medium hover:bg-zinc-800 dark:hover:bg-white flex items-center gap-2 transition-colors">
                    <i class="fa-solid fa-bolt text-xs"></i>
                    <span>تشغيل التحليل الفوري بالذكاء الاصطناعي</span>
                </button>
            </div>
        </form>

        <!-- Simulation Results Display -->
        @if($simulationResult)
            <div class="mt-4 p-4 rounded-lg bg-zinc-50 dark:bg-zinc-800/60 border border-zinc-200 dark:border-zinc-700 space-y-3">
                <div class="flex items-center justify-between border-b border-zinc-200 dark:border-zinc-700 pb-2">
                    <span class="text-xs font-semibold text-zinc-900 dark:text-zinc-100">نتائج الفحص والتحليل التلقائي:</span>
                    <span class="text-[10px] font-num text-zinc-400">{{ $simulationResult['engine'] }}</span>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <div>
                        <div class="text-[11px] text-zinc-400">مؤشر الاستعجال (Urgency Index)</div>
                        <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100 mt-0.5">
                            {{ $simulationResult['urgency_index'] }} <span class="text-xs text-zinc-400 font-normal">/ 100</span>
                        </div>
                    </div>

                    <div>
                        <div class="text-[11px] text-zinc-400">مستوى التدخل (Triage Tier)</div>
                        <div class="text-xs font-semibold mt-1" style="color: {{ $simulationResult['badge_color'] }};">
                            {{ $simulationResult['tier_label'] }}
                        </div>
                    </div>

                    <div>
                        <div class="text-[11px] text-zinc-400">الإجراء الإداري الموصى به</div>
                        <div class="text-xs text-zinc-700 dark:text-zinc-300 mt-1">
                            {{ $simulationResult['recommended_action'] }}
                        </div>
                    </div>
                </div>

                @if(!empty($simulationResult['key_vulnerability_factors']))
                    <div class="pt-2 border-t border-zinc-200 dark:border-zinc-700">
                        <div class="text-[11px] text-zinc-400 mb-1.5">عوامل الهشاشة والخطر المكتشفة لغوياً:</div>
                        <div class="flex flex-wrap gap-1.5">
                            @foreach($simulationResult['key_vulnerability_factors'] as $factor)
                                <span class="px-2 py-0.5 rounded bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-700 text-[11px] text-zinc-800 dark:text-zinc-200 font-medium">
                                    • {{ $factor }}
                                </span>
                            @endforeach
                        </div>
                    </div>
                @endif
            </div>
        @endif
    </div>

    <!-- Scanned Image Fingerprints Log (dHash Database) -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل بصمات الصور الرقمية المحفوظة (Perceptual Hash Registry)</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">البصمات المشفرة المخزنة لمنع رفع نفس الصور في حملات تبرع أخرى</p>
            </div>
            <span class="text-[11px] text-zinc-400 font-num">64-bit Hex Registry</span>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">الحالة المرتبطة</th>
                        <th class="px-4 py-2.5 font-normal">بصمة الصورة المشفرة (dHash 64-bit)</th>
                        <th class="px-4 py-2.5 font-normal">مسار الصورة</th>
                        <th class="px-4 py-2.5 font-normal">حالة الفحص</th>
                        <th class="px-4 py-2.5 font-normal">تاريخ الاحتساب</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($fingerprints as $fp)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $fp->case?->title ?? 'حالة إغاثية مسجلة' }}</div>
                                <div class="text-[10px] text-zinc-400 font-num">Case ID: #{{ $fp->case_id }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-zinc-900 dark:text-zinc-100 font-medium">
                                <code class="bg-zinc-100 dark:bg-zinc-800 px-1.5 py-0.5 rounded text-[11px]">{{ $fp->phash }}</code>
                            </td>
                            <td class="px-4 py-3 text-zinc-500 font-num text-[11px] max-w-xs truncate">
                                {{ $fp->image_path }}
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                <span class="text-emerald-700 dark:text-emerald-400 font-medium">فريدة ومؤكدة (Verified Clean)</span>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px] text-zinc-400">
                                {{ $fp->created_at?->diffForHumans() ?? 'مؤخراً' }}
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="px-4 py-8 text-center text-zinc-400">
                                لا توجد بصمات صور مسجلة حتى الآن
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

</div>
@endsection
