@extends('layouts.dashboard')

@section('title', 'الخريطة الميدانية التفاعلية المباشرة (GIS)')
@section('page_title', 'الخريطة الميدانية التفاعلية (GIS Operations Map)')

@section('styles')
<!-- Leaflet CSS -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
<style>
    #map { 
        height: calc(100vh - 170px); 
        min-height: 580px; 
        width: 100%; 
        border-radius: 0.5rem; 
    }
    .leaflet-popup-content-wrapper { 
        background: #ffffff; 
        color: #18181b; 
        border-radius: 0.5rem; 
        border: 1px solid #e4e4e7; 
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05); 
        font-family: 'IBM Plex Sans Arabic', sans-serif; 
        text-align: right; 
        padding: 4px;
    }
    .dark .leaflet-popup-content-wrapper {
        background: #18181b;
        color: #f4f4f5;
        border-color: #27272a;
    }
    .leaflet-popup-tip { 
        background: #ffffff; 
    }
    .dark .leaflet-popup-tip {
        background: #18181b;
    }
</style>
@endsection

@section('content')
<div class="space-y-4" x-data="gisApp()">

    <!-- GIS Control Bar (Sober, Minimalist) -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-3 flex flex-wrap items-center justify-between gap-3 text-xs">
        
        <!-- Layer Filter Toggles -->
        <div class="flex flex-wrap items-center gap-4 text-zinc-600 dark:text-zinc-300">
            <label class="flex items-center gap-1.5 cursor-pointer">
                <input type="checkbox" x-model="showCases" @change="renderMarkers()" class="rounded border-zinc-300 text-zinc-900 focus:ring-0">
                <span>طلبات الإغاثة (<span class="font-num" x-text="counts.cases">0</span>)</span>
            </label>

            <label class="flex items-center gap-1.5 cursor-pointer">
                <input type="checkbox" x-model="showVolunteers" @change="renderMarkers()" class="rounded border-zinc-300 text-zinc-900 focus:ring-0">
                <span>الفرق الميدانية (<span class="font-num" x-text="counts.volunteers">0</span>)</span>
            </label>

            <label class="flex items-center gap-1.5 cursor-pointer">
                <input type="checkbox" x-model="showWarehouses" @change="renderMarkers()" class="rounded border-zinc-300 text-zinc-900 focus:ring-0">
                <span>مستودعات التوزيع (<span class="font-num" x-text="counts.warehouses">0</span>)</span>
            </label>
        </div>

        <!-- Action Buttons: Add Warehouse, Governorate Filter & Reset -->
        <div class="flex flex-wrap items-center gap-2">
            <!-- Add Warehouse Button -->
            <button type="button" @click="openAddWarehouseModal()" class="bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 px-3 py-1.5 rounded-md text-xs font-semibold shadow-sm transition-colors flex items-center gap-1.5">
                <i class="fa-solid fa-plus text-[10px]"></i>
                <span>إضافة مستودع جديد</span>
            </button>

            <!-- Governorate Filter -->
            <select x-model="selectedGov" @change="filterByGov()" class="bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 text-xs rounded px-2.5 py-1.5 outline-none">
                <option value="">جميع المحافظات السورية</option>
                @foreach($governorates as $gov)
                    <option value="{{ $gov->name }}">{{ $gov->name }}</option>
                @endforeach
            </select>

            <button @click="resetMap()" class="bg-zinc-100 dark:bg-zinc-800 hover:bg-zinc-200 dark:hover:bg-zinc-700 text-zinc-700 dark:text-zinc-300 px-2.5 py-1.5 rounded text-xs transition-colors border border-zinc-200 dark:border-zinc-700">
                إعادة ضبط الخريطة
            </button>
        </div>
    </div>

    <!-- Map Canvas -->
    <div class="relative rounded-lg overflow-hidden border border-zinc-200 dark:border-zinc-800">
        <div id="map"></div>

        <!-- Minimalist GPS Status Overlay -->
        <div class="absolute bottom-4 right-4 z-[1000] bg-white/90 dark:bg-zinc-900/90 backdrop-blur border border-zinc-200 dark:border-zinc-800 px-3 py-2 rounded text-[11px] text-zinc-500 hidden sm:block">
            <span class="font-num font-medium text-zinc-800 dark:text-zinc-200">GPS Live Telemetry</span> • تحديث مستمر
        </div>
    </div>

    <!-- Modal: Add New Warehouse (إضافة مستودع جديد) -->
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
                    <button type="submit" class="px-4 py-1.5 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 font-semibold shadow-sm transition-colors">حفظ المستودع وإظهاره بالخريطة</button>
                </div>
            </form>
        </div>
    </div>

