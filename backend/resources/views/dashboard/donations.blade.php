@extends('layouts.dashboard')

@section('title', 'سجل الشفافية المالية والتبرعات')
@section('page_title', 'الشفافية المالية والتبرعات (Donations Ledger)')

@section('content')
<div class="space-y-5" x-data="{ 
    donationModalOpen: false,
    receiptModalOpen: false,
    selectedReceipt: null,
    showReceipt(don) {
        this.selectedReceipt = don;
        this.receiptModalOpen = true;
    }
}">

    <!-- Stat Overview -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">إجمالي التبرعات المحصلة</div>
            <div class="text-2xl font-semibold font-num text-emerald-700 dark:text-emerald-400">{{ number_format($totalCollected) }} ل.س</div>
            <div class="text-[11px] text-zinc-400">شام كاش وسيريتل كاش والتحويل المباشر</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">عدد الحركات المالية المنفذة</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ $totalCount }}</div>
            <div class="text-[11px] text-zinc-400">عملية مساهمة مكتملة</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">التحقق المالي الإلكتروني</div>
            <div class="text-xs font-semibold text-zinc-800 dark:text-zinc-200 pt-1 font-num">{{ $shamCashCount }} مدفوعات إلكترونية</div>
            <div class="text-[11px] text-zinc-400">تطابق فوري مع السجل المصرفي</div>
        </div>
    </div>

    <!-- Donations Table -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل التدفقات المالية والمساهمات</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">شفافية رقمية كاملة لكل ليرة تم التبرع بها للحالات المعتمدة</p>
            </div>
            <div class="flex items-center gap-2">
                <button type="button" @click="donationModalOpen = true" class="px-3 py-1.5 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 text-xs font-semibold shadow-sm flex items-center gap-1.5 transition-colors">
                    <i class="fa-solid fa-plus text-[10px]"></i>
                    <span>تسجيل مساهمة نقدية / مكتبية</span>
                </button>
                <span class="text-[11px] text-zinc-400 font-num">Financial Audit Ledger</span>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">رقم العملية والمتبرع</th>
                        <th class="px-4 py-2.5 font-normal">الهاتف</th>
                        <th class="px-4 py-2.5 font-normal">المبلغ والمطابقة</th>
                        <th class="px-4 py-2.5 font-normal">وسيلة الدفع</th>
                        <th class="px-4 py-2.5 font-normal">الحالة الإغاثية المستفيدة</th>
                        <th class="px-4 py-2.5 font-normal">الحالة</th>
                        <th class="px-4 py-2.5 text-center font-normal">التاريخ</th>
                        <th class="px-4 py-2.5 text-center font-normal">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($donations as $don)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $don->donor_name }}</div>
                                <div class="text-[10px] text-zinc-400 font-num">REF: {{ $don->transaction_ref }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px] text-zinc-500">
                                {{ $don->donor_phone ?? 'مجهول (فاعل خير)' }}
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num font-semibold text-zinc-900 dark:text-zinc-100">
                                {{ number_format($don->amount) }} {{ $don->currency ?? 'ل.س' }}
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($don->payment_method === 'sham_cash')
                                    <span class="font-num text-zinc-700 dark:text-zinc-300">Sham Cash</span>
                                @elseif($don->payment_method === 'syriatel_cash')
                                    <span class="font-num text-zinc-700 dark:text-zinc-300">Syriatel Cash</span>
                                @elseif($don->payment_method === 'bank_transfer')
                                    <span class="text-zinc-700 dark:text-zinc-300">حوالة مصرفية</span>
                                @else
                                    <span class="text-zinc-500">مساهمة نقدية</span>
                                @endif
                            </td>
                            <td class="px-4 py-3">
                                <span class="font-medium text-zinc-800 dark:text-zinc-200 line-clamp-1 max-w-xs">
                                    {{ $don->case?->title ?? 'صندوق الإغاثة العام' }}
                                </span>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($don->status === 'completed')
                                    <span class="inline-flex items-center gap-1 text-emerald-700 dark:text-emerald-400 font-semibold bg-emerald-50 dark:bg-emerald-950/40 px-2 py-0.5 rounded border border-emerald-200 dark:border-emerald-800">
                                        <i class="fa-solid fa-circle-check text-[10px]"></i>
                                        <span>مكتملة ومودعة</span>
                                    </span>
                                @elseif($don->status === 'failed')
                                    <span class="inline-flex items-center gap-1 text-rose-700 dark:text-rose-400 font-semibold bg-rose-50 dark:bg-rose-950/40 px-2 py-0.5 rounded border border-rose-200 dark:border-rose-800">
                                        <i class="fa-solid fa-circle-xmark text-[10px]"></i>
                                        <span>ملغاة</span>
                                    </span>
                                @else
                                    <span class="inline-flex items-center gap-1 text-amber-700 dark:text-amber-400 font-semibold bg-amber-50 dark:bg-amber-950/40 px-2 py-0.5 rounded border border-amber-200 dark:border-amber-800">
                                        <i class="fa-solid fa-clock text-[10px] animate-pulse"></i>
                                        <span>قيد المعالجة</span>
                                    </span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-center font-num text-[11px] text-zinc-400">
                                {{ $don->created_at ? $don->created_at->format('Y-m-d H:i') : '-' }}
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                <div class="flex items-center justify-center gap-2">
                                    <!-- Print / View Voucher Modal -->
                                    <button type="button"
                                            @click="showReceipt({{ json_encode([
                                                'id' => $don->id,
                                                'ref' => $don->transaction_ref,
                                                'donor_name' => $don->donor_name,
                                                'donor_phone' => $don->donor_phone ?? 'فاعل خير',
                                                'amount' => $don->amount,
                                                'currency' => $don->currency ?? 'ل.س',
                                                'payment_method' => $don->payment_method,
                                                'case_title' => $don->case?->title ?? 'صندوق الإغاثة المركزي العام',
                                                'case_id' => $don->case_id,
                                                'status' => $don->status,
                                                'created_at' => $don->created_at ? $don->created_at->format('Y-m-d H:i:s') : date('Y-m-d H:i:s'),
                                            ]) }})"
                                            class="text-xs text-zinc-900 dark:text-zinc-100 font-semibold hover:underline flex items-center gap-1"
                                            title="معاينة وطباعة سند القبض المالي الرسمي">
                                        <i class="fa-solid fa-receipt text-[10px]"></i>
                                        <span>سند القبض</span>
                                    </button>

                                    @if($don->status === 'pending')
                                        <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                        <form action="{{ route('dashboard.donations.approve', $don->id) }}" method="POST" class="inline">
                                            @csrf
                                            <button type="submit" class="px-2 py-0.5 rounded bg-emerald-600 hover:bg-emerald-500 text-white text-[11px] font-semibold transition-colors shadow-xs">
                                                اعتماد الإيداع
                                            </button>
                                        </form>
                                        <form action="{{ route('dashboard.donations.reject', $don->id) }}" method="POST" class="inline">
                                            @csrf
                                            <button type="submit" class="px-2 py-0.5 rounded border border-rose-300 dark:border-rose-700 text-rose-600 hover:bg-rose-50 text-[11px] font-medium transition-colors">
                                                إلغاء
                                            </button>
                                        </form>
                                    @elseif($don->status === 'failed')
                                        <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                        <form action="{{ route('dashboard.donations.approve', $don->id) }}" method="POST" class="inline">
                                            @csrf
                                            <button type="submit" class="text-[10px] text-emerald-600 dark:text-emerald-400 hover:underline">
                                                (إعادة الاعتماد)
                                            </button>
                                        </form>
                                    @endif
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" class="px-4 py-8 text-center text-zinc-400">
                                لا توجد تبرعات مسجلة في السجل المالي
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="p-3 border-t border-zinc-100 dark:border-zinc-800 text-xs">
            {{ $donations->links() }}
        </div>
    </div>

    <!-- Modal: Official Printable Receipt Voucher (سند قبض مالي معتمد) -->
    <div x-show="receiptModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/70 backdrop-blur-sm">
        <div @click.away="receiptModalOpen = false" class="bg-white text-zinc-900 border border-zinc-300 rounded-lg max-w-lg w-full p-6 space-y-4 max-h-[90vh] overflow-y-auto shadow-2xl relative">
            
            <!-- Top Controls (No-print) -->
            <div class="flex items-center justify-between border-b border-zinc-200 pb-2">
                <span class="text-[11px] text-zinc-400 font-num">REF: OFFICIAL-RECEIPT-VOUCHER</span>
                <div class="flex items-center gap-2">
                    <button onclick="window.print()" class="px-3 py-1 bg-zinc-900 text-white rounded text-xs font-semibold hover:bg-zinc-800 flex items-center gap-1 transition-colors">
                        <i class="fa-solid fa-print text-[10px]"></i>
                        <span>طباعة السند الرسمي</span>
                    </button>
                    <button @click="receiptModalOpen = false" class="text-zinc-400 hover:text-zinc-700 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
                </div>
            </div>

            <!-- Receipt Voucher Paper Body -->
            <template x-if="selectedReceipt">
                <div class="border-2 border-zinc-800 p-5 rounded-md space-y-4 bg-zinc-50/50">
                    
                    <!-- Header -->
                    <div class="flex items-start justify-between border-b-2 border-zinc-800 pb-3">
                        <div class="space-y-0.5">
                            <h3 class="font-bold text-sm text-zinc-900">مـنـظـمـة أَثَـــــــر لـلإغـاثـة والـتـنـمـيـة</h3>
                            <p class="text-[10px] text-zinc-500">رخصة إشهار رقم: SY-ATHAR-2026 • وزارة الشؤون الاجتماعية</p>
                            <p class="text-[10px] text-emerald-800 font-semibold font-num">سند استلام وتبرع مالي إلكتروني رسمي</p>
                        </div>
                        <div class="text-left font-num text-[11px] space-y-0.5 text-zinc-600">
                            <div>رقم السند: <strong class="text-zinc-900" x-text="selectedReceipt.ref"></strong></div>
                            <div>التاريخ: <span x-text="selectedReceipt.created_at"></span></div>
                            <div class="text-[10px] text-emerald-700 font-semibold">حالة الإيداع: مقبوض ومودع</div>
                        </div>
                    </div>

                    <!-- Voucher Content Table -->
                    <div class="space-y-2.5 text-xs text-zinc-800">
                        <div class="flex items-center justify-between border-b border-zinc-200 pb-1.5">
                            <span class="text-zinc-500">وصلنا من المتبرع الكريم:</span>
                            <span class="font-bold text-zinc-900" x-text="selectedReceipt.donor_name"></span>
                        </div>

                        <div class="flex items-center justify-between border-b border-zinc-200 pb-1.5">
                            <span class="text-zinc-500">رقم الهاتف المسجل:</span>
                            <span class="font-num text-zinc-900" x-text="selectedReceipt.donor_phone"></span>
                        </div>

                        <div class="flex items-center justify-between border-b border-zinc-200 pb-1.5">
                            <span class="text-zinc-500">المبلغ المقبوض:</span>
                            <span class="font-bold text-sm font-num text-emerald-800" x-text="Number(selectedReceipt.amount).toLocaleString() + ' ' + selectedReceipt.currency"></span>
                        </div>

                        <div class="flex items-center justify-between border-b border-zinc-200 pb-1.5">
                            <span class="text-zinc-500">طريقة الدفع والقيد:</span>
                            <span class="font-medium text-zinc-800" x-text="selectedReceipt.payment_method === 'sham_cash' ? 'شام كاش (Sham Cash)' : (selectedReceipt.payment_method === 'syriatel_cash' ? 'سيريتل كاش (Syriatel Cash)' : (selectedReceipt.payment_method === 'in_kind' ? 'مساهمة عينية مسعرة' : 'إيداع نقدي بمقر الجمعية'))"></span>
                        </div>

                        <div class="flex items-center justify-between border-b border-zinc-200 pb-1.5">
                            <span class="text-zinc-500">تخصيص المساهمة:</span>
                            <span class="font-bold text-zinc-900" x-text="selectedReceipt.case_title"></span>
                        </div>
                    </div>

                    <!-- Seal & Signatures -->
                    <div class="pt-4 grid grid-cols-2 gap-4 text-center text-[10px] text-zinc-600 border-t border-zinc-300">
                        <div>
                            <span class="block mb-6">أمين الصندوق والتدقيق المالي</span>
                            <span class="font-semibold text-zinc-900 font-num">ATHAR-FINANCE-DESK</span>
                        </div>
                        <div class="flex flex-col items-center">
                            <div class="w-16 h-16 rounded-full border-2 border-dashed border-emerald-700/60 flex items-center justify-center text-emerald-800 font-bold text-[9px] rotate-[-12deg] select-none">
                                ختـم معتـمد<br>منظمة أَثَـر
                            </div>
                            <span class="mt-1 text-[9px] text-zinc-400">توثيق مالي رقمي معتمد</span>
                        </div>
                    </div>

                </div>
            </template>
        </div>
    </div>

    <!-- Modal: Record Office / Cash Donation -->
    <div x-show="donationModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="donationModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-3 max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">قيد تبرع نقدي مباشر / إيداع مكتبي</h4>
                <button @click="donationModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form action="{{ route('dashboard.donations.store') }}" method="POST" class="space-y-3 text-xs">
                @csrf
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">اسم المتبرع (أو فاعل خير)</label>
                    <input type="text" name="donor_name" required placeholder="مثال: فاعل خير / أحمد الحلبي" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">رقم الهاتف (اختياري)</label>
                        <input type="text" name="donor_phone" placeholder="09xxxxxxxx" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المبلغ المتبرع به (ل.س)</label>
                        <input type="number" name="amount" required min="1" placeholder="مثال: 500000" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">طريقة الدفع / القيد</label>
                        <select name="payment_method" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="manual">إيداع نقدي بمقر الجمعية</option>
                            <option value="sham_cash">شام كاش (Sham Cash)</option>
                            <option value="syriatel_cash">سيريتل كاش (Syriatel Cash)</option>
                            <option value="in_kind">مساهمة عينية مسعرة</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">تخصيص لحالة معتمدة</label>
                        <select name="case_id" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="">-- صندوق الإغاثة العام --</option>
                            @foreach($cases as $c)
                                <option value="{{ $c->id }}">#{{ $c->id }} • {{ $c->title }}</option>
                            @endforeach
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">ملاحظات ورقم إيصال الاستلام</label>
                    <input type="text" name="notes" placeholder="رقم السند الورقي أو ملاحظات المتبرع..." class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="donationModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 font-semibold shadow-sm transition-colors">تسجيل وسند التبرع</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
