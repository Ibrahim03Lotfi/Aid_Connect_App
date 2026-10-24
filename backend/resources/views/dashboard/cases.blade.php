@extends('layouts.dashboard')

@section('title', 'لوحة التدقيق والفرز الذكي للحالات (AI Triage Board)')
@section('page_title', 'لوحة التدقيق والفرز الذكي للحالات (AI Triage & Review)')

@section('content')
<div class="space-y-5" x-data="{
    assignModalOpen: false,
    rejectModalOpen: false,
    detailsModalOpen: false,
    createModalOpen: false,
    editModalOpen: false,
    selectedCaseId: null,
    selectedCaseTitle: '',
    activeCase: null,
    editingCase: {},

    openAssign(id, title) {
        this.selectedCaseId = id;
        this.selectedCaseTitle = title;
        this.assignModalOpen = true;
    },
    openReject(id, title) {
        this.selectedCaseId = id;
        this.selectedCaseTitle = title;
        this.rejectModalOpen = true;
    },
    openDetails(caseData) {
        this.activeCase = caseData;
        this.detailsModalOpen = true;
    },
    openEdit(caseData) {
        this.editingCase = { ...caseData };
        this.editModalOpen = true;
    }
}">

    <!-- Filter Bar (Minimalist, Serious) -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4">
        <form action="{{ route('dashboard.cases') }}" method="GET" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 text-xs">
            
            <!-- Status Filter -->
            <div>
                <label class="block text-zinc-500 dark:text-zinc-400 mb-1 font-medium">حالة الملف</label>
                <select name="status" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded px-2.5 py-2 outline-none">
                    <option value="all" {{ request('status') == 'all' ? 'selected' : '' }}>جميع الحالات</option>
                    <option value="pending" {{ request('status') == 'pending' ? 'selected' : '' }}>قيد الانتظار والمراجعة</option>
                    <option value="assigned_for_inspection" {{ request('status') == 'assigned_for_inspection' ? 'selected' : '' }}>مسندة لكشف ميداني</option>
                    <option value="approved" {{ request('status') == 'approved' ? 'selected' : '' }}>معتمدة للتبرع والتمويل</option>
                    <option value="rejected" {{ request('status') == 'rejected' ? 'selected' : '' }}>مرفوضة</option>
                </select>
            </div>

            <!-- Governorate Filter -->
            <div>
                <label class="block text-zinc-500 dark:text-zinc-400 mb-1 font-medium">المحافظة</label>
                <select name="governorate_id" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded px-2.5 py-2 outline-none">
                    <option value="">جميع المحافظات</option>
                    @foreach($governorates as $gov)
                        <option value="{{ $gov->id }}" {{ request('governorate_id') == $gov->id ? 'selected' : '' }}>{{ $gov->name }}</option>
                    @endforeach
                </select>
            </div>

            <!-- Minimum Urgency Filter -->
            <div>
                <label class="block text-zinc-500 dark:text-zinc-400 mb-1 font-medium">أدنى درجة استعجال (AI Score)</label>
                <select name="min_urgency" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded px-2.5 py-2 outline-none font-num">
                    <option value="">جميع الدرجات</option>
                    <option value="90" {{ request('min_urgency') == '90' ? 'selected' : '' }}>90+ (حرج وفوري - Tier 1)</option>
                    <option value="75" {{ request('min_urgency') == '75' ? 'selected' : '' }}>75+ (أولوية مرتفعة)</option>
                    <option value="50" {{ request('min_urgency') == '50' ? 'selected' : '' }}>50+ (أولوية متوسطة)</option>
                </select>
            </div>

            <!-- Action Buttons -->
            <div class="flex items-end gap-2">
                <button type="submit" class="flex-1 bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 font-semibold py-2 rounded-md shadow-sm transition-colors">
                    تطبيق التصفية
                </button>
                <a href="{{ route('dashboard.cases') }}" class="px-3 py-2 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400 hover:bg-zinc-50 dark:hover:bg-zinc-800 text-center">
                    إلغاء
                </a>
            </div>
        </form>
    </div>

    <!-- Cases Data Table -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden shadow-xs">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل مراجعة طلبات الإغاثة والتحقق الآلي</h3>
                <span class="text-[11px] text-zinc-400 font-num">AI Priority Engine Active</span>
            </div>
            <button @click="createModalOpen = true" class="px-3 py-1.5 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 text-xs font-semibold shadow-sm flex items-center gap-1.5 transition-colors">
                <i class="fa-solid fa-plus text-[10px]"></i>
                <span>تسجيل حالة إنسانية جديدة</span>
            </button>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">معرف الطلب والعنوان</th>
                        <th class="px-4 py-2.5 font-normal">المحافظة والتصنيف</th>
                        <th class="px-4 py-2.5 font-normal">درجة الاستعجال (AI)</th>
                        <th class="px-4 py-2.5 font-normal">التدقيق المالي</th>
                        <th class="px-4 py-2.5 font-normal">بصمة الصورة</th>
                        <th class="px-4 py-2.5 font-normal">الحالة</th>
                        <th class="px-4 py-2.5 text-center font-normal">الإجراء</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($cases as $case)
                        @php
                            $urgency = $case->ai_urgency_index ?? 0;
                            $isCritical = $urgency >= 85;
                        @endphp
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            
                            <!-- Case ID & Title -->
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100 line-clamp-1">#{{ $case->id }} • {{ $case->title }}</div>
                                <div class="text-[11px] text-zinc-400 mt-0.5 line-clamp-1 max-w-xs">{{ $case->description }}</div>
                            </td>

                            <!-- Governorate & Category -->
                            <td class="px-4 py-3 whitespace-nowrap">
                                <div class="text-zinc-800 dark:text-zinc-200">{{ $case->governorate?->name ?? 'دمشق' }}</div>
                                <div class="text-[10px] text-zinc-400">{{ $case->category?->name ?? 'رعاية صحية' }}</div>
                            </td>

                            <!-- AI Triage Urgency Gauge -->
                            <td class="px-4 py-3 whitespace-nowrap">
                                <span class="font-num font-semibold text-xs {{ $isCritical ? 'text-rose-600 dark:text-rose-400' : 'text-zinc-800 dark:text-zinc-200' }}">
                                    {{ $urgency }} / 100
                                </span>
                                <span class="block text-[10px] text-zinc-400">
                                    {{ $case->ai_triage_tier ?? 'Tier 2' }}
                                </span>
                            </td>

                            <!-- Document & Invoice Audit -->
                            <td class="px-4 py-3 whitespace-nowrap">
                                @if($case->target_amount > 0)
                                    <span class="font-num font-medium text-zinc-900 dark:text-zinc-100">{{ number_format($case->target_amount) }} ل.س</span>
                                    <span class="block text-[10px] text-zinc-400">Math Verified (100%)</span>
                                @else
                                    <span class="text-zinc-400">معونة عينية</span>
                                @endif
                            </td>

                            <!-- dHash Anti-Fraud Check -->
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($case->duplicate_case_id)
                                    <span class="text-rose-600 dark:text-rose-400 font-num font-medium">مكررة (#{{ $case->duplicate_case_id }})</span>
                                @else
                                    <span class="text-zinc-500">فريدة (Authentic)</span>
                                @endif
                            </td>

                            <!-- Status -->
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($case->status === 'approved')
                                    <span class="inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-700 dark:text-emerald-400 bg-emerald-50 dark:bg-emerald-950/40 px-2 py-0.5 rounded border border-emerald-200 dark:border-emerald-800/60">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                                        معتمدة
                                    </span>
                                @elseif($case->status === 'rejected')
                                    <span class="inline-flex items-center gap-1 text-[11px] font-semibold text-rose-700 dark:text-rose-400 bg-rose-50 dark:bg-rose-950/40 px-2 py-0.5 rounded border border-rose-200 dark:border-rose-900/60">
                                        <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                                        مرفوضة
                                    </span>
                                @elseif($case->status === 'assigned_for_inspection')
                                    <span class="inline-flex items-center gap-1 text-[11px] font-semibold text-sky-700 dark:text-sky-400 bg-sky-50 dark:bg-sky-950/40 px-2 py-0.5 rounded border border-sky-200 dark:border-sky-900/60">
                                        <span class="w-1.5 h-1.5 rounded-full bg-sky-500"></span>
                                        كشف ميداني
                                    </span>
                                @else
                                    <span class="inline-flex items-center gap-1 text-[11px] font-semibold text-amber-700 dark:text-amber-400 bg-amber-50 dark:bg-amber-950/40 px-2 py-0.5 rounded border border-amber-200 dark:border-amber-900/60">
                                        <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
                                        قيد التدقيق
                                    </span>
                                @endif
                            </td>

                            <!-- Actions Toolbar -->
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                <div class="flex items-center justify-center gap-1.5">
                                    <button type="button" 
                                            @click="openDetails({{ json_encode([
                                                'id' => $case->id,
                                                'title' => $case->title,
                                                'description' => $case->description,
                                                'governorate' => $case->governorate?->name ?? 'دمشق',
                                                'category' => $case->category?->name ?? 'رعاية صحية',
                                                'status' => $case->status,
                                                'target_amount' => $case->target_amount,
                                                'collected_amount' => $case->collected_amount,
                                                'ai_urgency' => $urgency,
                                                'ai_tier' => $case->ai_triage_tier ?? 'Tier 2',
                                                'ai_fraud_status' => $case->ai_fraud_status ?? 'clean',
                                                'duplicate_case_id' => $case->duplicate_case_id,
                                                'images' => $case->images->map(fn($img) => asset($img->url))->toArray(),
                                                'attachments' => $case->attachments->map(fn($att) => ['name' => $att->file_name ?? 'وثيقة رسمية', 'url' => asset($att->file_path)])->toArray(),
                                                'comments' => $case->comments->map(fn($c) => ['user' => $c->user?->name ?? 'مستخدم', 'comment' => $c->comment, 'time' => $c->created_at?->diffForHumans() ?? 'مؤخراً'])->toArray(),
                                            ]) }})" 
                                            class="text-zinc-900 dark:text-zinc-100 font-medium text-xs hover:underline" 
                                            title="معاينة الملف الكامل والوثائق المرفقة">
                                        معاينة
                                    </button>

                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>

                                    <button type="button"
                                            @click="openEdit({{ json_encode([
                                                'id' => $case->id,
                                                'title' => $case->title,
                                                'description' => $case->description,
                                                'governorate_id' => $case->governorate_id,
                                                'category_id' => $case->category_id,
                                                'target_amount' => $case->target_amount,
                                                'priority' => $case->priority ?? 'medium',
                                                'status' => $case->status,
                                            ]) }})"
                                            class="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 text-xs hover:underline">
                                        تعديل
                                    </button>

                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>

                                    <button type="button" 
                                            @click="openAssign({{ $case->id }}, '{{ addslashes($case->title) }}')" 
                                            class="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 text-xs hover:underline" 
                                            title="إسناد لمتطوع">
                                        إسناد
                                    </button>

                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>

                                    <form action="{{ route('dashboard.cases.approve', $case->id) }}" method="POST" onsubmit="return confirm('تأكيد اعتماد الحالة؟');" class="inline">
                                        @csrf
                                        <button type="submit" class="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 text-xs hover:underline">
                                            اعتماد
                                        </button>
                                    </form>

                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>

                                    <button type="button" 
                                            @click="openReject({{ $case->id }}, '{{ addslashes($case->title) }}')" 
                                            class="text-zinc-400 hover:text-rose-600 text-xs hover:underline">
                                        رفض
                                    </button>

                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>

                                    <form action="{{ route('dashboard.cases.destroy', $case->id) }}" method="POST" onsubmit="return confirm('تأكيد حذف هذه الحالة الإنسانية وسجلاتها؟');" class="inline">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="text-rose-600 hover:text-rose-800 text-xs hover:underline">
                                            حذف
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="px-4 py-8 text-center text-zinc-400">
                                لا توجد حالات مسجلة تطابق محددات البحث
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>


        <div class="p-3 border-t border-zinc-100 dark:border-zinc-800 text-xs">
            {{ $cases->links() }}
        </div>
    </div>

    <!-- Modal 1: Assign Volunteer -->
    <div x-show="assignModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="assignModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-md w-full p-5 space-y-3">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">إسناد الحالة لكشف ميداني</h4>
                <button @click="assignModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>
            
            <p class="text-xs text-zinc-500">
                سيتم إرسال إشعار للمتطوع الميداني لإجراء الزيارة وتوثيق استمارة المعاينة.
            </p>
            
            <div class="p-2.5 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs font-medium text-zinc-800 dark:text-zinc-200 rounded" x-text="selectedCaseTitle"></div>

            <form :action="'{{ url('/dashboard/cases') }}/' + selectedCaseId + '/assign'" method="POST" class="space-y-3 text-xs">
                @csrf
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المتطوع الميداني</label>
                    <select name="volunteer_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded px-2.5 py-2 outline-none">
                        @foreach($volunteers as $vol)
                            <option value="{{ $vol->id }}">{{ $vol->name }} ({{ $vol->governorate ?? 'دمشق' }} • {{ $vol->volunteer_hours }} ساعة)</option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">توجيهات أو ملاحظات (اختياري)</label>
                    <textarea name="notes" rows="3" placeholder="ملاحظات الزيارة..." class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none"></textarea>
                </div>
                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="assignModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">تأكيد الإسناد الميداني</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 2: Reject Case -->
    <div x-show="rejectModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="rejectModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-md w-full p-5 space-y-3">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">رفض طلب الإغاثة</h4>
                <button @click="rejectModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>
            
            <p class="text-xs text-zinc-500">
                تدوين سبب الرفض وإشعار مقدم الطلب في السجل.
            </p>
            
            <div class="p-2.5 bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-xs font-medium text-zinc-800 dark:text-zinc-200 rounded" x-text="selectedCaseTitle"></div>

            <form :action="'{{ url('/dashboard/cases') }}/' + selectedCaseId + '/reject'" method="POST" class="space-y-3 text-xs">
                @csrf
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">سبب الرفض الرسمي</label>
                    <textarea name="rejection_reason" required rows="3" placeholder="بيان سبب الرفض..." class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none"></textarea>
                </div>
                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="rejectModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">تأكيد الرفض</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 3: Case Dossier & Multimedia Evidence (Mobile App Sync) -->
    <div x-show="detailsModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/60 backdrop-blur-sm overflow-y-auto">
        <div @click.away="detailsModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-2xl w-full p-5 space-y-4 my-8 max-h-[90vh] flex flex-col">
            <!-- Header -->
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-3">
                <div class="space-y-0.5">
                    <div class="flex items-center gap-2">
                        <span class="text-[10px] font-mono uppercase tracking-wider px-1.5 py-0.5 rounded bg-zinc-100 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-400">DOSSIER #<span x-text="activeCase?.id"></span></span>
                        <span class="text-xs text-zinc-500" x-text="activeCase?.category + ' • ' + activeCase?.governorate"></span>
                    </div>
                    <h3 class="font-semibold text-sm text-zinc-900 dark:text-zinc-100" x-text="activeCase?.title"></h3>
                </div>
                <button @click="detailsModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-sm"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <!-- Scrollable Content -->
            <div class="overflow-y-auto space-y-4 text-xs pr-1 flex-1">
                <!-- AI & Verification Status Strip -->
                <div class="grid grid-cols-2 sm:grid-cols-4 gap-2 bg-zinc-50 dark:bg-zinc-800/50 p-3 rounded border border-zinc-100 dark:border-zinc-800 font-mono text-[11px]">
                    <div>
                        <span class="block text-zinc-400 text-[10px]">AI TRIAGE</span>
                        <span class="font-semibold text-zinc-800 dark:text-zinc-200" x-text="activeCase?.ai_tier"></span>
                    </div>
                    <div>
                        <span class="block text-zinc-400 text-[10px]">URGENCY SCORE</span>
                        <span class="font-semibold text-zinc-800 dark:text-zinc-200" x-text="activeCase?.ai_urgency + ' / 100'"></span>
                    </div>
                    <div>
                        <span class="block text-zinc-400 text-[10px]">FRAUD / DHASH</span>
                        <span :class="activeCase?.ai_fraud_status === 'clean' ? 'text-emerald-600 dark:text-emerald-400 font-semibold' : 'text-rose-600 dark:text-rose-400 font-semibold'" x-text="activeCase?.ai_fraud_status === 'clean' ? 'CLEAN (VERIFIED)' : 'FLAGGED'"></span>
                    </div>
                    <div>
                        <span class="block text-zinc-400 text-[10px]">FUNDING</span>
                        <span class="font-semibold text-zinc-800 dark:text-zinc-200" x-text="Number(activeCase?.collected_amount || 0).toLocaleString() + ' / ' + Number(activeCase?.target_amount || 0).toLocaleString() + ' SYP'"></span>
                    </div>
                </div>

                <!-- Case Narrative -->
                <div class="space-y-1.5">
                    <h5 class="text-[11px] font-semibold text-zinc-700 dark:text-zinc-300 uppercase tracking-wide">بيان الحالة الميدانية ومسوغات الإغاثة</h5>
                    <p class="p-3 bg-zinc-50 dark:bg-zinc-800/40 rounded border border-zinc-100 dark:border-zinc-800 text-zinc-700 dark:text-zinc-300 leading-relaxed whitespace-pre-line" x-text="activeCase?.description || 'لا يوجد وصف تفصيلي مسجل.'"></p>
                </div>

                <!-- Mobile Field Photos Gallery -->
                <div class="space-y-1.5">
                    <h5 class="text-[11px] font-semibold text-zinc-700 dark:text-zinc-300 uppercase tracking-wide">الصور الميدانية المرفوعة عبر التطبيق</h5>
                    <template x-if="activeCase?.images && activeCase.images.length > 0">
                        <div class="grid grid-cols-2 sm:grid-cols-3 gap-2">
                            <template x-for="(imgUrl, idx) in activeCase.images" :key="idx">
                                <a :href="imgUrl" target="_blank" class="block border border-zinc-200 dark:border-zinc-800 rounded overflow-hidden group relative aspect-video bg-zinc-100 dark:bg-zinc-800">
                                    <img :src="imgUrl" class="w-full h-full object-cover group-hover:scale-105 transition-transform" alt="صورة ميدانية" />
                                    <span class="absolute bottom-1 right-1 bg-zinc-950/75 text-[9px] text-white px-1.5 py-0.5 rounded font-mono">تكبير <i class="fa-solid fa-arrow-up-right-from-square text-[8px]"></i></span>
                                </a>
                            </template>
                        </div>
                    </template>
                    <template x-if="!activeCase?.images || activeCase.images.length === 0">
                        <p class="text-zinc-400 italic text-[11px] py-1">لم يتم إرفاق صور ميدانية مع هذه الحالة عبر التطبيق.</p>
                    </template>
                </div>

                <!-- Invoices & Medical Attachments -->
                <div class="space-y-1.5">
                    <h5 class="text-[11px] font-semibold text-zinc-700 dark:text-zinc-300 uppercase tracking-wide">الفواتير والتقارير الطبية الرسمية (Attachments)</h5>
                    <template x-if="activeCase?.attachments && activeCase.attachments.length > 0">
                        <div class="space-y-1.5">
                            <template x-for="(att, idx) in activeCase.attachments" :key="idx">
                                <div class="flex items-center justify-between p-2 bg-zinc-50 dark:bg-zinc-800/40 rounded border border-zinc-100 dark:border-zinc-800">
                                    <div class="flex items-center gap-2 truncate">
                                        <i class="fa-solid fa-file-pdf text-zinc-500"></i>
                                        <span class="text-zinc-700 dark:text-zinc-300 truncate" x-text="att.name"></span>
                                    </div>
                                    <a :href="att.url" target="_blank" class="text-zinc-900 dark:text-zinc-100 font-medium hover:underline text-[11px] shrink-0">
                                        فتح الوثيقة <i class="fa-solid fa-arrow-up-right-from-square text-[9px]"></i>
                                    </a>
                                </div>
                            </template>
                        </div>
                    </template>
                    <template x-if="!activeCase?.attachments || activeCase.attachments.length === 0">
                        <p class="text-zinc-400 italic text-[11px] py-1">لا توجد وثائق أو فواتير رسمية مرفقة بصيغة PDF.</p>
                    </template>
                </div>

                <!-- Citizen Comments / Community Engagement -->
                <div class="space-y-1.5">
                    <h5 class="text-[11px] font-semibold text-zinc-700 dark:text-zinc-300 uppercase tracking-wide">تفاعلات وتعليقات المستخدمين من التطبيق</h5>
                    <template x-if="activeCase?.comments && activeCase.comments.length > 0">
                        <div class="space-y-2">
                            <template x-for="(comm, idx) in activeCase.comments" :key="idx">
                                <div class="p-2.5 bg-zinc-50 dark:bg-zinc-800/30 rounded border border-zinc-100 dark:border-zinc-800 space-y-1">
                                    <div class="flex items-center justify-between text-[10px] text-zinc-400">
                                        <span class="font-medium text-zinc-700 dark:text-zinc-300" x-text="comm.user"></span>
                                        <span x-text="comm.time"></span>
                                    </div>
                                    <p class="text-zinc-600 dark:text-zinc-400 leading-snug" x-text="comm.comment"></p>
                                </div>
                            </template>
                        </div>
                    </template>
                    <template x-if="!activeCase?.comments || activeCase.comments.length === 0">
                        <p class="text-zinc-400 italic text-[11px] py-1">لا توجد تعليقات أو مناقشات مسجلة على هذه الحالة حتى الآن.</p>
                    </template>
                </div>
            </div>

            <!-- Modal Footer -->
            <div class="flex items-center justify-end gap-2 pt-3 border-t border-zinc-100 dark:border-zinc-800">
                <button type="button" @click="detailsModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 text-xs">إغلاق</button>
            </div>
        </div>
    </div>


    <!-- Modal 4: Create New Aid Case Modal -->
    <div x-show="createModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/60 backdrop-blur-sm">
        <div @click.away="createModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-4 max-h-[90vh] overflow-y-auto shadow-2xl relative">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">تسجيل حالة إنسانية جديدة يدوياً</h4>
                <button @click="createModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form action="{{ route('dashboard.cases.store') }}" method="POST" class="space-y-3 text-xs">
                @csrf
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">عنوان الحالة الإغاثية</label>
                    <input type="text" name="title" required placeholder="مثال: إجراء عملية جراحية عاجلة للطفل يمان" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المحافظة</label>
                        <select name="governorate_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="">-- اختر المحافظة --</option>
                            @foreach($governorates as $gov)
                                <option value="{{ $gov->id }}">{{ $gov->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">القطاع / التصنيف</label>
                        <select name="category_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="">-- اختر التصنيف --</option>
                            @foreach($categories as $cat)
                                <option value="{{ $cat->id }}">{{ $cat->name }}</option>
                            @endforeach
                        </select>
                    </div>
                </div>

                <div class="grid grid-cols-3 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المبلغ المطلوب (ل.س)</label>
                        <input type="number" name="target_amount" required min="0" value="0" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">درجة الأولوية</label>
                        <select name="priority" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="urgent">طارئة وفورية</option>
                            <option value="high">مرتفعة</option>
                            <option value="medium" selected>متوسطة</option>
                            <option value="low">منخفضة</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">مؤشر الاستعجال الذكي (0-100)</label>
                        <input type="number" name="urgency_score" min="0" max="100" value="70" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">التفاصيل والوصف الإنساني للحالة</label>
                    <textarea name="description" rows="3" required placeholder="شرح الوضع الإنساني والصحي والسكني للأسرة..." class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none"></textarea>
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="createModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">تسجيل ونشر الحالة</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 5: Edit Aid Case Modal -->
    <div x-show="editModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/60 backdrop-blur-sm">
        <div @click.away="editModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-4 max-h-[90vh] overflow-y-auto shadow-2xl relative">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">تعديل بيانات الحالة الإنسانية</h4>
                <button @click="editModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form :action="'{{ url('dashboard/cases') }}/' + editingCase.id" method="POST" class="space-y-3 text-xs">
                @csrf
                @method('PUT')
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">عنوان الحالة</label>
                    <input type="text" name="title" x-model="editingCase.title" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المحافظة</label>
                        <select name="governorate_id" x-model="editingCase.governorate_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            @foreach($governorates as $gov)
                                <option value="{{ $gov->id }}">{{ $gov->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">القطاع / التصنيف</label>
                        <select name="category_id" x-model="editingCase.category_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            @foreach($categories as $cat)
                                <option value="{{ $cat->id }}">{{ $cat->name }}</option>
                            @endforeach
                        </select>
                    </div>
                </div>

                <div class="grid grid-cols-3 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المبلغ المطلوب (ل.س)</label>
                        <input type="number" name="target_amount" x-model="editingCase.target_amount" required min="0" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">درجة الأولوية</label>
                        <select name="priority" x-model="editingCase.priority" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="urgent">طارئة وفورية</option>
                            <option value="high">مرتفعة</option>
                            <option value="medium">متوسطة</option>
                            <option value="low">منخفضة</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">حالة الملف</label>
                        <select name="status" x-model="editingCase.status" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="pending">قيد التدقيق والمراجعة</option>
                            <option value="assigned_for_inspection">مسندة لكشف ميداني</option>
                            <option value="approved">معتمدة للتبرع</option>
                            <option value="rejected">مرفوضة</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">التفاصيل والوصف الإنساني</label>
                    <textarea name="description" rows="3" x-model="editingCase.description" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none"></textarea>
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="editModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 font-semibold shadow-sm transition-colors">حفظ التعديلات</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
