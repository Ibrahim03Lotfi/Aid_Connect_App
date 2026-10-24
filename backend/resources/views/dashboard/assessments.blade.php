@extends('layouts.dashboard')

@section('title', 'المعاينات الميدانية وتقييم السكن')
@section('page_title', 'المعاينات الميدانية وتقييم السكن (Field Assessments)')

@section('content')
<div class="space-y-5" x-data="{
    detailsModalOpen: false,
    activeAssessment: null,
    showDetails(item) {
        this.activeAssessment = item;
        this.detailsModalOpen = true;
    }
}">

    <!-- Stat Overview -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">إجمالي المعاينات المنفذة</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ $totalAssessments }}</div>
            <div class="text-[11px] text-zinc-400">زيارات ميدانية موثقة</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">سكن في حالة حرجة وهشة</div>
            <div class="text-2xl font-semibold font-num text-rose-600 dark:text-rose-400">{{ $criticalCount }}</div>
            <div class="text-[11px] text-zinc-400">تتطلب تدخلاً هندسياً وإيوائياً عاجلاً</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">التوثيق بالذكاء الاصطناعي</div>
            <div class="text-xs font-semibold text-zinc-800 dark:text-zinc-200 pt-1 font-num">Multimodal Shelter Vision</div>
            <div class="text-[11px] text-zinc-400">فحص الصور الإنشائية وتحديد مؤشر الهشاشة</div>
        </div>
    </div>

    <!-- Assessments Table -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل استبيانات الوضع المعيشي والميداني</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">تقييم الباحث الميداني لحالة المنزل والتدفئة ومصادر الدخل</p>
            </div>
            <span class="text-[11px] text-zinc-400 font-num">Field Surveys</span>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">الحالة / الأسرة</th>
                        <th class="px-4 py-2.5 font-normal">المتطوع الميداني</th>
                        <th class="px-4 py-2.5 font-normal">درجة الخطورة</th>
                        <th class="px-4 py-2.5 font-normal">تقييم السكن (1-10)</th>
                        <th class="px-4 py-2.5 font-normal">نوع المأوى والتدفئة</th>
                        <th class="px-4 py-2.5 font-normal">الحالة</th>
                        <th class="px-4 py-2.5 text-center font-normal">الإجراء</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($assessments as $item)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $item->case?->title ?? 'طلب كشف ميداني' }}</div>
                                <div class="text-[10px] text-zinc-400 font-num">
                                    {{ $item->beneficiary?->full_name ?? 'الأسرة المستفيدة' }} • ملف: {{ $item->beneficiary?->file_number ?? 'ATHAR-FAM' }}
                                </div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap">
                                <span class="text-zinc-800 dark:text-zinc-200 font-medium">{{ $item->volunteer?->name ?? 'متطوع ميداني' }}</span>
                                <span class="text-[10px] text-zinc-400 block font-num">{{ $item->visited_at ? $item->visited_at->format('Y-m-d') : 'مؤخراً' }}</span>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($item->urgency_rating === 'critical')
                                    <span class="inline-flex items-center gap-1 text-rose-700 dark:text-rose-400 font-semibold bg-rose-50 dark:bg-rose-950/40 px-2 py-0.5 rounded border border-rose-200 dark:border-rose-800">
                                        <i class="fa-solid fa-triangle-exclamation text-[10px]"></i>
                                        <span>حرجة جداً (SOS)</span>
                                    </span>
                                @elseif($item->urgency_rating === 'high')
                                    <span class="inline-flex items-center gap-1 text-amber-700 dark:text-amber-400 font-medium bg-amber-50 dark:bg-amber-950/40 px-2 py-0.5 rounded border border-amber-200 dark:border-amber-800">
                                        <span>أولوية مرتفعة</span>
                                    </span>
                                @else
                                    <span class="text-zinc-500 font-medium">عادية</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num">
                                <div class="flex items-center gap-1.5">
                                    <span class="font-semibold text-xs {{ $item->living_condition_score <= 4 ? 'text-rose-600' : ($item->living_condition_score <= 7 ? 'text-amber-600' : 'text-emerald-600') }}">
                                        {{ $item->living_condition_score }} / 10
                                    </span>
                                </div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                <div class="text-zinc-800 dark:text-zinc-200">{{ $item->housing_type }}</div>
                                <div class="text-zinc-400 text-[10px]">
                                    {{ $item->heating_available ? 'تدفئة متوفرة' : 'لا تتوفر تدفئة' }}
                                </div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($item->status === 'approved')
                                    <span class="inline-flex items-center gap-1 text-emerald-700 dark:text-emerald-400 font-semibold bg-emerald-50 dark:bg-emerald-950/40 px-2 py-0.5 rounded border border-emerald-200 dark:border-emerald-800">
                                        <i class="fa-solid fa-circle-check text-[10px]"></i>
                                        <span>معتمدة</span>
                                    </span>
                                @elseif($item->status === 'rejected')
                                    <span class="inline-flex items-center gap-1 text-rose-700 dark:text-rose-400 font-semibold bg-rose-50 dark:bg-rose-950/40 px-2 py-0.5 rounded border border-rose-200 dark:border-rose-800">
                                        <i class="fa-solid fa-circle-xmark text-[10px]"></i>
                                        <span>مرفوضة</span>
                                    </span>
                                @else
                                    <span class="inline-flex items-center gap-1 text-amber-700 dark:text-amber-400 font-semibold bg-amber-50 dark:bg-amber-950/40 px-2 py-0.5 rounded border border-amber-200 dark:border-amber-800">
                                        <i class="fa-solid fa-clock text-[10px] animate-pulse"></i>
                                        <span>قيد التدقيق</span>
                                    </span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                <div class="flex items-center justify-center gap-2">
                                    <!-- View Details Button -->
                                    <button type="button" 
                                            @click="showDetails({{ json_encode([
                                                'id' => $item->id,
                                                'case_title' => $item->case?->title ?? 'طلب كشف ميداني',
                                                'beneficiary_name' => $item->beneficiary?->full_name ?? 'الأسرة المستفيدة',
                                                'national_id' => $item->beneficiary?->national_id ?? '-',
                                                'file_number' => $item->beneficiary?->file_number ?? 'ATHAR-FAM',
                                                'volunteer_name' => $item->volunteer?->name ?? 'متطوع ميداني',
                                                'volunteer_phone' => $item->volunteer?->phone ?? '-',
                                                'living_condition_score' => $item->living_condition_score,
                                                'housing_type' => $item->housing_type,
                                                'heating_available' => (bool) $item->heating_available,
                                                'monthly_income_estimate' => $item->monthly_income_estimate,
                                                'income_source' => $item->income_source ?? 'لا يوجد دخل ثابت',
                                                'urgency_rating' => $item->urgency_rating,
                                                'inspector_notes' => $item->inspector_notes,
                                                'ai_damage_assessment' => $item->ai_damage_assessment ?? 'تم فحص أضرار السكن وتصنيفها آلياً.',
                                                'status' => $item->status,
                                                'visited_at' => $item->visited_at ? $item->visited_at->format('Y-m-d H:i') : 'مؤخراً',
                                            ]) }})"
                                            class="text-xs text-zinc-900 dark:text-zinc-100 font-semibold hover:underline flex items-center gap-1">
                                        <i class="fa-solid fa-file-lines text-[10px]"></i>
                                        <span>الاستبيان</span>
                                    </button>

                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>

                                    @if($item->status === 'submitted' || empty($item->status))
                                        <form action="{{ route('dashboard.assessments.status', $item->id) }}" method="POST" class="inline">
                                            @csrf
                                            <input type="hidden" name="status" value="approved">
                                            <button type="submit" class="px-2 py-0.5 rounded bg-emerald-600 hover:bg-emerald-500 text-white text-[11px] font-semibold transition-colors shadow-xs">
                                                اعتماد
                                            </button>
                                        </form>
                                        <form action="{{ route('dashboard.assessments.status', $item->id) }}" method="POST" class="inline">
                                            @csrf
                                            <input type="hidden" name="status" value="rejected">
                                            <button type="submit" class="px-2 py-0.5 rounded border border-rose-300 dark:border-rose-700 text-rose-600 hover:bg-rose-50 text-[11px] font-medium transition-colors">
                                                رفض
                                            </button>
                                        </form>
                                    @elseif($item->status === 'approved')
                                        <form action="{{ route('dashboard.assessments.status', $item->id) }}" method="POST" class="inline">
                                            @csrf
                                            <input type="hidden" name="status" value="rejected">
                                            <button type="submit" class="text-[10px] text-zinc-400 hover:text-rose-600 hover:underline" title="إلغاء الاعتماد وتحويل إلى مرفوض">
                                                (تحويل لرفض)
                                            </button>
                                        </form>
                                        <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                        <form action="{{ route('dashboard.assessments.status', $item->id) }}" method="POST" class="inline">
                                            @csrf
                                            <input type="hidden" name="status" value="submitted">
                                            <button type="submit" class="text-[10px] text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 hover:underline" title="إعادة الكشف إلى قيد التدقيق">
                                                (إعادة التدقيق)
                                            </button>
                                        </form>
                                    @elseif($item->status === 'rejected')
                                        <form action="{{ route('dashboard.assessments.status', $item->id) }}" method="POST" class="inline">
                                            @csrf
                                            <input type="hidden" name="status" value="approved">
                                            <button type="submit" class="text-[10px] text-emerald-600 dark:text-emerald-400 hover:underline" title="إعادة الاعتماد والتوثيق">
                                                (إعادة الاعتماد)
                                            </button>
                                        </form>
                                    @endif
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="px-4 py-8 text-center text-zinc-400">
                                لا توجد استمارات معاينة ميدانية مسجلة حالياً
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="p-3 border-t border-zinc-100 dark:border-zinc-800 text-xs">
            {{ $assessments->links() }}
        </div>
    </div>

    <!-- Modal: Field Assessment Full Survey Details (تفاصيل الاستبيان الميداني) -->
    <div x-show="detailsModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/60 backdrop-blur-sm">
        <div @click.away="detailsModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-xl w-full p-6 space-y-4 max-h-[90vh] overflow-y-auto shadow-2xl">
            
            <!-- Modal Header -->
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-3">
                <div class="flex items-center gap-2">
                    <span class="w-2.5 h-2.5 rounded-full bg-emerald-600"></span>
                    <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-sm">استمارة الكشف الميداني وتقييم السكن والهشاشة</h4>
                </div>
                <button @click="detailsModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <!-- Survey Body Content -->
            <template x-if="activeAssessment">
                <div class="space-y-4 text-xs">
                    
                    <!-- Basic Meta Grid -->
                    <div class="grid grid-cols-2 gap-3 bg-zinc-50 dark:bg-zinc-800/50 p-3 rounded-lg border border-zinc-100 dark:border-zinc-800">
                        <div>
                            <span class="text-[10px] text-zinc-400 block">الأسرة المستفيدة</span>
                            <span class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs" x-text="activeAssessment.beneficiary_name"></span>
                            <span class="text-[10px] text-zinc-500 font-num block" x-text="'الرقم الوطني: ' + activeAssessment.national_id"></span>
                        </div>
                        <div>
                            <span class="text-[10px] text-zinc-400 block">الباحث الميداني والتاريخ</span>
                            <span class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs" x-text="activeAssessment.volunteer_name"></span>
                            <span class="text-[10px] text-zinc-500 font-num block" x-text="activeAssessment.visited_at"></span>
                        </div>
                    </div>

                    <!-- Living Condition & Urgency Metrics -->
                    <div class="grid grid-cols-3 gap-3">
                        <div class="p-3 bg-zinc-50 dark:bg-zinc-800/40 rounded border border-zinc-100 dark:border-zinc-800 text-center">
                            <span class="text-[10px] text-zinc-400 block mb-1">تقييم السكن العام</span>
                            <span class="font-num font-bold text-base text-zinc-900 dark:text-zinc-100" x-text="activeAssessment.living_condition_score + ' / 10'"></span>
                        </div>

                        <div class="p-3 bg-zinc-50 dark:bg-zinc-800/40 rounded border border-zinc-100 dark:border-zinc-800 text-center">
                            <span class="text-[10px] text-zinc-400 block mb-1">نوع المسكن</span>
                            <span class="font-medium text-zinc-900 dark:text-zinc-100" x-text="activeAssessment.housing_type"></span>
                        </div>

                        <div class="p-3 bg-zinc-50 dark:bg-zinc-800/40 rounded border border-zinc-100 dark:border-zinc-800 text-center">
                            <span class="text-[10px] text-zinc-400 block mb-1">توفر التدفئة</span>
                            <span class="font-medium" :class="activeAssessment.heating_available ? 'text-emerald-600' : 'text-rose-600'" x-text="activeAssessment.heating_available ? 'متوفرة' : 'معدومة / بحاجة وقود'"></span>
                        </div>
                    </div>

                    <!-- Economic & Vulnerability Factors -->
                    <div class="p-3 bg-zinc-50 dark:bg-zinc-800/40 rounded border border-zinc-100 dark:border-zinc-800 space-y-1.5">
                        <div class="flex items-center justify-between">
                            <span class="text-[11px] text-zinc-400">تقدير الدخل الشهري للأسرة:</span>
                            <span class="font-num font-semibold text-zinc-900 dark:text-zinc-100" x-text="activeAssessment.monthly_income_estimate ? (Number(activeAssessment.monthly_income_estimate).toLocaleString() + ' ل.س') : 'معدوم (دون دخل)'"></span>
                        </div>
                        <div class="flex items-center justify-between">
                            <span class="text-[11px] text-zinc-400">مصدر الدخل وطبيعة العمل:</span>
                            <span class="text-zinc-800 dark:text-zinc-200" x-text="activeAssessment.income_source"></span>
                        </div>
                        <div class="flex items-center justify-between pt-1 border-t border-zinc-100 dark:border-zinc-800/60">
                            <span class="text-[11px] text-zinc-400">مؤشر الاستعجال الإغاثي:</span>
                            <span class="font-semibold text-rose-600" x-text="activeAssessment.urgency_rating === 'critical' ? 'حرج وفوري (تدخل هندسي وغذائي)' : (activeAssessment.urgency_rating === 'high' ? 'أولوية مرتفعة' : 'اعتيادية')"></span>
                        </div>
                    </div>

                    <!-- Inspector Notes -->
                    <div class="space-y-1">
                        <label class="block text-zinc-500 font-medium text-[11px]">تقرير وملاحظات الكاشف الميداني:</label>
                        <div class="p-3 rounded bg-zinc-50 dark:bg-zinc-800/60 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 leading-relaxed" x-text="activeAssessment.inspector_notes"></div>
                    </div>

                    <!-- AI Damage Vision Assessment -->
                    <div class="space-y-1" x-show="activeAssessment.ai_damage_assessment">
                        <label class="block text-zinc-500 font-medium text-[11px] flex items-center gap-1">
                            <i class="fa-solid fa-microchip text-[10px] text-teal-600"></i>
                            <span>تشخيص نموذج الرؤية الحاسوبية (Multimodal Vision Damage):</span>
                        </label>
                        <div class="p-3 rounded bg-teal-50/50 dark:bg-teal-950/20 border border-teal-200 dark:border-teal-800 text-teal-900 dark:text-teal-200 text-[11px] leading-relaxed" x-text="activeAssessment.ai_damage_assessment"></div>
                    </div>

                    <!-- Modal Actions Footer -->
                    <div class="pt-3 border-t border-zinc-100 dark:border-zinc-800 flex items-center justify-between">
                        <div class="text-[11px] text-zinc-400">
                            الحالة الحالية: <span class="font-semibold" x-text="activeAssessment.status"></span>
                        </div>
                        <div class="flex items-center gap-2">
                            <button type="button" @click="detailsModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100">
                                إغلاق
                            </button>
                            <template x-if="activeAssessment.status !== 'approved'">
                                <form :action="'{{ url('dashboard/assessments') }}/' + activeAssessment.id + '/status'" method="POST" class="inline">
                                    @csrf
                                    <input type="hidden" name="status" value="approved">
                                    <button type="submit" class="px-4 py-1.5 rounded bg-emerald-600 hover:bg-emerald-500 text-white font-semibold transition-colors">
                                        اعتماد وتوثيق الاستمارة
                                    </button>
                                </form>
                            </template>
                        </div>
                    </div>

                </div>
            </template>
        </div>
    </div>

</div>
@endsection
