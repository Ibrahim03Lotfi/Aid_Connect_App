@extends('layouts.dashboard')

@section('title', 'إدارة الشركاء واعتماد الجمعيات')
@section('page_title', 'إدارة الشركاء واعتماد الجمعيات (NGO Accreditation Hub)')

@section('content')
<div class="space-y-6" x-data="{
    rejectModalOpen: false,
    selectedReqId: null,
    selectedOrgName: '',
    openReject(id, name) {
        this.selectedReqId = id;
        this.selectedOrgName = name;
        this.rejectModalOpen = true;
    }
}">

    <!-- Stats Row -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">إجمالي طلبات الانضمام</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ $totalRequests }}</div>
            <div class="text-[11px] text-zinc-400">ملفات الجمعيات والمبادرات الأهلية</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">طلبات قيد التدقيق والتحقق</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ $pendingCount }}</div>
            <div class="text-[11px] text-zinc-400">بانتظار مطابقة التراخيص الرسمية</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">منظمات معتمدة ومفعلة</div>
            <div class="text-2xl font-semibold font-num text-emerald-700 dark:text-emerald-400">{{ $approvedCount }}</div>
            <div class="text-[11px] text-zinc-400">تمتلك صلاحية رفع الحالات وإطلاق المبادرات</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">حسابات الشركاء المؤسسية</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ $registeredNgos->count() }}</div>
            <div class="text-[11px] text-zinc-400">حسابات وصول لوحة المنظمات الميدانية</div>
        </div>
    </div>

    <!-- Requests Table -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل طلبات الترخيص والشراكة الإغاثية</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">مراجعة أوراق الاعتماد وإشهار الجمعيات الأهلية والمنظمات الإنسانية</p>
            </div>

            <!-- Status Filter -->
            <div class="flex items-center gap-1.5 text-xs">
                <a href="{{ route('dashboard.organizations') }}" class="px-2.5 py-1 rounded {{ !request('status') ? 'bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium' : 'text-zinc-500 hover:bg-zinc-100 dark:hover:bg-zinc-800' }}">الكل</a>
                <a href="{{ route('dashboard.organizations', ['status' => 'pending']) }}" class="px-2.5 py-1 rounded {{ request('status') === 'pending' ? 'bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium' : 'text-zinc-500 hover:bg-zinc-100 dark:hover:bg-zinc-800' }}">قيد المراجعة</a>
                <a href="{{ route('dashboard.organizations', ['status' => 'approved']) }}" class="px-2.5 py-1 rounded {{ request('status') === 'approved' ? 'bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium' : 'text-zinc-500 hover:bg-zinc-100 dark:hover:bg-zinc-800' }}">المعتمدة</a>
                <a href="{{ route('dashboard.organizations', ['status' => 'rejected']) }}" class="px-2.5 py-1 rounded {{ request('status') === 'rejected' ? 'bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium' : 'text-zinc-500 hover:bg-zinc-100 dark:hover:bg-zinc-800' }}">المرفوضة</a>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">اسم المنظمة / الجمعية</th>
                        <th class="px-4 py-2.5 font-normal">رقم الإشهار الرسمي</th>
                        <th class="px-4 py-2.5 font-normal">بيانات الاتصال</th>
                        <th class="px-4 py-2.5 font-normal">المقر الجغرافي</th>
                        <th class="px-4 py-2.5 font-normal">الحالة</th>
                        <th class="px-4 py-2.5 text-center font-normal">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($requests as $req)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100 text-xs">{{ $req->name }}</div>
                                <div class="text-[11px] text-zinc-400 line-clamp-1 max-w-xs">{{ $req->description }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-zinc-900 dark:text-zinc-100 font-medium">
                                {{ $req->registration_number }}
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px]">
                                <div class="text-zinc-800 dark:text-zinc-200">{{ $req->phone }}</div>
                                <div class="text-zinc-400">{{ $req->email }}</div>
                            </td>
                            <td class="px-4 py-3 text-zinc-600 dark:text-zinc-400">
                                {{ $req->address }}
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($req->status === 'approved')
                                    <span class="text-emerald-700 dark:text-emerald-400 font-medium">معتمدة رسمياً</span>
                                @elseif($req->status === 'rejected')
                                    <span class="text-rose-600 dark:text-rose-400 font-medium">مرفوض</span>
                                    @if($req->rejection_reason)
                                        <div class="text-[10px] text-zinc-400 line-clamp-1">{{ $req->rejection_reason }}</div>
                                    @endif
                                @else
                                    <span class="text-zinc-600 dark:text-zinc-400">قيد التدقيق</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                @if($req->status === 'pending')
                                    <div class="flex items-center justify-center gap-1.5">
                                        <form action="{{ route('dashboard.organizations.approve', $req->id) }}" method="POST">
                                            @csrf
                                            <button type="submit" class="px-2.5 py-1 rounded bg-emerald-600 hover:bg-emerald-500 text-white text-[11px] font-semibold flex items-center gap-1 shadow-sm transition-colors">
                                                <i class="fa-solid fa-check text-[10px]"></i>
                                                <span>اعتماد وشراكة</span>
                                            </button>
                                        </form>
                                        <button type="button" @click="openReject({{ $req->id }}, '{{ addslashes($req->name) }}')" class="px-2.5 py-1 rounded border border-rose-300 dark:border-rose-700 text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950 text-[11px] font-medium transition-colors">
                                            <i class="fa-solid fa-xmark text-[10px]"></i>
                                            <span>رفض</span>
                                        </button>
                                    </div>
                                @elseif($req->status === 'approved')
                                    <div class="flex items-center justify-center gap-2">
                                        <span class="text-[11px] text-emerald-600 dark:text-emerald-400 font-medium">شريك معتمد</span>
                                        <button type="button" @click="openReject({{ $req->id }}, '{{ addslashes($req->name) }}')" class="text-[10px] text-zinc-400 hover:text-rose-600 hover:underline" title="إلغاء الترخيص والشراكة">
                                            (تجميد الشراكة)
                                        </button>
                                    </div>
                                @else
                                    <div class="flex items-center justify-center gap-2">
                                        <span class="text-[11px] text-rose-500 font-medium">مرفوض</span>
                                        <form action="{{ route('dashboard.organizations.approve', $req->id) }}" method="POST" class="inline">
                                            @csrf
                                            <button type="submit" class="text-[10px] text-emerald-600 dark:text-emerald-400 hover:underline" title="إعادة تدقيق واعتماد المنظمة">
                                                (إعادة الاعتماد)
                                            </button>
                                        </form>
                                    </div>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-4 py-8 text-center text-zinc-400">
                                لا توجد طلبات اعتماد شراكة مسجلة في هذا القسم
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($requests->hasPages())
            <div class="p-3 border-t border-zinc-200 dark:border-zinc-800">
                {{ $requests->links() }}
            </div>
        @endif
    </div>

    <!-- Active Accredited NGO Accounts -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">منظمات الإغاثة المعتمدة في النظام (Active Partner NGOs)</h3>
            <span class="text-[11px] text-zinc-400 font-num">{{ $registeredNgos->count() }} منظمات نشطة</span>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">اسم الشريك</th>
                        <th class="px-4 py-2.5 font-normal">البريد والهاتف</th>
                        <th class="px-4 py-2.5 font-normal">رقم الترخيص</th>
                        <th class="px-4 py-2.5 font-normal">المحافظة / العنوان</th>
                        <th class="px-4 py-2.5 font-normal">الحالات التابعة</th>
                        <th class="px-4 py-2.5 font-normal">الحالة</th>
                        <th class="px-4 py-2.5 text-center font-normal">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($registeredNgos as $ngo)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-2.5 font-medium text-zinc-900 dark:text-zinc-100">{{ $ngo->name }}</td>
                            <td class="px-4 py-2.5 font-num text-[11px]">{{ $ngo->email }} • {{ $ngo->phone }}</td>
                            <td class="px-4 py-2.5 font-num text-zinc-600 dark:text-zinc-400">{{ $ngo->registration_number ?? 'MO-SYR-2026' }}</td>
                            <td class="px-4 py-2.5 text-zinc-500">{{ $ngo->address ?? 'دمشق، الجمهورية العربية السورية' }}</td>
                            <td class="px-4 py-2.5 font-num text-zinc-900 dark:text-zinc-100 font-medium">{{ $ngo->cases()->count() }} حالات</td>
                            <td class="px-4 py-2.5 whitespace-nowrap text-[11px]">
                                @if($ngo->is_active ?? true)
                                    <span class="text-emerald-700 dark:text-emerald-400 font-medium">نشط ومفعل</span>
                                @else
                                    <span class="text-rose-600 dark:text-rose-400 font-medium">مجمد</span>
                                @endif
                            </td>
                            <td class="px-4 py-2.5 whitespace-nowrap text-center">
                                <div class="flex items-center justify-center gap-2">
                                    <form action="{{ route('dashboard.users.toggle', $ngo->id) }}" method="POST" class="inline">
                                        @csrf
                                        @if($ngo->is_active ?? true)
                                            <button type="submit" class="text-xs text-zinc-400 hover:text-amber-600 hover:underline">
                                                تجميد الحساب
                                            </button>
                                        @else
                                            <button type="submit" class="text-xs text-emerald-600 hover:text-emerald-800 hover:underline">
                                                تنشيط الحساب
                                            </button>
                                        @endif
                                    </form>
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    <a href="{{ route('dashboard.cases') }}" class="text-xs text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-zinc-100 hover:underline">
                                        الحالات &rarr;
                                    </a>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="px-4 py-6 text-center text-zinc-400">
                                لم يتم تسجيل حسابات منظمات شريكة حتى الآن
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Reject Modal -->
    <div x-show="rejectModalOpen" x-cloak class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div x-show="rejectModalOpen" @click="rejectModalOpen = false" class="fixed inset-0 bg-zinc-950/60 backdrop-blur-xs transition-opacity"></div>
            <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

            <div class="inline-block align-bottom bg-white dark:bg-zinc-900 rounded-lg text-right overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-md sm:w-full border border-zinc-200 dark:border-zinc-800">
                <form :action="`/dashboard/organizations/${selectedReqId}/reject`" method="POST">
                    @csrf
                    <div class="p-6 space-y-4">
                        <div class="flex items-center justify-between border-b border-zinc-200 dark:border-zinc-800 pb-3">
                            <h3 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100">رفض طلب الاعتماد والشراكة</h3>
                            <button type="button" @click="rejectModalOpen = false" class="text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 text-xs">
                                <i class="fa-solid fa-xmark"></i>
                            </button>
                        </div>

                        <p class="text-xs text-zinc-600 dark:text-zinc-400">
                            أنت على وشك رفض طلب منظمة <span class="font-semibold text-zinc-900 dark:text-zinc-100" x-text="selectedOrgName"></span>. يرجى توضيح سبب الرفض لحفظه في سجل الحوكمة وإشعار ممثل المنظمة.
                        </p>

                        <div>
                            <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">سبب الرفض والتدقيق</label>
                            <textarea name="rejection_reason" rows="3" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded p-2.5 text-xs text-zinc-900 dark:text-zinc-100 outline-none" placeholder="مثال: رقم الإشهار غير مسجل لدى وزارة الشؤون الاجتماعية أو الأوراق غير مكتملة..."></textarea>
                        </div>
                    </div>

                    <div class="bg-zinc-50 dark:bg-zinc-800/60 px-6 py-3 border-t border-zinc-200 dark:border-zinc-800 flex items-center justify-end gap-2">
                        <button type="button" @click="rejectModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-xs text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800">
                            إلغاء
                        </button>
                        <button type="submit" class="px-4 py-1.5 rounded bg-rose-600 text-white text-xs font-medium hover:bg-rose-700">
                            تأكيد رفض الطلب
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

</div>
@endsection
