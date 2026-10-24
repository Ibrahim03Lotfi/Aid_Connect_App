<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تقرير الأثر الإنساني السنوي المعتمد {{ $year }} | منظمة أَثَــر</title>

    <!-- Google Fonts: IBM Plex Sans Arabic + JetBrains Mono -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">

    <!-- FontAwesome 6 Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>

    <style>
        body { 
            font-family: 'IBM Plex Sans Arabic', -apple-system, BlinkMacSystemFont, sans-serif;
            letter-spacing: -0.01em;
        }
        .font-num {
            font-family: 'JetBrains Mono', 'IBM Plex Sans Arabic', monospace;
        }
        @media print {
            .no-print { display: none !important; }
            body { background: white !important; color: #000000 !important; padding: 0 !important; }
            .print-border { border: 1px solid #e4e4e7 !important; }
            .page-break { page-break-after: always; }
        }
    </style>
</head>
<body class="bg-zinc-100 text-zinc-900 min-h-screen p-4 sm:p-8">

    <!-- Print & Back Actions Bar (Hidden in Print) -->
    <div class="max-w-4xl mx-auto mb-4 flex items-center justify-between no-print bg-white p-3 rounded-md border border-zinc-200">
        <div class="flex items-center gap-3">
            <a href="{{ route('dashboard.index') }}" class="text-xs font-medium text-zinc-600 hover:text-zinc-900 px-3 py-1.5 rounded border border-zinc-200 hover:bg-zinc-50 transition-colors">
                &rarr; العودة لغرفة العمليات
            </a>
            <span class="text-xs text-zinc-400 font-num">REF: ATHAR-DOC-{{ $year }}</span>
        </div>

        <button onclick="window.print()" class="bg-zinc-900 text-white hover:bg-zinc-800 text-xs font-medium px-4 py-1.5 rounded transition-colors">
            طباعة الوثيقة الرسمية (PDF)
        </button>
    </div>

    <!-- Official Report Document (Sovereign Letterhead Document) -->
    <div class="max-w-4xl mx-auto bg-white border border-zinc-300 p-8 sm:p-12 space-y-8 text-zinc-900 shadow-sm">

        <!-- 1. Official Letterhead Header -->
        <div class="flex items-start justify-between border-b-2 border-zinc-900 pb-5">
            <div class="space-y-1">
                <h1 class="text-lg font-bold text-zinc-900">مـنـظـمـة أَثَـــــــر لـلإغـاثـة والـتـنـمـيـة</h1>
                <p class="text-xs text-zinc-500 font-medium">الجمهورية العربية السورية • وزارة الشؤون الاجتماعية والعمل • رخصة رقم: SY-ATHAR-2026</p>
                <p class="text-[11px] font-num text-zinc-400">Athar Humanitarian & Operations Operating System</p>
            </div>

            <div class="text-left font-num text-xs space-y-0.5 text-zinc-600">
                <div>رقم الوثيقة: <strong>REP-ATHAR-{{ $year }}-091</strong></div>
                <div>تاريخ الإصدار: <strong>{{ date('Y-m-d') }}</strong></div>
                <div>التصنيف: <strong>عام / تدقيق مالي وإنساني</strong></div>
            </div>
        </div>

        <!-- 2. Report Title & Context -->
        <div class="text-center space-y-1 py-1">
            <div class="text-xs font-semibold text-zinc-400 font-num uppercase tracking-wider">Annual Operations Audit</div>
            <h2 class="text-xl sm:text-2xl font-bold text-zinc-900">تقرير الأثر الإنساني السنوي والشفافية الرقمية ({{ $year }})</h2>
            <p class="text-xs text-zinc-500 max-w-2xl mx-auto leading-relaxed">
                تقرير رسمي صادر وموثق رقمياً لكافة العمليات الإغاثية الميدانية في المحافظات السورية لعام {{ $year }}، المسجلة بالتحقق اللاتلامسي والفرز الآلي.
            </p>
        </div>

        <!-- 3. Key Operational KPIs Grid (Sober, Monochromatic Table) -->
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
            <div class="border border-zinc-200 p-3 rounded">
                <span class="text-[11px] text-zinc-500 block mb-1">الأسر المستفيدة</span>
                <span class="text-xl font-bold font-num text-zinc-900">{{ number_format($totalFamilies) }}</span>
                <span class="text-[10px] text-zinc-400 block mt-0.5">موثقة بالرقم الوطني</span>
            </div>

            <div class="border border-zinc-200 p-3 rounded">
                <span class="text-[11px] text-zinc-500 block mb-1">تسليمات المعونة (NFC)</span>
                <span class="text-xl font-bold font-num text-zinc-900">{{ number_format($totalDistributions) }}</span>
                <span class="text-[10px] text-zinc-400 block mt-0.5">عملية استلام لاتلامسية</span>
            </div>

            <div class="border border-zinc-200 p-3 rounded">
                <span class="text-[11px] text-zinc-500 block mb-1">ساعات الخدمة الميدانية</span>
                <span class="text-xl font-bold font-num text-zinc-900">{{ number_format($totalHours) }}</span>
                <span class="text-[10px] text-zinc-400 block mt-0.5">ساعة تطوع موثقة</span>
            </div>

            <div class="border border-zinc-200 p-3 rounded">
                <span class="text-[11px] text-zinc-500 block mb-1">المخصصات المصروفة</span>
                <span class="text-xl font-bold font-num text-zinc-900">{{ number_format($fundsDisbursed) }}</span>
                <span class="text-[10px] text-zinc-400 block mt-0.5">ليرة سورية (شام كاش)</span>
            </div>
        </div>

        <!-- 4. Integrity and Double-Dipping Prevention Standards -->
        <div class="border border-zinc-200 p-4 rounded space-y-2 text-xs">
            <h3 class="font-semibold text-zinc-900">معايير الحوكمة ومنع التكرار المعتمدة</h3>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 text-[11px] text-zinc-600">
                <div class="p-2.5 bg-zinc-50 rounded border border-zinc-100">
                    <strong class="text-zinc-900 block mb-0.5">١. التدقيق الذكي للوثائق الطبية</strong>
                    <p>مطابقة حسابية تامة لبنود العمليات الجراحية بالرؤية الحاسوبية.</p>
                </div>
                <div class="p-2.5 bg-zinc-50 rounded border border-zinc-100">
                    <strong class="text-zinc-900 block mb-0.5">٢. كشف الاحتيال ببصمة الصورة</strong>
                    <p>فحص بصمة dHash لكل مرفق لمنع تدوير الصور المكررة.</p>
                </div>
                <div class="p-2.5 bg-zinc-50 rounded border border-zinc-100">
                    <strong class="text-zinc-900 block mb-0.5">٣. المنع التام للازدواجية (NFC)</strong>
                    <p>ربط كل حصة برمز مشفر يمنع ازدواجية الصرف بنسبة مطلقة.</p>
                </div>
            </div>
        </div>

        <!-- 5. Geographical Distribution Breakdown -->
        <div class="space-y-2 text-xs">
            <h3 class="font-semibold text-zinc-900">التوزيع الجغرافي للأسر المستفيدة في المحافظات</h3>
            <table class="w-full text-right border border-zinc-200 text-xs">
                <thead class="bg-zinc-50 font-medium text-zinc-600 border-b border-zinc-200">
                    <tr>
                        <th class="p-2.5 font-normal">المحافظة</th>
                        <th class="p-2.5 font-normal">عدد الأسر المستفيدة</th>
                        <th class="p-2.5 font-normal">نسبة التغطية</th>
                        <th class="p-2.5 font-normal">المستودع الإقليمي</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-200 font-num text-zinc-700">
                    @foreach($topGovernorates as $gov)
                        <tr>
                            <td class="p-2.5 font-sans font-medium text-zinc-900">{{ $gov->name }}</td>
                            <td class="p-2.5">{{ number_format($gov->family_count) }} أسرة</td>
                            <td class="p-2.5 font-semibold text-zinc-900">{{ round(($gov->family_count / max(1, $totalFamilies)) * 100, 1) }}%</td>
                            <td class="p-2.5 font-sans text-zinc-500">متصل بالشبكة</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        <!-- 6. Signatures & Verification Seal -->
        <div class="pt-6 border-t border-zinc-200 grid grid-cols-3 gap-4 items-center text-center text-xs">
            <div class="space-y-1">
                <p class="text-zinc-400 text-[11px]">إدارة العمليات الميدانية</p>
                <div class="font-semibold text-zinc-900">م. إبراهيم لطفي</div>
                <div class="text-[10px] font-num text-zinc-400">ATHAR-OPS-DIR</div>
            </div>

            <!-- Verification QR -->
            <div class="space-y-1">
                <div class="w-14 h-14 bg-zinc-900 text-white rounded mx-auto flex items-center justify-center p-1">
                    <i class="fa-solid fa-qrcode text-3xl"></i>
                </div>
                <p class="text-[9px] font-num text-zinc-400">VERIFY: ATHAR.SY/CERT</p>
            </div>

            <div class="space-y-1">
                <p class="text-zinc-400 text-[11px]">مشروع التخرج والتحكيم</p>
                <div class="font-semibold text-zinc-900">كلية الهندسة المعلوماتية</div>
                <div class="text-[10px] text-zinc-400">قسم هندسة البرمجيات</div>
            </div>
        </div>

    </div>

</body>
</html>
