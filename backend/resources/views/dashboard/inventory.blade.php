@extends('layouts.dashboard')

@section('title', 'نظام اللوجستيات والمستودعات الإغاثية')
@section('page_title', 'المستودعات واللوجستيات الإغاثية (Logistics & Inventory)')

@section('content')
<div class="space-y-6" x-data="{ 
    addStockModal: false,
    addWarehouseModal: false,
    editWarehouseModal: false,
    editingWarehouse: {},
    addItemModal: false,
    editItemModal: false,
    editingItem: {},
    modalGov: '',
    modalDistrict: '',
    currentGovPlaces: [],
    modalLat: '',
    modalLng: '',
    syrianPlaces: {
        'دمشق': [
            { name: 'الميدان', lat: 33.4920, lng: 36.2980 },
            { name: 'المزة', lat: 33.5042, lng: 36.2514 },
            { name: 'كفرسوسة', lat: 33.4950, lng: 36.2750 },
            { name: 'برزة', lat: 33.5510, lng: 36.3150 },
            { name: 'القصاع وباب توما', lat: 33.5180, lng: 36.3180 },
            { name: 'القنوات وباب سريجة', lat: 33.5080, lng: 36.2920 },
            { name: 'ركن الدين', lat: 33.5350, lng: 36.2950 },
            { name: 'دمر والربوة', lat: 33.5320, lng: 36.2350 },
            { name: 'الشاغور', lat: 33.5010, lng: 36.3080 }
        ],
        'ريف دمشق': [
            { name: 'صحنايا', lat: 33.4350, lng: 36.2300 },
            { name: 'جرمانا', lat: 33.4850, lng: 36.3500 },
            { name: 'دوما', lat: 33.5710, lng: 36.4020 },
            { name: 'داريا', lat: 33.4580, lng: 36.2380 },
            { name: 'قدسيا', lat: 33.5420, lng: 36.2190 },
            { name: 'التل', lat: 33.6050, lng: 36.3120 },
            { name: 'الكسوة', lat: 33.3580, lng: 36.2390 },
            { name: 'يبرود', lat: 33.9680, lng: 36.6570 },
            { name: 'النبك', lat: 34.0250, lng: 36.7280 }
        ],
        'حلب': [
            { name: 'الشهباء والجميلية', lat: 36.2150, lng: 37.1500 },
            { name: 'السليمانية والعزيزية', lat: 36.2180, lng: 37.1620 },
            { name: 'السكري', lat: 36.1750, lng: 37.1350 },
            { name: 'صلاح الدين', lat: 36.1820, lng: 37.1240 },
            { name: 'حلب الجديدة', lat: 36.2100, lng: 37.1050 },
            { name: 'الأشرفية', lat: 36.2280, lng: 37.1380 },
            { name: 'عفرين', lat: 36.5120, lng: 36.8680 },
            { name: 'منبج', lat: 36.5280, lng: 37.9550 }
        ],
        'حمص': [
            { name: 'الوعر', lat: 34.7450, lng: 36.6800 },
            { name: 'الخالدية', lat: 34.7420, lng: 36.7180 },
            { name: 'الدبلان والإنشاءات', lat: 34.7280, lng: 36.7020 },
            { name: 'وادي الذهب والزهراء', lat: 34.7150, lng: 36.7320 },
            { name: 'تدمر', lat: 34.5600, lng: 38.2800 },
            { name: 'الرستن', lat: 34.9280, lng: 36.7320 },
            { name: 'القصير', lat: 34.5080, lng: 36.5800 }
        ],
        'حماة': [
            { name: 'الحاضر والدباغة', lat: 35.1380, lng: 36.7550 },
            { name: 'الصابونية والمرابط', lat: 35.1250, lng: 36.7450 },
            { name: 'القصور والبرناوي', lat: 35.1480, lng: 36.7420 },
            { name: 'سلمية', lat: 35.0120, lng: 37.0520 },
            { name: 'مصياف', lat: 35.0650, lng: 36.3420 },
            { name: 'محردة', lat: 35.2520, lng: 36.5780 }
        ],
        'اللاذقية': [
            { name: 'الشيخ ضاهر والصليبة', lat: 35.5210, lng: 35.7820 },
            { name: 'الزراعة والكاملية', lat: 35.5350, lng: 35.8010 },
            { name: 'الرمل الشمالي والكورنيش', lat: 35.5450, lng: 35.7720 },
            { name: 'جبلة', lat: 35.3620, lng: 35.9280 },
            { name: 'القرداحة', lat: 35.4580, lng: 36.0620 },
            { name: 'كسب', lat: 35.9250, lng: 35.9850 }
        ],
        'طرطوس': [
            { name: 'الميناء والكورنيش البحري', lat: 34.8890, lng: 35.8750 },
            { name: 'المشبكة ورأس الشغري', lat: 34.8980, lng: 35.8920 },
            { name: 'بانياس', lat: 35.1820, lng: 35.9450 },
            { name: 'صافيتا', lat: 34.8210, lng: 36.1180 },
            { name: 'دريكيش', lat: 34.9020, lng: 36.1420 },
            { name: 'مشتى الحلو', lat: 34.8850, lng: 36.2480 }
        ],
        'درعا': [
            { name: 'درعا البلد والمحطة', lat: 32.6255, lng: 36.1054 },
            { name: 'الصنمين', lat: 33.0680, lng: 36.1820 },
            { name: 'إزرع', lat: 32.8720, lng: 36.2510 },
            { name: 'نوى', lat: 32.8920, lng: 36.0420 },
            { name: 'بصرى الشام', lat: 32.5180, lng: 36.4820 }
        ],
        'السويداء': [
            { name: 'المدينة المركز', lat: 32.7089, lng: 36.5695 },
            { name: 'شهبا', lat: 32.8550, lng: 36.6280 },
            { name: 'صلخد', lat: 32.4920, lng: 36.7120 },
            { name: 'القريا', lat: 32.5520, lng: 36.5920 }
        ],
        'دير الزور': [
            { name: 'الجورة والقصور', lat: 35.3359, lng: 40.1408 },
            { name: 'الميادين', lat: 35.0180, lng: 40.4520 },
            { name: 'البوكمال', lat: 34.4520, lng: 40.9180 }
        ],
        'الحسكة': [
            { name: 'المدينة المركز', lat: 36.5023, lng: 40.7483 },
            { name: 'القامشلي', lat: 36.8350, lng: 41.2280 },
            { name: 'عامودا', lat: 37.0850, lng: 40.9180 },
            { name: 'المالكية (ديريك)', lat: 37.1750, lng: 42.1380 }
        ],
        'الرقة': [
            { name: 'الرقة المركز', lat: 35.9594, lng: 39.0089 },
            { name: 'الطبقة (الثورة)', lat: 35.8350, lng: 38.5480 },
            { name: 'تل أبيض', lat: 36.6980, lng: 38.9550 }
        ],
        'إدلب': [
            { name: 'إدلب المدينة', lat: 35.9306, lng: 36.6339 },
            { name: 'معرة النعمان', lat: 35.6480, lng: 36.6780 },
            { name: 'أريحا', lat: 35.8120, lng: 36.6120 },
            { name: 'جسر الشغور', lat: 35.8150, lng: 36.3220 },
            { name: 'سرمدا والدانا', lat: 36.1850, lng: 36.7150 }
        ],
        'القنيطرة': [
            { name: 'خان أرنبة والبعث', lat: 33.1780, lng: 35.8750 },
            { name: 'القنيطرة المركز', lat: 33.1259, lng: 35.8246 }
        ]
    },
    openAddWarehouse() {
        this.addWarehouseModal = true;
        this.modalGov = '';
        this.modalDistrict = '';
        this.currentGovPlaces = [];
        this.modalLat = '';
        this.modalLng = '';
    },
    openEditWarehouse(wh) {
        this.editingWarehouse = { ...wh };
        this.editWarehouseModal = true;
    },
    openEditItem(item) {
        this.editingItem = { ...item };
        this.editItemModal = true;
    },
    onModalGovChange() {
        if (this.modalGov && this.syrianPlaces[this.modalGov]) {
            this.currentGovPlaces = this.syrianPlaces[this.modalGov];
            if (this.currentGovPlaces.length > 0) {
                this.modalDistrict = this.currentGovPlaces[0].name;
                this.modalLat = this.currentGovPlaces[0].lat;
                this.modalLng = this.currentGovPlaces[0].lng;
            }
        } else {
            this.currentGovPlaces = [];
            this.modalDistrict = '';
            this.modalLat = '';
            this.modalLng = '';
        }
    },
    onModalDistrictChange() {
        const place = this.currentGovPlaces.find(p => p.name === this.modalDistrict);
        if (place) {
            this.modalLat = place.lat;
            this.modalLng = place.lng;
        }
    }
}">

    <!-- Stock Metrics Bar (Sober Enterprise Metrics) -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        
        <!-- Total Stock -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">إجمالي الطرود في المستودعات</div>
            <div class="text-2xl sm:text-3xl font-semibold font-num text-zinc-900 dark:text-zinc-100 tracking-tight">
                {{ number_format($totalStockUnits) }}
            </div>
            <div class="text-[11px] text-zinc-400">رصيد المخزون الكلي المسجل</div>
        </div>

        <!-- Available Free Stock -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">الرصيد الحر المتاح للصرف</div>
            <div class="text-2xl sm:text-3xl font-semibold font-num text-zinc-900 dark:text-zinc-100 tracking-tight">
                {{ number_format($availableUnits) }}
            </div>
            <div class="text-[11px] text-zinc-400">جاهز للتسليم الميداني</div>
        </div>

        <!-- Reserved Stock -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">الكميات المحجوزة للحملات</div>
            <div class="text-2xl sm:text-3xl font-semibold font-num text-zinc-900 dark:text-zinc-100 tracking-tight">
                {{ number_format($reservedUnits) }}
            </div>
            <div class="text-[11px] text-zinc-400">مخصصة لقوافل اليوم</div>
        </div>

        <!-- Low Stock Warning -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">مواد اقتربت من حد الأمان</div>
            <div class="text-2xl sm:text-3xl font-semibold font-num text-zinc-900 dark:text-zinc-100 tracking-tight">
                {{ $lowStockCount }}
            </div>
            <div class="text-[11px] text-zinc-400">تتطلب إعادة توريد</div>
        </div>
    </div>

    <!-- 1. Regional Warehouses Management (إدارة المستودعات ومراكز التوزيع) -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">مراكز ومستودعات التوزيع الإقليمية (Regional Warehouses Hub)</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">المستودعات المسجلة رسمياً والمرتبطة بنظام الخرائط الجغرافية GIS</p>
            </div>
            <div class="flex items-center gap-2">
                <button type="button" @click="openAddWarehouse()" class="px-3 py-1.5 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 text-xs font-semibold shadow-sm flex items-center gap-1.5 transition-colors">
                    <i class="fa-solid fa-plus text-[10px]"></i>
                    <span>إضافة مستودع جديد</span>
                </button>
                <a href="{{ route('dashboard.gis') }}" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-700 dark:text-zinc-300 text-xs hover:bg-zinc-50 dark:hover:bg-zinc-800 flex items-center gap-1">
                    <i class="fa-solid fa-map-location-dot text-[10px]"></i>
                    <span>عرض على خريطة GIS</span>
                </a>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">اسم المستودع</th>
                        <th class="px-4 py-2.5 font-normal">المحافظة والمنطقة</th>
                        <th class="px-4 py-2.5 font-normal">الإحداثيات الجغرافية</th>
                        <th class="px-4 py-2.5 font-normal">الطاقة الاستيعابية</th>
                        <th class="px-4 py-2.5 font-normal">المشرف وهاتف التواصل</th>
                        <th class="px-4 py-2.5 text-center font-normal">إجراء</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($warehouses as $wh)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $wh->name }}</div>
                                <div class="text-[10px] text-zinc-400">{{ $wh->address ?? 'مركز تخزين وتوزيع معتمد' }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap">
                                <span class="font-medium text-zinc-800 dark:text-zinc-200">{{ $wh->governorate }}</span>
                                @if($wh->district)
                                    <span class="text-[10px] text-zinc-400 block">• {{ $wh->district }}</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px] text-zinc-500">
                                <div>Lat: {{ number_format($wh->latitude, 4) }}</div>
                                <div>Lng: {{ number_format($wh->longitude, 4) }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap">
                                <span class="bg-zinc-100 dark:bg-zinc-800 px-2 py-0.5 rounded text-[11px] font-medium text-zinc-900 dark:text-zinc-100">
                                    {{ $wh->stock_capacity }}
                                </span>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                <div>{{ $wh->manager_name ?? 'غير محدد' }}</div>
                                <div class="font-num text-zinc-400">{{ $wh->phone ?? '—' }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                <div class="flex items-center justify-center gap-2">
                                    <button type="button" @click="openEditWarehouse({{ json_encode($wh) }})" class="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 text-xs hover:underline">
                                        تعديل
                                    </button>
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    <form action="{{ route('dashboard.warehouses.destroy', $wh->id) }}" method="POST" onsubmit="return confirm('تأكيد حذف هذا المستودع من المنظومة والخريطة؟');" class="inline">
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
                            <td colspan="6" class="px-4 py-8 text-center text-zinc-400">
                                لم يتم تسجيل أي مستودعات بعد. يمكنك الضغط على زر "إضافة مستودع جديد" واختيار المحافظة والمنطقة ليظهر فوراً على الخريطة.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- 2. Inventory Stock Items Table -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">أرصدة المواد الإغاثية ومواقع التخزين</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">NFC Real-time Decrement & Inflow Control</p>
            </div>
            <div class="flex items-center gap-2">
                <button @click="addItemModal = true" class="px-3 py-1.5 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 text-xs font-semibold shadow-sm flex items-center gap-1.5 transition-colors">
                    <i class="fa-solid fa-plus text-[10px]"></i>
                    <span>إضافة مادة إغاثية جديدة</span>
                </button>
                <button @click="addStockModal = true" class="px-3 py-1.5 rounded-md border border-zinc-200 dark:border-zinc-700 hover:border-teal-400 hover:text-teal-700 dark:hover:text-teal-300 text-zinc-700 dark:text-zinc-300 text-xs font-medium flex items-center gap-1.5 transition-colors bg-white dark:bg-zinc-800">
                    <i class="fa-solid fa-arrow-down-to-bracket text-[10px]"></i>
                    <span>تسجيل شحنة توريد (+IN)</span>
                </button>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">رمز المادة والاسم</th>
                        <th class="px-4 py-2.5 font-normal">المستودع والموقع</th>
                        <th class="px-4 py-2.5 font-normal">إجمالي المخزون</th>
                        <th class="px-4 py-2.5 font-normal">المتاح للتوزيع</th>
                        <th class="px-4 py-2.5 font-normal">المحجوز</th>
                        <th class="px-4 py-2.5 font-normal">حد الأمان</th>
                        <th class="px-4 py-2.5 text-center font-normal">الحالة</th>
                        <th class="px-4 py-2.5 text-center font-normal">إجراء</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($items as $item)
                        @php
                            $isLow = $item->available_stock <= $item->minimum_threshold;
                        @endphp
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            
                            <!-- Item Code & Name -->
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100 text-xs">{{ $item->name }}</div>
                                <div class="font-num text-zinc-400 text-[11px]">{{ $item->code }} • {{ $item->unit }}</div>
                            </td>

                            <!-- Warehouse -->
                            <td class="px-4 py-3 whitespace-nowrap">
                                <div class="text-zinc-800 dark:text-zinc-200">{{ $item->warehouse_location ?? 'مستودع الميدان' }}</div>
                                <div class="text-zinc-400 text-[10px]">{{ $item->category?->name ?? 'مواد عامة' }}</div>
                            </td>

                            <!-- Total Stock -->
                            <td class="px-4 py-3 whitespace-nowrap font-num text-zinc-700 dark:text-zinc-300">
                                {{ number_format($item->total_stock) }} {{ $item->unit }}
                            </td>

                            <!-- Available Stock -->
                            <td class="px-4 py-3 whitespace-nowrap font-num font-medium text-zinc-900 dark:text-zinc-100">
                                {{ number_format($item->available_stock) }} {{ $item->unit }}
                            </td>

                            <!-- Reserved -->
                            <td class="px-4 py-3 whitespace-nowrap font-num text-zinc-500">
                                {{ number_format($item->reserved_stock) }} {{ $item->unit }}
                            </td>

                            <!-- Min Threshold -->
                            <td class="px-4 py-3 whitespace-nowrap font-num text-zinc-400">
                                {{ number_format($item->minimum_threshold) }} {{ $item->unit }}
                            </td>

                            <!-- Status -->
                            <td class="px-4 py-3 whitespace-nowrap text-center text-[11px]">
                                @if($isLow)
                                    <span class="text-rose-600 dark:text-rose-400 font-medium">تحت حد الأمان</span>
                                @else
                                    <span class="text-zinc-500">مستقر</span>
                                @endif
                            </td>

                            <!-- Actions -->
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                <div class="flex items-center justify-center gap-2">
                                    <button type="button" @click="openEditItem({{ json_encode($item) }})" class="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 text-xs hover:underline">
                                        تعديل
                                    </button>
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    <form action="{{ route('dashboard.inventory.items.destroy', $item->id) }}" method="POST" onsubmit="return confirm('تأكيد حذف هذه المادة الإغاثية وسجلاتها؟');" class="inline">
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
                            <td colspan="8" class="px-4 py-8 text-center text-zinc-400">
                                لا توجد مواد مسجلة في المستودعات حالياً
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- 3. Real-time Inventory Audit Ledger (سجل حركات المخزون والتدقيق الميداني) -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل حركات المخزون والتدقيق الميداني (Inventory Transaction Ledger)</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">توثيق تلقائي لحركات الإدخال (+IN) والصرف العيني المرتبط ببطاقات NFC (-OUT)</p>
            </div>
            <span class="text-[11px] text-zinc-400 font-num">Tamper-Proof Audit Log</span>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">المادة الإغاثية</th>
                        <th class="px-4 py-2.5 font-normal">نوع الحركة</th>
                        <th class="px-4 py-2.5 font-normal">الكمية</th>
                        <th class="px-4 py-2.5 font-normal">المنفذ / المسؤول</th>
                        <th class="px-4 py-2.5 font-normal">الملاحظات والمرجع</th>
                        <th class="px-4 py-2.5 text-center font-normal">التوقيت</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($transactions as $tx)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-2.5">
                                <span class="font-medium text-zinc-900 dark:text-zinc-100">{{ $tx->item?->name ?? 'مادة محذوفة' }}</span>
                                <span class="block text-[10px] text-zinc-400 font-num">{{ $tx->item?->code }}</span>
                            </td>
                            <td class="px-4 py-2.5 whitespace-nowrap text-[11px]">
                                @if($tx->type === 'inbound')
                                    <span class="text-emerald-700 dark:text-emerald-400 font-medium">توريد (+IN)</span>
                                @elseif($tx->type === 'outbound')
                                    <span class="text-rose-600 dark:text-rose-400 font-medium">صرف ميداني (-OUT)</span>
                                @else
                                    <span class="text-zinc-500">نقل مخزني</span>
                                @endif
                            </td>
                            <td class="px-4 py-2.5 whitespace-nowrap font-num font-semibold text-zinc-900 dark:text-zinc-100">
                                {{ $tx->type === 'inbound' ? '+' : '-' }}{{ number_format($tx->quantity) }}
                            </td>
                            <td class="px-4 py-2.5 whitespace-nowrap text-zinc-600 dark:text-zinc-400">
                                {{ $tx->performer?->name ?? 'مسؤول المستودع' }}
                            </td>
                            <td class="px-4 py-2.5 text-zinc-500">
                                {{ $tx->notes ?? 'حركة موثقة رسمياً' }}
                            </td>
                            <td class="px-4 py-2.5 whitespace-nowrap text-center font-num text-[11px] text-zinc-400">
                                {{ $tx->created_at ? $tx->created_at->format('Y-m-d H:i') : '-' }}
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-4 py-6 text-center text-zinc-400">
                                لا توجد حركات مخزنية مسجلة حتى الآن
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Modal 1: Add Stock Intake Modal -->
    <div x-show="addStockModal" x-cloak class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div x-show="addStockModal" @click="addStockModal = false" class="fixed inset-0 bg-zinc-950/60 backdrop-blur-xs transition-opacity"></div>
            <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

            <div class="inline-block align-bottom bg-white dark:bg-zinc-900 rounded-lg text-right overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full border border-zinc-200 dark:border-zinc-800">
                <form action="{{ route('dashboard.inventory.add-stock') }}" method="POST">
                    @csrf
                    <div class="p-6 space-y-4">
                        <div class="flex items-center justify-between border-b border-zinc-200 dark:border-zinc-800 pb-3">
                            <h3 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100">تسجيل شحنة توريد مخزني (+IN)</h3>
                            <button type="button" @click="addStockModal = false" class="text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 text-xs">
                                <i class="fa-solid fa-xmark"></i>
                            </button>
                        </div>

                        <div>
                            <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">المادة الإغاثية المراد توريدها</label>
                            <select name="item_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 outline-none">
                                <option value="">-- اختر المادة من المستودع --</option>
                                @foreach($items as $itm)
                                    <option value="{{ $itm->id }}">{{ $itm->name }} ({{ $itm->code }}) - المتاح: {{ $itm->available_stock }} {{ $itm->unit }}</option>
                                @endforeach
                            </select>
                        </div>

                        <div class="grid grid-cols-2 gap-3">
                            <div>
                                <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">الكمية الواردة</label>
                                <input type="number" name="quantity" min="1" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 font-num outline-none" placeholder="100">
                            </div>

                            <div>
                                <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">مصدر الشحنة / المرجع</label>
                                <input type="text" name="notes" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 outline-none" placeholder="مثال: منحة الهلال الأحمر">
                            </div>
                        </div>

                        <div class="p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded border border-zinc-100 dark:border-zinc-800 text-[11px] text-zinc-500">
                            سيتم قيد الكمية فوراً في الرصيد الكلي والرصيد الحر المتاح للتسليم، وتدوين حركة إدخال رسمية في سجل التدقيق غير القابل للتعديل.
                        </div>
                    </div>

                    <div class="bg-zinc-50 dark:bg-zinc-800/60 px-6 py-3 border-t border-zinc-200 dark:border-zinc-800 flex items-center justify-end gap-2">
                        <button type="button" @click="addStockModal = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-xs text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800">
                            إلغاء
                        </button>
                        <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-xs font-medium hover:bg-zinc-800 dark:hover:bg-white">
                            تأكيد التوريد المخزني
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal 2: Add Warehouse Modal (إضافة مستودع جديد) -->
    <div x-show="addWarehouseModal" x-cloak class="fixed inset-0 z-[9999] flex items-center justify-center p-4 bg-zinc-950/70 backdrop-blur-sm">
        <div @click.away="addWarehouseModal = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-4 max-h-[90vh] overflow-y-auto shadow-2xl relative">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">إضافة مركز توزيع / مستودع إغاثي جديد</h4>
                <button @click="addWarehouseModal = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form action="{{ route('dashboard.warehouses.store') }}" method="POST" class="space-y-3 text-xs">
                @csrf
                
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">اسم المستودع أو مركز التوزيع</label>
                    <input type="text" name="name" required placeholder="مثال: مستودع الميدان الإغاثي المركزي" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <!-- Choose Governorate -->
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المحافظة السورية</label>
                        <select name="governorate" x-model="modalGov" @change="onModalGovChange()" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="">اختر المحافظة...</option>
                            <template x-for="gov in Object.keys(syrianPlaces)" :key="gov">
                                <option :value="gov" x-text="gov"></option>
                            </template>
                        </select>
                    </div>

                    <!-- Choose District / Place in that Governorate -->
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المنطقة / الحي بالمحافظة</label>
                        <select name="district" x-model="modalDistrict" @change="onModalDistrictChange()" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="">اختر المنطقة أو الحي...</option>
                            <template x-for="place in currentGovPlaces" :key="place.name">
                                <option :value="place.name" x-text="place.name"></option>
                            </template>
                        </select>
                    </div>
                </div>

                <!-- Coordinates (Auto-filled based on place, or customized) -->
                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">خط العرض (Latitude)</label>
                        <input type="number" step="any" name="latitude" x-model="modalLat" required placeholder="33.4920" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">خط الطول (Longitude)</label>
                        <input type="number" step="any" name="longitude" x-model="modalLng" required placeholder="36.2980" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">الطاقة الاستيعابية / المخزون الأولي</label>
                        <input type="text" name="stock_capacity" placeholder="مثال: 500 طرد غذائي وطبي" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المسؤول عن المستودع</label>
                        <input type="text" name="manager_name" placeholder="اسم المشرف الميداني..." class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">رقم هاتف التواصل</label>
                    <input type="text" name="phone" placeholder="0944112233" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">العنوان التفصيلي</label>
                    <input type="text" name="address" placeholder="المدينة - الشارع - بالقرب من..." class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="addWarehouseModal = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-emerald-600 hover:bg-emerald-700 text-white font-medium">حفظ المستودع وإظهاره بالخريطة</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 3: Add New Inventory Item Modal -->
    <div x-show="addItemModal" x-cloak class="fixed inset-0 z-[9999] flex items-center justify-center p-4 bg-zinc-950/70 backdrop-blur-sm">
        <div @click.away="addItemModal = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-4 max-h-[90vh] overflow-y-auto shadow-2xl relative">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">إضافة مادة إغاثية جديدة إلى الكتالوج</h4>
                <button @click="addItemModal = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form action="{{ route('dashboard.inventory.items.store') }}" method="POST" class="space-y-3 text-xs">
                @csrf
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">اسم المادة الإغاثية</label>
                    <input type="text" name="name" required placeholder="مثال: سلة غذائية رمضانية متكاملة" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">رمز المادة (SKU / Code)</label>
                        <input type="text" name="code" required placeholder="مثال: FOOD-BSK-01" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num uppercase rounded p-2 outline-none">
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
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">وحدة القياس</label>
                        <input type="text" name="unit" required placeholder="طرد / سلة / كيس" value="طرد" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">الرصيد الافتتاحي</label>
                        <input type="number" name="total_stock" required min="0" value="0" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">حد الأمان الأدنى</label>
                        <input type="number" name="minimum_threshold" required min="0" value="20" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المستودع الرئيسي المخصص</label>
                    <select name="warehouse_location" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                        @foreach($warehouses as $wh)
                            <option value="{{ $wh->name }}">{{ $wh->name }} ({{ $wh->governorate }})</option>
                        @endforeach
                    </select>
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="addItemModal = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-emerald-600 hover:bg-emerald-700 text-white font-medium">حفظ المادة وتفعيلها</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 4: Edit Inventory Item Modal -->
    <div x-show="editItemModal" x-cloak class="fixed inset-0 z-[9999] flex items-center justify-center p-4 bg-zinc-950/70 backdrop-blur-sm">
        <div @click.away="editItemModal = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-4 max-h-[90vh] overflow-y-auto shadow-2xl relative">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">تعديل بيانات المادة الإغاثية</h4>
                <button @click="editItemModal = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form :action="'{{ url('dashboard/inventory/items') }}/' + editingItem.id" method="POST" class="space-y-3 text-xs">
                @csrf
                @method('PUT')
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">اسم المادة الإغاثية</label>
                    <input type="text" name="name" x-model="editingItem.name" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">القطاع / التصنيف</label>
                        <select name="category_id" x-model="editingItem.category_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            @foreach($categories as $cat)
                                <option value="{{ $cat->id }}">{{ $cat->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">وحدة القياس</label>
                        <input type="text" name="unit" x-model="editingItem.unit" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">حد الأمان الأدنى للتنبيه</label>
                        <input type="number" name="minimum_threshold" x-model="editingItem.minimum_threshold" required min="0" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المستودع الرئيسي المخصص</label>
                        <input type="text" name="warehouse_location" x-model="editingItem.warehouse_location" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="editItemModal = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">حفظ التعديلات</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 5: Edit Warehouse Modal -->
    <div x-show="editWarehouseModal" x-cloak class="fixed inset-0 z-[9999] flex items-center justify-center p-4 bg-zinc-950/70 backdrop-blur-sm">
        <div @click.away="editWarehouseModal = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-4 max-h-[90vh] overflow-y-auto shadow-2xl relative">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">تعديل بيانات المستودع / مركز التوزيع</h4>
                <button @click="editWarehouseModal = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form :action="'{{ url('dashboard/warehouses') }}/' + editingWarehouse.id" method="POST" class="space-y-3 text-xs">
                @csrf
                @method('PUT')
                
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">اسم المستودع أو مركز التوزيع</label>
                    <input type="text" name="name" x-model="editingWarehouse.name" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المحافظة السورية</label>
                        <input type="text" name="governorate" x-model="editingWarehouse.governorate" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المنطقة / الحي بالمحافظة</label>
                        <input type="text" name="district" x-model="editingWarehouse.district" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">خط العرض (Latitude)</label>
                        <input type="number" step="any" name="latitude" x-model="editingWarehouse.latitude" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">خط الطول (Longitude)</label>
                        <input type="number" step="any" name="longitude" x-model="editingWarehouse.longitude" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">الطاقة الاستيعابية / المخزون</label>
                        <input type="text" name="stock_capacity" x-model="editingWarehouse.stock_capacity" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المسؤول عن المستودع</label>
                        <input type="text" name="manager_name" x-model="editingWarehouse.manager_name" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">رقم هاتف التواصل</label>
                    <input type="text" name="phone" x-model="editingWarehouse.phone" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">العنوان التفصيلي</label>
                    <input type="text" name="address" x-model="editingWarehouse.address" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="editWarehouseModal = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">تحديث بيانات المستودع</button>
                </div>
            </form>
        </div>
    </div>

</div>
@endsection
