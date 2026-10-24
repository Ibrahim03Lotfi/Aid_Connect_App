@extends('layouts.dashboard')

@section('title', 'التحليلات الميدانية والإحصاءات التنفيذية')
@section('page_title', 'التحليلات الميدانية والإحصاءات (Executive Analytics)')

@section('content')
<div class="space-y-6">

    <!-- Header Actions -->
    <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 pb-2 border-b border-zinc-200 dark:border-zinc-800">
        <div>
            <h3 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100">لوحة القياس والتحليل التنفيذي</h3>
            <p class="text-xs text-zinc-500 dark:text-zinc-400">مؤشرات الأداء الميداني والتوزيع الإحصائي للعمليات</p>
        </div>
        <a href="{{ route('dashboard.reports.annual') }}" target="_blank" 
           class="text-xs font-semibold px-3 py-1.5 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 shadow-sm transition-colors flex items-center gap-1.5">
            <i class="fa-solid fa-file-invoice text-xs"></i>
            <span>عرض وطباعة التقرير السنوي الشامل</span>
        </a>
    </div>

    <!-- Charts Grid (2x2) -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        
        <!-- Chart 1: Distributions by Governorate -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-3">
            <div class="flex items-center justify-between pb-2 border-b border-zinc-100 dark:border-zinc-800 text-xs">
                <h4 class="font-medium text-zinc-900 dark:text-zinc-100">توزيع المعونات حسب المحافظة</h4>
                <span class="text-[11px] text-zinc-400 font-num">Governorates</span>
            </div>
            <div class="relative h-60">
                <canvas id="govChart"></canvas>
            </div>
        </div>

        <!-- Chart 2: Aid by Category -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-3">
            <div class="flex items-center justify-between pb-2 border-b border-zinc-100 dark:border-zinc-800 text-xs">
                <h4 class="font-medium text-zinc-900 dark:text-zinc-100">توزيع الحالات حسب القطاع الإغاثي</h4>
                <span class="text-[11px] text-zinc-400 font-num">Sectors</span>
            </div>
            <div class="relative h-60 flex items-center justify-center">
                <canvas id="catChart"></canvas>
            </div>
        </div>
    </div>

    <!-- Volunteer Leaderboard & Performance -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h4 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">لوحة شرف المتطوعين الميدانيين</h4>
                <p class="text-[11px] text-zinc-400 mt-0.5">مرتبون حسب الساعات الميدانية المعتمدة وخدمة الأسر</p>
            </div>
            <span class="text-[10px] font-num text-zinc-400">Field Service Ledger</span>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2 font-normal">الترتيب</th>
                        <th class="px-4 py-2 font-normal">اسم المتطوع</th>
                        <th class="px-4 py-2 font-normal">المحافظة</th>
                        <th class="px-4 py-2 font-normal">ساعات الخدمة</th>
                        <th class="px-4 py-2 font-normal">وسيلة التنقل</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($topVolunteers as $index => $vol)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-2.5 font-num text-zinc-400 text-xs">
                                {{ sprintf('%02d', $index + 1) }}
                            </td>
                            <td class="px-4 py-2.5 font-medium text-zinc-900 dark:text-zinc-100">
                                {{ $vol->name }}
                            </td>
                            <td class="px-4 py-2.5 text-zinc-500">
                                {{ $vol->governorate ?? 'دمشق' }}
                            </td>
                            <td class="px-4 py-2.5 font-num font-medium text-zinc-900 dark:text-zinc-100">
                                {{ $vol->volunteer_hours ?? 0 }} ساعة
                            </td>
                            <td class="px-4 py-2.5 text-zinc-500 text-[11px]">
                                {{ $vol->vehicle_type ?? 'سيارة ميدانية' }}
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="px-4 py-6 text-center text-zinc-400">
                                لا توجد بيانات متطوعين مسجلة
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

</div>
@endsection

@section('scripts')
<!-- Chart.js CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    const isDark = document.documentElement.classList.contains('dark');
    const textColor = isDark ? '#a1a1aa' : '#71717a';
    const gridColor = isDark ? 'rgba(255,255,255,0.05)' : 'rgba(0,0,0,0.05)';

    // 1. Governorate Distribution Bar Chart (Monochromatic Slate)
    const govData = @json($governorateStats);
    const govLabels = govData.map(d => d.gov_name);
    const govCounts = govData.map(d => d.total_distributions);

    new Chart(document.getElementById('govChart'), {
        type: 'bar',
        data: {
            labels: govLabels,
            datasets: [{
                data: govCounts,
                backgroundColor: isDark ? '#0d9488' : '#0f766e',
                hoverBackgroundColor: isDark ? '#14b8a6' : '#115e59',
                borderRadius: 4,
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false }
            },
            scales: {
                x: {
                    grid: { display: false },
                    ticks: { color: textColor, font: { family: 'IBM Plex Sans Arabic', size: 11 } }
                },
                y: {
                    grid: { color: gridColor },
                    ticks: { color: textColor, font: { family: 'JetBrains Mono', size: 10 } }
                }
            }
        }
    });

    // 2. Categories Doughnut Chart (Harmonious Executive Palette)
    const catData = @json($categoryStats);
    const catLabels = catData.map(c => c.cat_name);
    const catCounts = catData.map(c => c.case_count);

    new Chart(document.getElementById('catChart'), {
        type: 'doughnut',
        data: {
            labels: catLabels,
            datasets: [{
                data: catCounts,
                backgroundColor: [
                    '#0f766e', // Teal / Brand
                    '#0284c7', // Sky Blue
                    '#d97706', // Warm Amber
                    '#6366f1', // Indigo
                    '#64748b'  // Slate
                ],
                borderWidth: 1,
                borderColor: isDark ? '#18181b' : '#ffffff',
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: { color: textColor, font: { family: 'IBM Plex Sans Arabic', size: 11 }, padding: 12 }
                }
            }
        }
    });
</script>
@endsection
