@extends('layouts.dashboard')

@section('title', 'مركز إدارة المستفيدين وبطاقات NFC الذكية')
@section('page_title', 'المستفيدون وبطاقات NFC الذكية (Beneficiary Hub)')

@section('content')
<div class="space-y-5" x-data="{
    registerModalOpen: false,
    editModalOpen: false,
    cardModalOpen: false,
    selectedBeneficiary: null,
    editingBeneficiary: {},

    showCard(ben) {
        this.selectedBeneficiary = ben;
        this.cardModalOpen = true;
    },
    openEdit(ben) {
        this.editingBeneficiary = { ...ben };
        this.editModalOpen = true;
    }
}">

    <!-- Top Action & Search Bar -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs">
        
        <!-- Search Input -->
        <form action="{{ route('dashboard.beneficiaries') }}" method="GET" class="w-full sm:w-80 relative">
            <input type="text" 
                   name="search" 
                   value="{{ request('search') }}" 
                   placeholder="بحث بالاسم، الرقم الوطني، أو رقم الملف..." 
                   class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded pr-8 pl-3 py-2 outline-none">
            <i class="fa-solid fa-magnifying-glass absolute right-2.5 top-2.5 text-zinc-400 text-xs"></i>
        </form>

        <!-- Register New Family Button -->
        <button type="button" 
                @click="registerModalOpen = true" 
                class="w-full sm:w-auto px-4 py-2 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 font-semibold text-xs shadow-sm transition-colors flex items-center justify-center gap-1.5">
            <i class="fa-solid fa-plus text-[10px]"></i>
            <span>تسجيل أسرة جديدة وربط بطاقة NFC</span>
        </button>
    </div>

    <!-- Beneficiaries Data Table -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل العائلات المستفيدة والمطابقة الرقمية</h3>
            <span class="text-[11px] text-zinc-400 font-num">NFC Ledger ID Sync</span>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">رقم الملف والاسم الثلاثي</th>
                        <th class="px-4 py-2.5 font-normal">الرقم الوطني والهاتف</th>
                        <th class="px-4 py-2.5 font-normal">أفراد الأسرة والمحافظة</th>
                        <th class="px-4 py-2.5 font-normal">مستوى الهشاشة</th>
                        <th class="px-4 py-2.5 font-normal">معرف بطاقة NFC</th>
                        <th class="px-4 py-2.5 font-normal">إجمالي التوزيعات</th>
                        <th class="px-4 py-2.5 text-center font-normal">البطاقة</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($beneficiaries as $ben)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            
                            <!-- File & Name -->
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100 text-xs">{{ $ben->full_name }}</div>
                                <div class="text-[10px] text-zinc-400 font-num">{{ $ben->file_number ?? 'ATHAR-FAM-2026-000' }}</div>
                            </td>

                            <!-- National ID & Phone -->
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px]">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $ben->national_id }}</div>
                                <div class="text-zinc-400">{{ $ben->phone }}</div>
                            </td>

                            <!-- Family count & Governorate -->
                            <td class="px-4 py-3 whitespace-nowrap">
                                <div class="text-zinc-800 dark:text-zinc-200">{{ $ben->family_members_count }} أفراد</div>
                                <div class="text-[10px] text-zinc-400">{{ $ben->governorate?->name ?? 'دمشق' }} • {{ $ben->address }}</div>
                            </td>

                            <!-- Vulnerability -->
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($ben->vulnerability_level === 'critical')
                                    <span class="inline-flex items-center gap-1 text-[11px] font-semibold text-rose-700 dark:text-rose-400 bg-rose-50 dark:bg-rose-950/40 px-2 py-0.5 rounded border border-rose-200 dark:border-rose-900/60">
                                        <span class="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
                                        حرجة جداً
                                    </span>
                                @elseif($ben->vulnerability_level === 'high')
                                    <span class="inline-flex items-center gap-1 text-[11px] font-semibold text-amber-700 dark:text-amber-400 bg-amber-50 dark:bg-amber-950/40 px-2 py-0.5 rounded border border-amber-200 dark:border-amber-900/60">
                                        <span class="w-1.5 h-1.5 rounded-full bg-amber-500"></span>
                                        مرتفعة
                                    </span>
                                @else
                                    <span class="inline-flex items-center gap-1 text-[11px] text-zinc-600 dark:text-zinc-400 bg-zinc-100 dark:bg-zinc-800 px-2 py-0.5 rounded">
                                        متوسطة
                                    </span>
                                @endif
                            </td>

                            <!-- NFC UID -->
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px]">
                                @if($ben->nfcCard)
                                    <span class="inline-flex items-center gap-1 text-emerald-700 dark:text-emerald-400 font-medium bg-emerald-50 dark:bg-emerald-950/40 px-2 py-0.5 rounded border border-emerald-200 dark:border-emerald-800/60">
                                        <i class="fa-solid fa-wifi rotate-90 text-[9px]"></i>
                                        {{ $ben->nfcCard->card_uid }}
                                    </span>
                                @else
                                    <span class="text-zinc-400 italic">غير مرتبطة</span>
                                @endif
                            </td>

                            <!-- Total Distributions -->
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px]">
                                <span class="font-medium text-zinc-900 dark:text-zinc-100">{{ $ben->distributions->count() }}</span>
                                <span class="text-zinc-400">صرف</span>
                            </td>

                            <!-- Actions / Print Card -->
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                <div class="flex items-center justify-center gap-2">
                                    <button type="button"
                                            onclick="window.dispatchEvent(new CustomEvent('open-nfc-simulator', { detail: { beneficiary_id: {{ $ben->id }} } }))"
                                            class="text-teal-600 dark:text-teal-400 hover:text-teal-800 dark:hover:text-teal-200 text-xs font-semibold hover:underline flex items-center gap-1"
                                            title="اختبار تمرير البطاقة في محاكي NFC ثلاثي الأبعاد">
                                        <i class="fa-solid fa-satellite-dish text-[10px]"></i>
                                        <span>محاكاة 3D</span>
                                    </button>
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    <button type="button" 
                                            @click="showCard({
                                                id: {{ $ben->id }},
                                                name: '{{ addslashes($ben->full_name) }}',
                                                file: '{{ $ben->file_number }}',
                                                national_id: '{{ $ben->national_id }}',
                                                members: {{ $ben->family_members_count }},
                                                gov: '{{ $ben->governorate?->name ?? 'دمشق' }}',
                                                nfc: '{{ $ben->nfcCard?->card_uid ?? 'N/A' }}',
                                                distributions_count: {{ $ben->distributions->count() }}
                                            })" 
                                            class="text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-zinc-100 text-xs hover:underline">
                                        بطاقة
                                    </button>
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    <button type="button"
                                            @click="openEdit({{ json_encode([
                                                'id' => $ben->id,
                                                'full_name' => $ben->full_name,
                                                'national_id' => $ben->national_id,
                                                'phone' => $ben->phone,
                                                'family_members_count' => $ben->family_members_count,
                                                'governorate_id' => $ben->governorate_id,
                                                'address' => $ben->address_details,
                                                'vulnerability_level' => $ben->vulnerability_level,
                                                'nfc_uid' => $ben->nfcCard?->card_uid ?? '',
                                            ]) }})"
                                            class="text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-zinc-100 text-xs hover:underline">
                                        تعديل
                                    </button>
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    <form action="{{ route('dashboard.beneficiaries.destroy', $ben->id) }}" method="POST" onsubmit="return confirm('تأكيد حذف ملف هذه الأسرة المستفيدة وسجلاتها؟');" class="inline">
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
                                لا توجد عائلات مسجلة حالياً
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="p-3 border-t border-zinc-100 dark:border-zinc-800 text-xs">
            {{ $beneficiaries->links() }}
        </div>
    </div>

    <!-- Modal 1: Register Beneficiary Family & Pair NFC Card -->
    <div x-show="registerModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="registerModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-3 max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">تسجيل أسرة مستفيدة وربط بطاقة NFC</h4>
                <button @click="registerModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form action="{{ route('dashboard.beneficiaries.store') }}" method="POST" class="space-y-3 text-xs">
                @csrf
                
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">اسم معيل الأسرة الثلاثي</label>
                    <input type="text" name="full_name" required placeholder="الاسم الكامل..." class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">الرقم الوطني السوري</label>
                        <input type="text" name="national_id" required placeholder="01010098765" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">رقم الهاتف الجوال</label>
                        <input type="text" name="phone" required placeholder="0944123456" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">عدد أفراد الأسرة</label>
                        <input type="number" name="family_members_count" required min="1" value="5" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المحافظة</label>
                        <select name="governorate_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            @foreach($governorates as $gov)
                                <option value="{{ $gov->id }}">{{ $gov->name }}</option>
                            @endforeach
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">العنوان التفصيلي</label>
                    <input type="text" name="address" required placeholder="المدينة - الحي..." class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">مستوى الهشاشة</label>
                    <select name="vulnerability_level" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                        <option value="critical">حرجة جداً</option>
                        <option value="high" selected>مرتفعة</option>
                        <option value="medium">متوسطة</option>
                        <option value="low">منخفضة</option>
                    </select>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">معرف بطاقة NFC (UID)</label>
                    <input type="text" name="nfc_uid" placeholder="04A1B2C3D4E5" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none uppercase">
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="registerModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 font-semibold shadow-sm transition-colors">حفظ واعتماد الأسرة</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 2: Virtual NFC Smart ID Card (Minimalist Executive Card) -->
    <div x-show="cardModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/60 backdrop-blur-sm">
        <div @click.away="cardModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-sm w-full p-5 space-y-4">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">بطاقة المستفيد الذكية</h4>
                <button @click="cardModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <!-- Virtual Card (Matte Charcoal Sovereign Card) -->
            <div id="printableCard" class="bg-zinc-900 text-white border border-zinc-800 rounded-lg p-4 space-y-3">
                <div class="flex items-center justify-between border-b border-zinc-800 pb-2">
                    <div class="text-xs font-semibold">منصة أَثَــر • بطاقة المعونة الذكية</div>
                    <span class="font-num text-[10px] text-zinc-400">NFC CONTACTLESS</span>
                </div>

                <div class="space-y-1">
                    <div class="text-sm font-semibold" x-text="selectedBeneficiary ? selectedBeneficiary.name : ''"></div>
                    <div class="text-xs font-num text-zinc-400" x-text="'الرقم الوطني: ' + (selectedBeneficiary ? selectedBeneficiary.national_id : '')"></div>
                    <div class="text-[11px] text-zinc-400" x-text="'المحافظة: ' + (selectedBeneficiary ? selectedBeneficiary.gov : '') + ' • الأفراد: ' + (selectedBeneficiary ? selectedBeneficiary.members : '')"></div>
                </div>

                <div class="flex items-center justify-between pt-2 border-t border-zinc-800 text-xs">
                    <div class="font-num">
                        <div class="text-[9px] text-zinc-500 uppercase">UID</div>
                        <div class="font-medium text-xs text-zinc-300" x-text="selectedBeneficiary ? selectedBeneficiary.nfc : 'NOT PAIRED'"></div>
                    </div>
                    <div class="w-8 h-8 bg-white text-zinc-900 rounded p-1 flex items-center justify-center">
                        <i class="fa-solid fa-qrcode text-lg"></i>
                    </div>
                </div>
            </div>

            <div class="flex justify-end pt-1">
                <button type="button" onclick="window.print()" class="px-3 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-xs font-medium">
                    طباعة الملصق
                </button>
            </div>
        </div>
    </div>

    <!-- Modal 3: Edit Beneficiary Family Modal -->
    <div x-show="editModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="editModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-3 max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">تعديل بيانات الأسرة المستفيدة</h4>
                <button @click="editModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form :action="'{{ url('dashboard/beneficiaries') }}/' + editingBeneficiary.id" method="POST" class="space-y-3 text-xs">
                @csrf
                @method('PUT')
                
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">اسم رب الأسرة الثلاثي</label>
                    <input type="text" name="full_name" x-model="editingBeneficiary.full_name" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">الرقم الوطني السوري</label>
                        <input type="text" name="national_id" x-model="editingBeneficiary.national_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">رقم الهاتف للتواصل</label>
                        <input type="text" name="phone" x-model="editingBeneficiary.phone" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                </div>

                <div class="grid grid-cols-3 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">عدد الأفراد</label>
                        <input type="number" name="family_members_count" x-model="editingBeneficiary.family_members_count" min="1" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المحافظة</label>
                        <select name="governorate_id" x-model="editingBeneficiary.governorate_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            @foreach($governorates as $gov)
                                <option value="{{ $gov->id }}">{{ $gov->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">مستوى الهشاشة</label>
                        <select name="vulnerability_level" x-model="editingBeneficiary.vulnerability_level" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="critical">حرجة جداً</option>
                            <option value="high">مرتفعة</option>
                            <option value="medium">متوسطة</option>
                            <option value="low">منخفضة</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">العنوان التفصيلي والسكن الحالي</label>
                    <input type="text" name="address" x-model="editingBeneficiary.address" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">معرف بطاقة NFC (اختياري / تحديث)</label>
                    <input type="text" name="nfc_uid" x-model="editingBeneficiary.nfc_uid" placeholder="04A1B2C3D4E5" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none uppercase">
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="editModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">حفظ التعديلات</button>
                </div>
            </form>
        </div>
    </div>

</div>
@endsection
