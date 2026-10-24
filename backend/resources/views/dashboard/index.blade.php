@extends('layouts.dashboard')

@section('title', 'غرفة العمليات المركزية ومؤشرات الأداء')
@section('page_title', 'غرفة العمليات المركزية • المؤشرات الحية')

@section('content')
<div class="space-y-6">

    <!-- Top Operations Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-2 border-b border-zinc-200 dark:border-zinc-800">
        <div>
            <h1 class="text-base font-semibold text-zinc-900 dark:text-zinc-100">غرفة العمليات المركزية</h1>
            <p class="text-xs text-zinc-500 dark:text-zinc-400">إدارة وتوثيق تدفق المساعدات الميدانية والتحقق اللاتلامسي عبر المحافظات السورية</p>
        </div>
        <div class="flex items-center gap-2 text-xs text-zinc-500 font-num">
            <span>التغطية: {{ \App\Models\Governorate::count() }} محافظة • {{ \App\Models\Warehouse::count() }} مركز توزيع</span>
        </div>
    </div>

    <!-- 5.1 Primary Metrics Grid (Sleek, Purposeful, Semantic Spotlight) -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        
        <!-- Metric 1: Total families aided this month (Success / Verified Metric) -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 border-t-2 border-t-emerald-600 rounded-lg p-4 space-y-2 shadow-xs transition-shadow hover:shadow-sm">
            <div class="flex items-center justify-between">
                <span class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">العائلات المستفيدة هذا الشهر</span>
                <div class="w-7 h-7 rounded bg-emerald-50 dark:bg-emerald-950/50 text-emerald-600 dark:text-emerald-400 flex items-center justify-center text-xs">
                    <i class="fa-solid fa-people-roof"></i>
                </div>
            </div>
            <div class="text-2xl sm:text-3xl font-bold font-num text-zinc-900 dark:text-zinc-100 tracking-tight">
                {{ number_format($totalFamiliesAidedMonth) }}
            </div>
            <div class="pt-1 border-t border-zinc-100 dark:border-zinc-800/60 flex items-center justify-between text-[11px]">
                <span class="inline-flex items-center gap-1 text-emerald-700 dark:text-emerald-400 font-medium">
                    <i class="fa-solid fa-circle-check text-[10px]"></i> موثقة ببطاقة NFC
                </span>
                <span class="font-num text-[10px] text-zinc-400">100% Verified</span>
            </div>
        </div>

        <!-- Metric 2: Active volunteers currently in field (Operational Activity) -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 border-t-2 border-t-sky-500 rounded-lg p-4 space-y-2 shadow-xs transition-shadow hover:shadow-sm">
            <div class="flex items-center justify-between">
                <span class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">متطوعون نشطون في الميدان</span>
                <div class="w-7 h-7 rounded bg-sky-50 dark:bg-sky-950/50 text-sky-600 dark:text-sky-400 flex items-center justify-center text-xs">
                    <i class="fa-solid fa-person-walking-luggage"></i>
                </div>
            </div>
            <div class="text-2xl sm:text-3xl font-bold font-num text-zinc-900 dark:text-zinc-100 tracking-tight">
                {{ number_format($activeVolunteersInField) }}
            </div>
            <div class="pt-1 border-t border-zinc-100 dark:border-zinc-800/60 flex items-center justify-between text-[11px]">
                <span class="inline-flex items-center gap-1 text-sky-700 dark:text-sky-400 font-medium">
                    <i class="fa-solid fa-satellite-dish text-[10px]"></i> فرق التوزيع والكشف
                </span>
                <span class="font-num text-[10px] text-zinc-400">Live Roster</span>
            </div>
        </div>

        <!-- Metric 3: Pending field visits (Attention Required / Pending Review) -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 border-t-2 border-t-amber-500 rounded-lg p-4 space-y-2 shadow-xs transition-shadow hover:shadow-sm">
            <div class="flex items-center justify-between">
                <span class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">زيارات ميدانية قيد الانتظار</span>
                <div class="w-7 h-7 rounded bg-amber-50 dark:bg-amber-950/50 text-amber-600 dark:text-amber-400 flex items-center justify-center text-xs">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                </div>
            </div>
            <div class="text-2xl sm:text-3xl font-bold font-num text-zinc-900 dark:text-zinc-100 tracking-tight">
                {{ number_format($pendingFieldVisits) }}
            </div>
            <div class="pt-1 border-t border-zinc-100 dark:border-zinc-800/60 flex items-center justify-between text-[11px]">
                <span class="inline-flex items-center gap-1 text-amber-700 dark:text-amber-400 font-medium">
                    <i class="fa-solid fa-clipboard-question text-[10px]"></i> بانتظار الكشف الاجتماعي
                </span>
                <span class="font-num text-[10px] text-amber-600 dark:text-amber-400 font-medium">Queue</span>
            </div>
        </div>

        <!-- Metric 4: Warehouse aid packages remaining (Logistics Readiness) -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 border-t-2 border-t-teal-600 rounded-lg p-4 space-y-2 shadow-xs transition-shadow hover:shadow-sm">
            <div class="flex items-center justify-between">
                <span class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">الطرود الإغاثية الجاهزة</span>
                <div class="w-7 h-7 rounded bg-teal-50 dark:bg-teal-950/50 text-teal-600 dark:text-teal-400 flex items-center justify-center text-xs">
                    <i class="fa-solid fa-boxes-packing"></i>
                </div>
            </div>
            <div class="text-2xl sm:text-3xl font-bold font-num text-zinc-900 dark:text-zinc-100 tracking-tight">
                {{ number_format($warehousePackagesRemaining) }}
            </div>
            <div class="pt-1 border-t border-zinc-100 dark:border-zinc-800/60 flex items-center justify-between text-[11px]">
                <span class="inline-flex items-center gap-1 text-teal-700 dark:text-teal-400 font-medium">
                    <i class="fa-solid fa-warehouse text-[10px]"></i> جاهزة للصرف الفوري
                </span>
                <span class="font-num text-[10px] text-zinc-400">Available</span>
            </div>
        </div>
    </div>

    <!-- GIS Map & Control Hub Section (Quiet, Authoritative, Unified Accent) -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-5 shadow-xs">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4">
            <div class="space-y-1 max-w-2xl">
                <div class="text-xs font-semibold text-teal-700 dark:text-teal-400 uppercase tracking-wider font-num flex items-center gap-1.5">
                    <span class="w-1.5 h-1.5 rounded-full bg-teal-600 animate-pulse"></span>
                    GIS Operations Layer
                </div>
                <h2 class="text-base font-semibold text-zinc-900 dark:text-zinc-100">الخريطة الميدانية المباشرة (Live GIS Operations Map)</h2>
                <p class="text-xs text-zinc-500 dark:text-zinc-400 leading-relaxed">
                    مراقبة جغرافية حية لفرق المتطوعين، ومواقع طلبات الإغاثة، ومراكز الإمداد في المحافظات مع ربط الإحداثيات آلياً بعمليات التوزيع.
                </p>
            </div>
            <div class="flex items-center gap-2">
                <a href="{{ route('dashboard.gis') }}" class="text-xs font-semibold px-4 py-2 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 shadow-sm transition-colors flex items-center gap-1.5">
                    <i class="fa-solid fa-map-location-dot text-xs"></i>
                    <span>فتح الخريطة التفاعلية الكاملة</span>
                </a>
                <a href="{{ route('dashboard.cases') }}" class="text-xs font-medium px-3 py-2 rounded-md border border-zinc-200 dark:border-zinc-700 hover:border-teal-400 dark:hover:border-teal-600 hover:text-teal-700 dark:hover:text-teal-300 text-zinc-700 dark:text-zinc-300 transition-colors flex items-center gap-1.5">
                    <i class="fa-solid fa-list-check text-xs"></i>
                    <span>لوحة التدقيق الذكي (AI Triage)</span>
                </a>
            </div>
        </div>
    </div>

    <!-- Split Data Section: Recent Distributions + AI Cases -->
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
        
        <!-- Distributions Table (7 Cols) -->
        <div class="lg:col-span-7 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden shadow-xs">
            <div class="p-4 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
                <div>
                    <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل التوزيعات اللحظية المعتمدة (NFC Log)</h3>
                    <p class="text-[11px] text-zinc-400 mt-0.5">عمليات الصرف الميداني الموثقة لاتلامسياً لمنع الازدواجية</p>
                </div>
                <span class="text-[10px] font-num font-semibold text-emerald-700 dark:text-emerald-300 bg-emerald-50 dark:bg-emerald-950/50 border border-emerald-200 dark:border-emerald-800/60 px-2.5 py-0.5 rounded-full inline-flex items-center gap-1">
                    <i class="fa-solid fa-circle-check text-[9px]"></i> VERIFIED NFC
                </span>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-right text-xs">
                    <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px] bg-zinc-50/50 dark:bg-zinc-900/50">
                        <tr>
                            <th class="px-4 py-2.5 font-normal">المستفيد</th>
                            <th class="px-4 py-2.5 font-normal">المادة / الحملة</th>
                            <th class="px-4 py-2.5 font-normal">المتطوع</th>
                            <th class="px-4 py-2.5 font-normal">التحقق</th>
                            <th class="px-4 py-2.5 font-normal">التوقيت</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                        @forelse($recentDistributions as $dist)
                            <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
                                <td class="px-4 py-2.5 font-medium text-zinc-900 dark:text-zinc-100">
                                    {{ $dist->beneficiary?->full_name ?? 'أسرة معتمدة' }}
                                    <span class="block text-[10px] font-num text-zinc-400">{{ $dist->beneficiary?->national_id }}</span>
                                </td>
                                <td class="px-4 py-2.5 text-zinc-600 dark:text-zinc-400">
                                    {{ $dist->campaign?->title ?? 'طرد إغاثي' }}
                                </td>
                                <td class="px-4 py-2.5 text-zinc-500">
                                    {{ $dist->volunteer?->name ?? 'متطوع ميداني' }}
                                </td>
                                <td class="px-4 py-2.5">
                                    <span class="inline-flex items-center gap-1 font-num text-[11px] text-emerald-700 dark:text-emerald-400 font-medium">
                                        <i class="fa-solid fa-wifi rotate-90 text-[10px]"></i> NFC Tap
                                    </span>
                                </td>
                                <td class="px-4 py-2.5 font-num text-[11px] text-zinc-400">
                                    {{ $dist->distributed_at ? \Carbon\Carbon::parse($dist->distributed_at)->diffForHumans() : 'الآن' }}
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" class="px-4 py-6 text-center text-zinc-400 text-xs">
                                    لا توجد عمليات توزيع مسجلة مؤخراً
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <!-- AI Cases Queue (5 Cols) -->
        <div class="lg:col-span-5 bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden shadow-xs">
            <div class="p-4 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
                <div>
                    <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">حالات بانتظار التدقيق والاعتماد</h3>
                    <p class="text-[11px] text-zinc-400 mt-0.5">فرز ذكي لدرجة الاستعجال والوثائق الطبية</p>
                </div>
                <a href="{{ route('dashboard.cases') }}" class="text-xs font-medium text-teal-700 dark:text-teal-400 hover:underline flex items-center gap-1">
                    <span>الكل</span>
                    <i class="fa-solid fa-arrow-left text-[10px]"></i>
                </a>
            </div>

            <div class="divide-y divide-zinc-100 dark:divide-zinc-800 text-xs">
                @forelse($criticalCases as $case)
                    @php
                        $urg = $case->ai_urgency_index ?? 0;
                        if ($urg >= 80) {
                            $urgBadge = 'bg-rose-50 text-rose-700 border-rose-200 dark:bg-rose-950/50 dark:text-rose-300 dark:border-rose-900/60';
                        } elseif ($urg >= 50) {
                            $urgBadge = 'bg-amber-50 text-amber-700 border-amber-200 dark:bg-amber-950/50 dark:text-amber-300 dark:border-amber-900/60';
                        } else {
                            $urgBadge = 'bg-zinc-100 text-zinc-700 border-zinc-200 dark:bg-zinc-800 dark:text-zinc-300 dark:border-zinc-700';
                        }
                    @endphp
                    <div class="p-3.5 hover:bg-zinc-50 dark:hover:bg-zinc-800/50 flex items-center justify-between gap-3 transition-colors">
                        <div class="space-y-0.5 min-w-0">
                            <div class="font-medium text-zinc-900 dark:text-zinc-100 truncate">
                                {{ $case->title }}
                            </div>
                            <div class="text-[11px] text-zinc-400 flex items-center gap-2">
                                <span>{{ $case->governorate?->name ?? 'دمشق' }}</span>
                                <span>•</span>
                                <span>{{ $case->category?->name ?? 'رعاية صحية' }}</span>
                            </div>
                        </div>

                        <div class="flex items-center gap-3 shrink-0">
                            <span class="font-num text-xs font-bold px-2 py-0.5 rounded border {{ $urgBadge }}">
                                {{ $urg }} / 100
                            </span>
                            <a href="{{ route('dashboard.cases') }}" class="text-[11px] font-semibold text-teal-700 dark:text-teal-400 hover:underline">
                                مراجعة
                            </a>
                        </div>
                    </div>
                @empty
                    <div class="p-6 text-center text-zinc-400 text-xs">
                        لا توجد طلبات معلقة تتطلب تدقيقاً فورياً
                    </div>
                @endforelse
            </div>
        </div>
    </div>

</div>
@endsection
