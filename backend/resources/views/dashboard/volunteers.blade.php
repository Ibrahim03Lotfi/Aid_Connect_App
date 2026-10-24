@extends('layouts.dashboard')

@section('title', 'سجل المتطوعين وجواز السفر الرقمي')
@section('page_title', 'سجل المتطوعين الميدانيين (Volunteer Hub)')

@section('content')
<div class="space-y-6" x-data="{
    logModalOpen: false,
    badgeModalOpen: false,
    opportunityModalOpen: false,
    editOpportunityModalOpen: false,
    editingOpportunity: {},
    openEditOpportunity(op) { this.editingOpportunity = { ...op }; this.editOpportunityModalOpen = true; },
    selectedVolunteerId: null,
    selectedVolunteerName: '',

    openLog(id, name) {
        this.selectedVolunteerId = id;
        this.selectedVolunteerName = name;
        this.logModalOpen = true;
    },
    openBadge(id, name) {
        this.selectedVolunteerId = id;
        this.selectedVolunteerName = name;
        this.badgeModalOpen = true;
    }
}">

    <!-- Stat Overview -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">إجمالي المتطوعين المعتمدين</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ number_format($totalVolunteers) }}</div>
            <div class="text-[11px] text-zinc-400">فرق الكشف والتوزيع الميداني</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">مجموع الساعات الميدانية المعتمدة</div>
            <div class="text-2xl font-semibold font-num text-emerald-700 dark:text-emerald-400">{{ number_format($totalHours) }}</div>
            <div class="text-[11px] text-zinc-400">موثقة في جواز السفر الرقمي</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">جواز السفر التطوعي (Passport)</div>
            <div class="text-xs font-semibold text-zinc-800 dark:text-zinc-200 pt-1 font-num">QR Certified Resume</div>
            <div class="text-[11px] text-zinc-400">شهادات خبرة رقمية قابلة للتحقق العام</div>
        </div>
    </div>

    <!-- Volunteers Table -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل المتطوعين وإدارة الساعات المعتمدة</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">اعتماد الساعات الميدانية ومنح الأوسمة الرسمية</p>
            </div>
            
            <!-- Governorate Filter -->
            <form action="{{ route('dashboard.volunteers') }}" method="GET" class="flex items-center gap-2">
                <select name="governorate" onchange="this.form.submit()" class="bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 text-xs rounded px-2.5 py-1.5 outline-none">
                    <option value="">جميع المحافظات</option>
                    @foreach($governorates as $gov)
                        <option value="{{ $gov->name }}" {{ request('governorate') == $gov->name ? 'selected' : '' }}>{{ $gov->name }}</option>
                    @endforeach
                </select>
            </form>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">اسم المتطوع</th>
                        <th class="px-4 py-2.5 font-normal">الهاتف والبريد</th>
                        <th class="px-4 py-2.5 font-normal">المحافظة</th>
                        <th class="px-4 py-2.5 font-normal">وسيلة التنقل</th>
                        <th class="px-4 py-2.5 font-normal">الساعات المعتمدة</th>
                        <th class="px-4 py-2.5 font-normal">النقاط</th>
                        <th class="px-4 py-2.5 text-center font-normal">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($volunteers as $vol)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $vol->name }}</div>
                                <div class="text-[10px] text-zinc-400 font-num">ID: #VOL-{{ $vol->id }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px]">
                                <div class="text-zinc-800 dark:text-zinc-200">{{ $vol->phone }}</div>
                                <div class="text-zinc-400">{{ $vol->email }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap">
                                <span class="text-zinc-700 dark:text-zinc-300">{{ $vol->governorate ?? 'دمشق' }}</span>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px] text-zinc-500">
                                {{ $vol->vehicle_type ?? 'سيارة ميدانية' }}
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num">
                                <span class="font-medium text-zinc-900 dark:text-zinc-100">{{ $vol->volunteer_hours ?? 0 }}</span>
                                <span class="text-zinc-400">ساعة</span>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-zinc-500">
                                {{ $vol->volunteer_points ?? 0 }} نقطة
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                <div class="flex items-center justify-center gap-2">
                                    <button type="button" @click="openLog({{ $vol->id }}, '{{ addslashes($vol->name) }}')" class="text-xs text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 hover:underline">
                                        اعتماد ساعات +
                                    </button>
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    <button type="button" @click="openBadge({{ $vol->id }}, '{{ addslashes($vol->name) }}')" class="text-xs text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 hover:underline">
                                        منح وسام
                                    </button>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="px-4 py-8 text-center text-zinc-400">
                                لا يوجد متطوعون مسجلون يطابقون الفرز
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="p-3 border-t border-zinc-100 dark:border-zinc-800 text-xs">
            {{ $volunteers->links() }}
        </div>
    </div>

    <!-- Volunteer Opportunities Management -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">الفرص التطوعية واستقطاب الكوادر الميدانية</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">فتح باب التطوع لحملات الإغاثة وفرق الاستجابة عبر التطبيق المحمول</p>
            </div>
            <button @click="opportunityModalOpen = true" class="px-3 py-1.5 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 text-xs font-semibold shadow-sm flex items-center gap-1.5 transition-colors">
                <i class="fa-solid fa-plus text-[10px]"></i>
                <span>طرح فرصة تطوعية جديدة</span>
            </button>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">عنوان الفرصة</th>
                        <th class="px-4 py-2.5 font-normal">الجهة المنظمة</th>
                        <th class="px-4 py-2.5 font-normal">التصنيف والمحافظة</th>
                        <th class="px-4 py-2.5 font-normal">الكوادر المطلوبة / المتقدمين</th>
                        <th class="px-4 py-2.5 font-normal">الأولوية</th>
                        <th class="px-4 py-2.5 font-normal">الحالة</th>
                        <th class="px-4 py-2.5 text-center font-normal">الإجراء</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($opportunities as $op)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $op->title }}</div>
                                <div class="text-[11px] text-zinc-400 line-clamp-1 max-w-sm">{{ $op->description }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-zinc-600 dark:text-zinc-400">
                                {{ $op->organization?->name ?? 'منصة أثر المركزية' }}
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px]">
                                <div class="text-zinc-900 dark:text-zinc-100">{{ $op->governorate }}</div>
                                <div class="text-zinc-400">{{ $op->category }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num">
                                <span class="font-medium text-zinc-900 dark:text-zinc-100">{{ $op->volunteers_applied }}</span>
                                <span class="text-zinc-400">/ {{ $op->volunteers_needed }} متطوع</span>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($op->is_urgent || $op->priority === 'urgent')
                                    <span class="text-rose-600 dark:text-rose-400 font-medium">عاجل وفوري</span>
                                @else
                                    <span class="text-zinc-500">{{ $op->priority }}</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px]">
                                @if($op->status === 'active')
                                    <span class="text-emerald-700 dark:text-emerald-400 font-medium">متاحة للتقديم</span>
                                @else
                                    <span class="text-zinc-400">مكتملة / مغلقة</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                <div class="flex items-center justify-center gap-2">
                                    <button type="button" @click="openEditOpportunity({{ json_encode([
                                        'id' => $op->id,
                                        'title' => $op->title,
                                        'description' => $op->description,
                                        'governorate' => $op->governorate,
                                        'category' => $op->category,
                                        'volunteers_needed' => $op->volunteers_needed,
                                        'priority' => $op->priority,
                                        'status' => $op->status,
                                    ]) }})" class="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 text-xs hover:underline">
                                        تعديل
                                    </button>
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    <form action="{{ route('dashboard.volunteers.opportunities.toggle', $op->id) }}" method="POST" class="inline">
                                        @csrf
                                        <button type="submit" class="text-xs text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 hover:underline">
                                            {{ $op->status === 'active' ? 'إغلاق' : 'تفعيل' }}
                                        </button>
                                    </form>
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    <form action="{{ route('dashboard.volunteers.opportunities.destroy', $op->id) }}" method="POST" onsubmit="return confirm('تأكيد حذف هذه الفرصة التطوعية؟');" class="inline">
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
                            <td colspan="7" class="px-4 py-6 text-center text-zinc-400">
                                لا توجد فرص تطوعية مطروحة حالياً
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Volunteer Applications Review -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">طلبات الانضمام للفرص والمبادرات (Volunteer Applications)</h3>
            <span class="text-[11px] text-zinc-400 font-num">{{ $applications->count() }} طلبات مسجلة</span>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">اسم المتطوع المتقدم</th>
                        <th class="px-4 py-2.5 font-normal">الفرصة أو المبادرة</th>
                        <th class="px-4 py-2.5 font-normal">الجهة المنظمة</th>
                        <th class="px-4 py-2.5 font-normal">الحالة</th>
                        <th class="px-4 py-2.5 text-center font-normal">الإجراء</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($applications as $app)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-2.5 whitespace-nowrap">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $app->user?->name ?? 'متطوع مسجل' }}</div>
                                <div class="text-[10px] text-zinc-400 font-num">{{ $app->user?->phone }}</div>
                            </td>
                            <td class="px-4 py-2.5">
                                <div class="font-medium text-zinc-800 dark:text-zinc-200">{{ $app->opportunity?->title ?? $app->case_title ?? 'مبادرة إغاثية عامة' }}</div>
                                <div class="text-[10px] text-zinc-400">{{ $app->category ?? 'إغاثة ميدانية' }}</div>
                            </td>
                            <td class="px-4 py-2.5 whitespace-nowrap text-zinc-500">
                                {{ $app->organization_name ?? $app->opportunity?->organization?->name ?? 'أثر المركزية' }}
                            </td>
                            <td class="px-4 py-2.5 whitespace-nowrap text-[11px]">
                                @if(in_array($app->status, ['accepted', 'approved']))
                                    <span class="inline-flex items-center gap-1 text-emerald-700 dark:text-emerald-400 font-semibold text-[11px] bg-emerald-50 dark:bg-emerald-950/40 px-2 py-0.5 rounded border border-emerald-200 dark:border-emerald-800">
                                        <i class="fa-solid fa-circle-check text-[10px]"></i>
                                        <span>مقبول في الكادر</span>
                                    </span>
                                @elseif($app->status === 'rejected')
                                    <span class="inline-flex items-center gap-1 text-rose-700 dark:text-rose-400 font-semibold text-[11px] bg-rose-50 dark:bg-rose-950/40 px-2 py-0.5 rounded border border-rose-200 dark:border-rose-800">
                                        <i class="fa-solid fa-circle-xmark text-[10px]"></i>
                                        <span>طلب مرفوض</span>
                                    </span>
                                @else
                                    <span class="inline-flex items-center gap-1 text-amber-700 dark:text-amber-400 font-semibold text-[11px] bg-amber-50 dark:bg-amber-950/40 px-2 py-0.5 rounded border border-amber-200 dark:border-amber-800">
                                        <i class="fa-solid fa-clock text-[10px] animate-pulse"></i>
                                        <span>بانتظار موافقة الإدارة</span>
                                    </span>
                                @endif
                            </td>
                            <td class="px-4 py-2.5 whitespace-nowrap text-center">
                                @if($app->status === 'pending' || empty($app->status))
                                    <div class="flex items-center justify-center gap-1.5">
                                        <form action="{{ route('dashboard.volunteers.applications.status', $app->id) }}" method="POST">
                                            @csrf
                                            <input type="hidden" name="status" value="accepted">
                                            <button type="submit" class="px-2.5 py-1 rounded bg-emerald-600 hover:bg-emerald-500 text-white text-[11px] font-semibold flex items-center gap-1 shadow-sm transition-colors" title="الموافقة على طلب المتطوع">
                                                <i class="fa-solid fa-check text-[10px]"></i>
                                                <span>قبول المتطوع</span>
                                            </button>
                                        </form>
                                        <form action="{{ route('dashboard.volunteers.applications.status', $app->id) }}" method="POST">
                                            @csrf
                                            <input type="hidden" name="status" value="rejected">
                                            <button type="submit" class="px-2.5 py-1 rounded border border-rose-300 dark:border-rose-700 text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950 text-[11px] font-medium transition-colors" title="رفض الطلب">
                                                <i class="fa-solid fa-xmark text-[10px]"></i>
                                                <span>رفض</span>
                                            </button>
                                        </form>
                                    </div>
                                @elseif(in_array($app->status, ['accepted', 'approved']))
                                    <div class="flex items-center justify-center gap-2">
                                        <span class="text-[11px] text-emerald-600 dark:text-emerald-400 font-medium">معتمد بالفرصة</span>
                                        <form action="{{ route('dashboard.volunteers.applications.status', $app->id) }}" method="POST" class="inline">
                                            @csrf
                                            <input type="hidden" name="status" value="rejected">
                                            <button type="submit" class="text-[10px] text-zinc-400 hover:text-rose-600 hover:underline" title="إلغاء القبول والتحويل إلى رفض">
                                                (تغيير إلى رفض)
                                            </button>
                                        </form>
                                    </div>
                                @elseif($app->status === 'rejected')
                                    <div class="flex items-center justify-center gap-2">
                                        <span class="text-[11px] text-rose-500 font-medium">مستبعد</span>
                                        <form action="{{ route('dashboard.volunteers.applications.status', $app->id) }}" method="POST" class="inline">
                                            @csrf
                                            <input type="hidden" name="status" value="accepted">
                                            <button type="submit" class="text-[10px] text-emerald-600 dark:text-emerald-400 hover:underline" title="إعادة قبول الطلب">
                                                (إعادة القبول)
                                            </button>
                                        </form>
                                    </div>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="px-4 py-6 text-center text-zinc-400">
                                لا توجد طلبات تطوع معلقة حالياً
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Modal 1: Log Hours -->
    <div x-show="logModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="logModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-sm w-full p-5 space-y-3">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">اعتماد ساعات ميدانية للمتطوع</h4>
                <button @click="logModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <div class="p-2 bg-zinc-50 dark:bg-zinc-800 rounded text-xs font-medium text-zinc-800 dark:text-zinc-200" x-text="selectedVolunteerName"></div>

            <form :action="'{{ url('/dashboard/volunteers') }}/' + selectedVolunteerId + '/log-hours'" method="POST" class="space-y-3 text-xs">
                @csrf
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">عدد الساعات الميدانية</label>
                    <input type="number" step="0.5" name="hours" required min="0.5" value="4.0" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num">
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">نوع النشاط الميداني</label>
                    <select name="mission_type" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                        <option value="field_assessment">كشف ومعاينة ميدانية</option>
                        <option value="aid_distribution" selected>توزيع معونات ببطاقة NFC</option>
                        <option value="emergency_mission">استجابة طارئة وإغاثة</option>
                    </select>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">ملاحظات التوثيق</label>
                    <input type="text" name="notes" placeholder="ملاحظات الاعتماد..." class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="logModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">تأكيد الاعتماد</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 2: Award Badge -->
    <div x-show="badgeModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="badgeModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-sm w-full p-5 space-y-3">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">منح وسام شرف في جواز السفر الرقمي</h4>
                <button @click="badgeModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <div class="p-2 bg-zinc-50 dark:bg-zinc-800 rounded text-xs font-medium text-zinc-800 dark:text-zinc-200" x-text="selectedVolunteerName"></div>

            <form :action="'{{ url('/dashboard/volunteers') }}/' + selectedVolunteerId + '/award-badge'" method="POST" class="space-y-3 text-xs">
                @csrf
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">اختر الوسام الممنوح</label>
                    <select name="badge" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                        <option value="مستجيب الطوارئ الأول">مستجيب الطوارئ الأول (Emergency First Responder)</option>
                        <option value="مسعف ميداني معتمد">مسعف ميداني معتمد (Certified Field Medic)</option>
                        <option value="نجم التوزيع اللاتلامسي">نجم التوزيع اللاتلامسي (NFC Precision Master)</option>
                        <option value="مدقق الأثر الإنساني">مدقق الأثر الإنساني (Humanitarian Impact Auditor)</option>
                    </select>
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="badgeModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">منح الوسام وتوثيقه</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 3: Create Volunteer Opportunity -->
    <div x-show="opportunityModalOpen" x-cloak class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div x-show="opportunityModalOpen" @click="opportunityModalOpen = false" class="fixed inset-0 bg-zinc-950/60 backdrop-blur-xs transition-opacity"></div>
            <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

            <div class="inline-block align-bottom bg-white dark:bg-zinc-900 rounded-lg text-right overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full border border-zinc-200 dark:border-zinc-800">
                <form action="{{ route('dashboard.volunteers.opportunities.store') }}" method="POST">
                    @csrf
                    <div class="p-6 space-y-4">
                        <div class="flex items-center justify-between border-b border-zinc-200 dark:border-zinc-800 pb-3">
                            <h3 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100">طرح فرصة تطوعية جديدة</h3>
                            <button type="button" @click="opportunityModalOpen = false" class="text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 text-xs">
                                <i class="fa-solid fa-xmark"></i>
                            </button>
                        </div>

                        <div>
                            <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">عنوان المبادرة / الفرصة التطوعية</label>
                            <input type="text" name="title" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 outline-none" placeholder="مثال: حملة توزيع الحقائب المدرسية في ريف دمشق">
                        </div>

                        <div class="grid grid-cols-2 gap-3">
                            <div>
                                <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">المجال / التصنيف</label>
                                <select name="category" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 outline-none">
                                    <option value="إغاثة عامة">إغاثة عامة</option>
                                    <option value="رعاية صحية">رعاية صحية وإسعاف</option>
                                    <option value="سلة غذائية">سلة غذائية ولوجستيات</option>
                                    <option value="كشف ميداني">كشف وتقييم سكني</option>
                                    <option value="تعليم وتدريب">تعليم وتدريب</option>
                                </select>
                            </div>

                            <div>
                                <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">المحافظة</label>
                                <select name="governorate" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 outline-none">
                                    @foreach($governorates as $gov)
                                        <option value="{{ $gov->name }}">{{ $gov->name }}</option>
                                    @endforeach
                                </select>
                            </div>
                        </div>

                        <div class="grid grid-cols-2 gap-3">
                            <div>
                                <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">عدد المتطوعين المطلوب</label>
                                <input type="number" name="volunteers_needed" min="1" required value="10" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 font-num outline-none">
                            </div>

                            <div>
                                <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">مستوى الأولوية</label>
                                <select name="priority" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 outline-none">
                                    <option value="urgent">عاجل وفوري (Urgent)</option>
                                    <option value="high" selected>مرتفع (High)</option>
                                    <option value="medium">متوسط (Medium)</option>
                                    <option value="low">عادي (Low)</option>
                                </select>
                            </div>
                        </div>

                        <div>
                            <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">وصف المهام الميدانية والمؤهلات المطلوبة</label>
                            <textarea name="description" rows="3" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded p-2.5 text-xs text-zinc-900 dark:text-zinc-100 outline-none" placeholder="اشرح طبيعة العمل الميداني، الساعات المتوقعة، والمهارات المطلوبة..."></textarea>
                        </div>

                        <div class="flex items-center gap-2 pt-1">
                            <input type="checkbox" name="is_urgent" id="is_urgent" value="1" class="rounded border-zinc-300 text-zinc-900 focus:ring-0">
                            <label for="is_urgent" class="text-xs text-zinc-700 dark:text-zinc-300">تصنيف كاستنفار طارئ (يظهر في رأس قائمة التطوع)</label>
                        </div>
                    </div>

                    <div class="bg-zinc-50 dark:bg-zinc-800/60 px-6 py-3 border-t border-zinc-200 dark:border-zinc-800 flex items-center justify-end gap-2">
                        <button type="button" @click="opportunityModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-xs text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800">
                            إلغاء
                        </button>
                        <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-xs font-medium hover:bg-zinc-800 dark:hover:bg-white">
                            نشر الفرصة في التطبيق
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>


    <!-- Edit Volunteer Opportunity Modal -->
    <div x-show="editOpportunityModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="editOpportunityModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-3 max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">تعديل بيانات الفرصة التطوعية</h4>
                <button @click="editOpportunityModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form :action="'{{ url('dashboard/volunteers/opportunities') }}/' + editingOpportunity.id" method="POST" class="space-y-3 text-xs">
                @csrf
                @method('PUT')
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">عنوان الفرصة أو المبادرة</label>
                    <input type="text" name="title" x-model="editingOpportunity.title" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المحافظة</label>
                        <select name="governorate" x-model="editingOpportunity.governorate" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            @foreach($governorates as $gov)
                                <option value="{{ $gov->name }}">{{ $gov->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">التصنيف الإغاثي</label>
                        <input type="text" name="category" x-model="editingOpportunity.category" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                </div>

                <div class="grid grid-cols-3 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">العدد المطلوب</label>
                        <input type="number" name="volunteers_needed" x-model="editingOpportunity.volunteers_needed" required min="1" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">درجة الأولوية</label>
                        <select name="priority" x-model="editingOpportunity.priority" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="urgent">عاجل وفوري</option>
                            <option value="normal">عادي</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">حالة الفرصة</label>
                        <select name="status" x-model="editingOpportunity.status" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="active">متاحة للتقديم</option>
                            <option value="closed">مغلقة ومكتملة</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">وصف المهام والمسؤوليات</label>
                    <textarea name="description" rows="2" x-model="editingOpportunity.description" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none"></textarea>
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="editOpportunityModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">حفظ التعديلات</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