</div>
@endsection

@section('scripts')
<!-- Leaflet JS -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""></script>

<script>
// Dictionary of Syrian Governorates and their famous districts/places with coordinates
const syrianPlaces = {
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
};

// Map Centers for all 14 Syrian Governorates
const govCenterCoords = {
    'دمشق': { center: [33.5138, 36.2765], zoom: 12 },
    'ريف دمشق': { center: [33.5350, 36.3800], zoom: 11 },
    'حلب': { center: [36.2021, 37.1343], zoom: 12 },
    'حمص': { center: [34.7324, 36.7136], zoom: 12 },
    'حماة': { center: [35.1318, 36.7578], zoom: 12 },
    'اللاذقية': { center: [35.5317, 35.7901], zoom: 12 },
    'طرطوس': { center: [34.8890, 35.8866], zoom: 12 },
    'درعا': { center: [32.6255, 36.1054], zoom: 11 },
    'السويداء': { center: [32.7089, 36.5695], zoom: 11 },
    'دير الزور': { center: [35.3359, 40.1408], zoom: 11 },
    'الحسكة': { center: [36.5023, 40.7483], zoom: 11 },
    'الرقة': { center: [35.9594, 39.0089], zoom: 11 },
    'إدلب': { center: [35.9306, 36.6339], zoom: 11 },
    'القنيطرة': { center: [33.1259, 35.8246], zoom: 11 }
};

