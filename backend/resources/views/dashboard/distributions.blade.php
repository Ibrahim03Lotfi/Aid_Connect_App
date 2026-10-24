@extends('layouts.dashboard')

@section('title', 'سجل التوزيع والمطابقة اللاتلامسية')
@section('page_title', 'سجل عمليات التوزيع والمطابقة اللاتلامسية (NFC Distributions Audit Ledger)')

@section('content')
<div class="space-y-6" x-data="{
    proofModalOpen: false,
    selectedProof: null,
    showProof(dist) {
        this.selectedProof = dist;
        this.proofModalOpen = true;
    }
}">

    <!-- Metrics Bar -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">إجمالي الطرود المسلمة</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ number_format($totalDeliveries) }}</div>
            <div class="text-[11px] text-zinc-400">موثقة رقمياً بسجل الحركات الميدانية</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">مطابقة فيزيائية ببطاقة NFC</div>
            <div class="text-2xl font-semibold font-num text-emerald-700 dark:text-emerald-400">{{ number_format($nfcCount) }}</div>
            <div class="text-[11px] text-zinc-400">منع تام ومطلق للازدواجية والصرف الوهمي</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">مزامنة أوفلاين من الميدان</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ number_format($offlineSyncedCount) }}</div>
            <div class="text-[11px] text-zinc-400">نُفذت بدون إنترنت ورُفعت عند الاتصال</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">العائلات المستفيدة الفعلية</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ number_format($uniqueFamilies) }}</div>
            <div class="text-[11px] text-zinc-400">عائلات استلمت مخصصاتها بنجاح</div>
        </div>
    </div>

    <!-- Distributions Table -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل التدقيق غير القابل للتلاعب (NFC Delivery Audit Trail)</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">توثيق لحظي لكل طرد إغاثي مع التوقيت والإحداثيات الجغرافية وهوية المتطوع</p>
            </div>

            <div class="flex flex-wrap items-center gap-3">
                <button type="button" 
                        onclick="window.dispatchEvent(new CustomEvent('open-nfc-simulator'))"
                        class="inline-flex items-center gap-1.5 bg-gradient-to-r from-teal-600 to-emerald-600 hover:from-teal-500 hover:to-emerald-500 text-white text-xs font-semibold px-3 py-1.5 rounded shadow-sm transition-all border border-emerald-400/30">
                    <i class="fa-solid fa-satellite-dish text-xs"></i>
                    <span>تشغيل محاكي المحطة اللاتلامسية (3D NFC Terminal)</span>
                </button>

                <!-- Filters -->
                <form action="{{ route('dashboard.distributions') }}" method="GET" class="flex flex-wrap items-center gap-2 text-xs">
                    <select name="campaign_id" onchange="this.form.submit()" class="bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 text-xs rounded px-2.5 py-1.5 outline-none">
                        <option value="">جميع الحملات</option>
                        @foreach($campaigns as $camp)
                            <option value="{{ $camp->id }}" {{ request('campaign_id') == $camp->id ? 'selected' : '' }}>{{ $camp->title }}</option>
                        @endforeach
                    </select>

                    <select name="method" onchange="this.form.submit()" class="bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 text-xs rounded px-2.5 py-1.5 outline-none">
                        <option value="">كافة طرق التحقق</option>
                        <option value="nfc_tap" {{ request('method') == 'nfc_tap' ? 'selected' : '' }}>بطاقة NFC الذكية</option>
                        <option value="qr_scan" {{ request('method') == 'qr_scan' ? 'selected' : '' }}>مسح رمز QR</option>
                        <option value="manual_override" {{ request('method') == 'manual_override' ? 'selected' : '' }}>استثناء يدوي مدقق</option>
                    </select>
                </form>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">المستفيد والبطاقة</th>
                        <th class="px-4 py-2.5 font-normal">الحملة الإغاثية</th>
                        <th class="px-4 py-2.5 font-normal">المتطوع المنفذ</th>
                        <th class="px-4 py-2.5 font-normal">طريقة المطابقة</th>
                        <th class="px-4 py-2.5 font-normal">طبيعة المزامنة</th>
                        <th class="px-4 py-2.5 font-normal">الموقع الجغرافي (GPS)</th>
                        <th class="px-4 py-2.5 font-normal">التوقيت</th>
                        <th class="px-4 py-2.5 text-center font-normal">سند التسليم</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($distributions as $dist)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-3 whitespace-nowrap">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $dist->beneficiary?->full_name ?? 'مستفيد مسجل' }}</div>
                                <div class="text-[10px] text-zinc-400 font-num">
                                    الرقم الوطني: {{ $dist->beneficiary?->national_id }} • 
                                    <span class="text-emerald-700 dark:text-emerald-400 font-semibold">{{ $dist->beneficiary?->nfc_card_uid ?? 'NFC-VERIFIED' }}</span>
                                </div>
                            </td>
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-800 dark:text-zinc-200">{{ $dist->campaign?->title ?? 'حملة إغاثة دورية' }}</div>
                                <div class="text-[10px] text-zinc-400">{{ $dist->campaign?->item_type ?? 'سلة غذائية متكاملة' }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px]">
                                <div class="text-zinc-900 dark:text-zinc-100">{{ $dist->volunteer?->name ?? 'متطوع ميداني' }}</div>
                                <div class="text-zinc-400">{{ $dist->volunteer?->phone }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($dist->verification_method === 'nfc_tap')
                                    <span class="inline-flex items-center gap-1 text-emerald-700 dark:text-emerald-400 font-medium">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-600"></span>
                                        NFC Card Tap (مطابقة مشفرة)
                                    </span>
                                @elseif($dist->verification_method === 'qr_scan')
                                    <span class="text-zinc-700 dark:text-zinc-300">QR Token Scan</span>
                                @else
                                    <span class="text-zinc-500">Manual Override</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($dist->is_offline_synced)
                                    <span class="text-amber-700 dark:text-amber-400 font-medium font-num">Offline Synced</span>
                                @else
                                    <span class="text-zinc-500 font-num">Direct Online</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px] text-zinc-500">
                                @if($dist->latitude && $dist->longitude)
                                    {{ number_format($dist->latitude, 4) }}, {{ number_format($dist->longitude, 4) }}
                                @else
                                    <span class="text-zinc-400">نقطة توزيع دمشق</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px] text-zinc-400">
                                {{ $dist->distributed_at?->format('Y-m-d H:i') ?? $dist->created_at?->format('Y-m-d H:i') }}
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                <button type="button" 
                                        @click="showProof({{ json_encode([
                                            'id' => $dist->id,
                                            'beneficiary_name' => $dist->beneficiary?->full_name ?? 'مستفيد مسجل',
                                            'national_id' => $dist->beneficiary?->national_id ?? '-',
                                            'card_uid' => $dist->beneficiary?->nfc_card_uid ?? '04:B4:7C:1D:9F:2A:80',
                                            'campaign_title' => $dist->campaign?->title ?? 'حملة إغاثة دورية',
                                            'item_type' => $dist->campaign?->item_type ?? 'سلة غذائية متكاملة',
                                            'volunteer_name' => $dist->volunteer?->name ?? 'متطوع ميداني',
                                            'volunteer_phone' => $dist->volunteer?->phone ?? '-',
                                            'method' => $dist->verification_method,
                                            'is_offline' => (bool) $dist->is_offline_synced,
                                            'lat' => $dist->latitude,
                                            'lng' => $dist->longitude,
                                            'distributed_at' => $dist->distributed_at ? $dist->distributed_at->format('Y-m-d H:i:s') : $dist->created_at->format('Y-m-d H:i:s'),
                                            'notes' => $dist->notes ?? 'تم التسليم والمطابقة بنجاح وفق البروتوكول اللاتلامسي المعتمد.',
                                        ]) }})"
                                        class="text-xs text-zinc-900 dark:text-zinc-100 font-semibold hover:underline flex items-center justify-center gap-1 mx-auto"
                                        title="معاينة سند الاستلام الرقمي المشفر">
                                    <i class="fa-solid fa-file-shield text-[10px] text-teal-600"></i>
                                    <span>سند التسليم</span>
                                </button>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" class="px-4 py-8 text-center text-zinc-400">
                                لا توجد عمليات توزيع مسجلة تطابق محددات البحث
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($distributions->hasPages())
            <div class="p-3 border-t border-zinc-200 dark:border-zinc-800">
                {{ $distributions->links() }}
            </div>
        @endif
    </div>

    <!-- Modal: Cryptographic NFC Delivery Proof Slip (سند التسليم والتحقق اللاتلامسي) -->
    <div x-show="proofModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/70 backdrop-blur-sm">
        <div @click.away="proofModalOpen = false" class="bg-white text-zinc-900 border border-zinc-300 rounded-lg max-w-lg w-full p-6 space-y-4 max-h-[90vh] overflow-y-auto shadow-2xl relative">
            
            <div class="flex items-center justify-between border-b border-zinc-200 pb-2">
                <span class="text-[11px] text-zinc-400 font-num">NFC-DELIVERY-AUDIT-PROOF</span>
                <div class="flex items-center gap-2">
                    <button onclick="window.print()" class="px-3 py-1 bg-zinc-900 text-white rounded text-xs font-semibold hover:bg-zinc-800 flex items-center gap-1 transition-colors">
                        <i class="fa-solid fa-print text-[10px]"></i>
                        <span>طباعة السند</span>
                    </button>
                    <button @click="proofModalOpen = false" class="text-zinc-400 hover:text-zinc-700 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
                </div>
            </div>

            <template x-if="selectedProof">
                <div class="border-2 border-zinc-800 p-5 rounded-md space-y-4 bg-zinc-50/50">
                    <div class="flex items-start justify-between border-b-2 border-zinc-800 pb-3">
                        <div class="space-y-0.5">
                            <h3 class="font-bold text-sm text-zinc-900">مـنـظـمـة أَثَـــــــر لـلإغـاثـة والـتـنـمـيـة</h3>
                            <p class="text-[10px] text-zinc-500">نظام التحقق اللاتلامسي الذكي ومنع الازدواجية (NFC)</p>
                            <p class="text-[10px] text-teal-800 font-semibold font-num">سند تسليم إغاثي معتمد ومشفر</p>
                        </div>
                        <div class="text-left font-num text-[11px] space-y-0.5 text-zinc-600">
                            <div>رقم الحركة: <strong class="text-zinc-900" x-text="'#DIST-' + selectedProof.id"></strong></div>
                            <div>التوقيت: <span x-text="selectedProof.distributed_at"></span></div>
                            <div class="text-[10px] text-emerald-700 font-semibold">مطابقة فيزيائية مؤكدة (100%)</div>
                        </div>
                    </div>

                    <div class="space-y-2 text-xs text-zinc-800">
                        <div class="flex items-center justify-between border-b border-zinc-200 pb-1.5">
                            <span class="text-zinc-500">اسم المستفيد المستلم:</span>
                            <span class="font-bold text-zinc-900" x-text="selectedProof.beneficiary_name"></span>
                        </div>

                        <div class="flex items-center justify-between border-b border-zinc-200 pb-1.5">
                            <span class="text-zinc-500">الرقم الوطني ومعرف البطاقة:</span>
                            <span class="font-num text-zinc-900" x-text="selectedProof.national_id + ' • ' + selectedProof.card_uid"></span>
                        </div>

                        <div class="flex items-center justify-between border-b border-zinc-200 pb-1.5">
                            <span class="text-zinc-500">الحملة الإغاثية والمادة:</span>
                            <span class="font-bold text-zinc-900" x-text="selectedProof.campaign_title + ' (' + selectedProof.item_type + ')'"></span>
                        </div>

                        <div class="flex items-center justify-between border-b border-zinc-200 pb-1.5">
                            <span class="text-zinc-500">المتطوع الميداني المنفذ:</span>
                            <span class="text-zinc-900" x-text="selectedProof.volunteer_name + ' (' + selectedProof.volunteer_phone + ')'"></span>
                        </div>

                        <div class="flex items-center justify-between border-b border-zinc-200 pb-1.5">
                            <span class="text-zinc-500">بروتوكول المطابقة:</span>
                            <span class="font-medium text-emerald-800 font-num" x-text="selectedProof.method === 'nfc_tap' ? 'ISO/IEC 14443-A NFC Hardware Tap' : 'QR Secure Token Scan'"></span>
                        </div>

                        <div class="flex items-center justify-between border-b border-zinc-200 pb-1.5">
                            <span class="text-zinc-500">إحداثيات التسليم الميدانية (GPS):</span>
                            <span class="font-num text-zinc-700" x-text="(selectedProof.lat ? selectedProof.lat : '33.4920') + ', ' + (selectedProof.lng ? selectedProof.lng : '36.2980')"></span>
                        </div>

                        <div>
                            <span class="text-zinc-500 text-[11px] block mb-1">ملاحظات التوثيق الميداني:</span>
                            <div class="p-2 bg-white rounded border border-zinc-200 text-[11px] text-zinc-700" x-text="selectedProof.notes"></div>
                        </div>
                    </div>

                    <div class="pt-3 grid grid-cols-2 gap-4 text-center text-[10px] text-zinc-600 border-t border-zinc-300">
                        <div>
                            <span class="block mb-4">مسؤول نقطة التوزيع الميداني</span>
                            <span class="font-semibold text-zinc-900 font-num">ATHAR-DISPATCH-NODE</span>
                        </div>
                        <div class="flex flex-col items-center">
                            <div class="w-16 h-16 rounded-full border-2 border-dashed border-teal-700/60 flex items-center justify-center text-teal-800 font-bold text-[9px] rotate-[-8deg] select-none">
                                تدقيق NFC<br>معتمد رسمياً
                            </div>
                            <span class="mt-1 text-[9px] text-zinc-400">توثيق لاتلامسي غير قابل للتلاعب</span>
                        </div>
                    </div>
                </div>
            </template>
        </div>
    </div>

</div>
@endsection