function gisApp() {
    return {
        map: null,
        data: { cases: [], volunteers: [], warehouses: [] },
        counts: { cases: 0, volunteers: 0, warehouses: 0 },
        markerGroup: null,
        showCases: true,
        showVolunteers: true,
        showWarehouses: true,
        selectedGov: '',

        // Modal state for adding a new warehouse
        addWarehouseModal: false,
        modalGov: '',
        modalDistrict: '',
        currentGovPlaces: [],
        modalLat: '',
        modalLng: '',
        syrianPlaces: syrianPlaces,

        init() {
            this.map = L.map('map', {
                center: [34.8021, 38.0000],
                zoom: 7,
            });

            // Standard OpenStreetMap TileLayer (Reliable, Global, NO API KEY REQUIRED)
            L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19,
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(this.map);

            this.markerGroup = L.layerGroup().addTo(this.map);
            this.fetchData();
        },

        async fetchData() {
            try {
                const response = await fetch("{{ route('dashboard.gis.data') }}");
                this.data = await response.json();
                this.counts.cases = this.data.cases.length;
                this.counts.volunteers = this.data.volunteers.length;
                this.counts.warehouses = this.data.warehouses.length;
                this.renderMarkers();
            } catch (err) {
                console.error('Error loading GIS data:', err);
            }
        },

        renderMarkers() {
            this.markerGroup.clearLayers();

            const pinIcon = (bgColor, label) => L.divIcon({
                className: 'plain-marker',
                html: `<div style="background: ${bgColor}; width: 14px; height: 14px; border-radius: 50%; border: 2px solid #fff; box-shadow: 0 1px 3px rgba(0,0,0,0.3);"></div>`,
                iconSize: [14, 14],
                iconAnchor: [7, 7],
                popupAnchor: [0, -7],
            });

            // 1. Cases (Deep dark red)
            if (this.showCases) {
                this.data.cases.forEach(c => {
                    if (this.selectedGov && c.governorate !== this.selectedGov) return;

                    const marker = L.marker([c.lat, c.lng], {
                        icon: pinIcon('#dc2626')
                    });

                    marker.bindPopup(`
                        <div style="direction: rtl; font-family: 'IBM Plex Sans Arabic', sans-serif; padding: 4px;">
                            <div style="font-size: 11px; color: #71717a;">طلب مساعدة • ${c.governorate}</div>
                            <div style="font-weight: 600; margin: 4px 0; color: #18181b; font-size: 12px;">${c.title}</div>
                            <div style="font-size: 11px; font-family: 'JetBrains Mono', monospace; color: #dc2626;">AI Urgency: ${c.urgency_index}/100</div>
                            <div style="margin-top: 6px; padding-top: 4px; border-top: 1px solid #f4f4f5;">
                                <a href="{{ url('/dashboard/cases') }}" style="color: #18181b; font-size: 11px; text-decoration: underline;">مراجعة الحالة &larr;</a>
                            </div>
                        </div>
                    `);
                    this.markerGroup.addLayer(marker);
                });
            }

            // 2. Volunteers (Deep blue)
            if (this.showVolunteers) {
                this.data.volunteers.forEach(v => {
                    const marker = L.marker([v.lat, v.lng], {
                        icon: pinIcon('#2563eb')
                    });

                    marker.bindPopup(`
                        <div style="direction: rtl; font-family: 'IBM Plex Sans Arabic', sans-serif; padding: 4px;">
                            <div style="font-size: 11px; color: #71717a;">فريق ميداني</div>
                            <div style="font-weight: 600; margin: 4px 0; color: #18181b; font-size: 12px;">${v.name}</div>
                            <div style="font-size: 11px; color: #52525b;">الوسيلة: ${v.vehicle} • ${v.hours} ساعة</div>
                            <div style="font-size: 10px; font-family: 'JetBrains Mono', monospace; color: #a1a1aa; margin-top: 2px;">${v.phone}</div>
                        </div>
                    `);
                    this.markerGroup.addLayer(marker);
                });
            }

            // 3. Warehouses (Green Markers)
            if (this.showWarehouses) {
                this.data.warehouses.forEach(w => {
                    if (this.selectedGov && w.governorate !== this.selectedGov) return;

                    const marker = L.marker([w.lat, w.lng], {
                        icon: pinIcon('#0f766e')
                    });

                    const districtInfo = w.district ? ` • ${w.district}` : '';
                    marker.bindPopup(`
                        <div style="direction: rtl; font-family: 'IBM Plex Sans Arabic', sans-serif; padding: 4px;">
                            <div style="font-size: 11px; color: #0f766e; font-weight: 600;">مستودع إغاثي • ${w.governorate}${districtInfo}</div>
                            <div style="font-weight: 600; margin: 4px 0; color: #18181b; font-size: 12px;">${w.name}</div>
                            <div style="font-size: 11px; color: #52525b;">المخزون / السعة: ${w.stock}</div>
                            ${w.manager ? `<div style="font-size: 10px; color: #71717a; margin-top: 2px;">المشرف: ${w.manager} ${w.phone ? '(' + w.phone + ')' : ''}</div>` : ''}
                        </div>
                    `);
                    this.markerGroup.addLayer(marker);
                });
            }
        },

        filterByGov() {
            this.renderMarkers();
            if (this.selectedGov && govCenterCoords[this.selectedGov]) {
                const target = govCenterCoords[this.selectedGov];
                this.map.flyTo(target.center, target.zoom);
            }
        },

        resetMap() {
            this.selectedGov = '';
            this.showCases = true;
            this.showVolunteers = true;
            this.showWarehouses = true;
            this.renderMarkers();
            this.map.flyTo([34.8021, 38.0000], 7);
        },

        openAddWarehouseModal() {
            this.addWarehouseModal = true;
            this.modalGov = '';
            this.modalDistrict = '';
            this.currentGovPlaces = [];
            this.modalLat = '';
            this.modalLng = '';
        },

        onModalGovChange() {
            if (this.modalGov && syrianPlaces[this.modalGov]) {
                this.currentGovPlaces = syrianPlaces[this.modalGov];
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
    }
}
</script>
@endsection
