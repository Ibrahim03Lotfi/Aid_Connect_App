@extends('layouts.dashboard')

@section('title', 'إعدادات المنظومة ومعايير التشغيل')
@section('page_title', 'إعدادات المنظومة والتشخيص الفني (Platform Settings & Health)')

@section('content')
<div class="space-y-6" x-data="{ addCatModal: false, editCatModal: false, editingCat: {}, openEditCat(c) { this.editingCat = { ...c }; this.editCatModal = true; }, addGovModal: false, editGovModal: false, editingGov: {}, openEditGov(g) { this.editingGov = { ...g }; this.editGovModal = true; } }">

    <!-- System Diagnostics Bar -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-5 space-y-4">
        <div class="border-b border-zinc-200 dark:border-zinc-800 pb-3 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">مؤشرات الجاهزية والمعايير التقنية (System Diagnostics)</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">الحالة التشغيلية للاتصالات وقواعد البيانات ومحركات التشفير الميدانية</p>
            </div>
            <span class="inline-flex items-center gap-1.5 text-xs text-emerald-700 dark:text-emerald-400 font-medium">
                <span class="w-2 h-2 rounded-full bg-emerald-600"></span>
                <span>System Operational (100%)</span>
            </span>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 text-xs">
            <div class="p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded border border-zinc-100 dark:border-zinc-800 space-y-1">
                <div class="text-[11px] text-zinc-400">قاعدة البيانات المركزية</div>
                <div class="font-semibold text-zinc-900 dark:text-zinc-100">{{ $diagnostics['db_status'] }}</div>
                <div class="text-[10px] text-zinc-400 font-num">PostgreSQL 18 x64 • ACID Compliant</div>
            </div>

            <div class="p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded border border-zinc-100 dark:border-zinc-800 space-y-1">
                <div class="text-[11px] text-zinc-400">معيار تشفير بطاقات NFC</div>
                <div class="font-semibold text-zinc-900 dark:text-zinc-100 font-num">ISO/IEC 14443 Type A</div>
                <div class="text-[10px] text-zinc-400">UID Hardware Encryption</div>
            </div>

            <div class="p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded border border-zinc-100 dark:border-zinc-800 space-y-1">
                <div class="text-[11px] text-zinc-400">محرك كشف التزوير والفرز</div>
                <div class="font-semibold text-zinc-900 dark:text-zinc-100 font-num">dHash + Arabic NLP</div>
                <div class="text-[10px] text-zinc-400">Hamming Dist <= 5 • Gemini Multimodal</div>
            </div>

            <div class="p-3 bg-zinc-50 dark:bg-zinc-800/50 rounded border border-zinc-100 dark:border-zinc-800 space-y-1">
                <div class="text-[11px] text-zinc-400">بوابة الدفع والشفافية</div>
                <div class="font-semibold text-zinc-900 dark:text-zinc-100 font-num">Sham Cash & Transfer</div>
                <div class="text-[10px] text-zinc-400">تتبع الحوالات وإشعارات الدفع</div>
            </div>
        </div>
    </div>

    <!-- 2 Column Section: Categories & Governorates -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">

        <!-- Categories Hub -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
            <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
                <div>
                    <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">تصنيفات ومجالات الإغاثة (Categories)</h3>
                    <p class="text-[11px] text-zinc-400 mt-0.5">{{ $categories->count() }} تصنيفات إنسانية معتمدة</p>
                </div>
                <button @click="addCatModal = true" class="px-2.5 py-1 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-[11px] font-medium hover:bg-zinc-800 flex items-center gap-1">
                    <i class="fa-solid fa-plus text-[9px]"></i>
                    <span>إضافة تصنيف</span>
                </button>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-right text-xs">
                    <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                        <tr>
                            <th class="px-4 py-2.5 font-normal">اسم التصنيف</th>
                            <th class="px-4 py-2.5 font-normal">الحالات التابعة</th>
                            <th class="px-4 py-2.5 font-normal">تاريخ الإنشاء</th>
                            <th class="px-4 py-2.5 text-center font-normal">إجراء</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                        @forelse($categories as $cat)
                            <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                                <td class="px-4 py-2.5 font-medium text-zinc-900 dark:text-zinc-100">
                                    {{ $cat->name }}
                                </td>
                                <td class="px-4 py-2.5 font-num text-zinc-600 dark:text-zinc-400">
                                    {{ $cat->cases_count }} حالة
                                </td>
                                <td class="px-4 py-2.5 font-num text-[11px] text-zinc-400">
                                    {{ $cat->created_at?->format('Y-m-d') ?? 'أساسي' }}
                                </td>
                                <td class="px-4 py-2.5 whitespace-nowrap text-center">
                                    <div class="flex items-center justify-center gap-2">
                                        <button type="button" @click="openEditCat({{ json_encode(['id' => $cat->id, 'name' => $cat->name]) }})" class="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 text-xs hover:underline">
                                            تعديل
                                        </button>
                                        <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                        <form action="{{ route('dashboard.settings.categories.destroy', $cat->id) }}" method="POST" onsubmit="return confirm('تأكيد حذف هذا التصنيف؟');" class="inline">
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
                                <td colspan="4" class="px-4 py-6 text-center text-zinc-400">لا توجد تصنيفات</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Governorates Hub -->
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
            <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
                <div>
                    <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">نطاق التغطية الجغرافية (Governorates)</h3>
                    <p class="text-[11px] text-zinc-400 mt-0.5">{{ $governorates->count() }} محافظات ومناطق إغاثية</p>
                </div>
                <button @click="addGovModal = true" class="px-2.5 py-1 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-[11px] font-medium hover:bg-zinc-800 flex items-center gap-1">
                    <i class="fa-solid fa-plus text-[9px]"></i>
                    <span>إضافة محافظة</span>
                </button>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-right text-xs">
                    <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                        <tr>
                            <th class="px-4 py-2.5 font-normal">اسم المحافظة</th>
                            <th class="px-4 py-2.5 font-normal">الحالة التشغيلية</th>
                            <th class="px-4 py-2.5 font-normal">الفرق الميدانية</th>
                            <th class="px-4 py-2.5 text-center font-normal">إجراء</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                        @forelse($governorates as $gov)
                            <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                                <td class="px-4 py-2.5 font-medium text-zinc-900 dark:text-zinc-100">
                                    {{ $gov->name }}
                                </td>
                                <td class="px-4 py-2.5 text-[11px]">
                                    <span class="text-emerald-700 dark:text-emerald-400 font-medium">مغطاة ومفعلة</span>
                                </td>
                                <td class="px-4 py-2.5 text-[11px] text-zinc-500">
                                    نظام GIS متصل
                                </td>
                                <td class="px-4 py-2.5 whitespace-nowrap text-center">
                                    <div class="flex items-center justify-center gap-2">
                                        <button type="button" @click="openEditGov({{ json_encode(['id' => $gov->id, 'name' => $gov->name]) }})" class="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 text-xs hover:underline">
                                            تعديل
                                        </button>
                                        <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                        <form action="{{ route('dashboard.settings.governorates.destroy', $gov->id) }}" method="POST" onsubmit="return confirm('تأكيد حذف هذه المحافظة؟');" class="inline">
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
                                <td colspan="4" class="px-4 py-6 text-center text-zinc-400">لا توجد محافظات مسجلة</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <!-- Add Category Modal -->
    <div x-show="addCatModal" x-cloak class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div x-show="addCatModal" @click="addCatModal = false" class="fixed inset-0 bg-zinc-950/60 backdrop-blur-xs transition-opacity"></div>
            <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

            <div class="inline-block align-bottom bg-white dark:bg-zinc-900 rounded-lg text-right overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-sm sm:w-full border border-zinc-200 dark:border-zinc-800">
                <form action="{{ route('dashboard.settings.categories.store') }}" method="POST">
                    @csrf
                    <div class="p-5 space-y-3">
                        <div class="flex items-center justify-between border-b border-zinc-200 dark:border-zinc-800 pb-2">
                            <h3 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100">إضافة تصنيف إغاثي جديد</h3>
                            <button type="button" @click="addCatModal = false" class="text-zinc-400 hover:text-zinc-600 text-xs"><i class="fa-solid fa-xmark"></i></button>
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">اسم التصنيف (مثال: كسوة الشتاء)</label>
                            <input type="text" name="name" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 outline-none">
                        </div>
                    </div>
                    <div class="bg-zinc-50 dark:bg-zinc-800/60 px-5 py-3 border-t border-zinc-200 dark:border-zinc-800 flex justify-end gap-2">
                        <button type="button" @click="addCatModal = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-xs text-zinc-600">إلغاء</button>
                        <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-xs font-medium">حفظ التصنيف</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Add Governorate Modal -->
    <div x-show="addGovModal" x-cloak class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div x-show="addGovModal" @click="addGovModal = false" class="fixed inset-0 bg-zinc-950/60 backdrop-blur-xs transition-opacity"></div>
            <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

            <div class="inline-block align-bottom bg-white dark:bg-zinc-900 rounded-lg text-right overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-sm sm:w-full border border-zinc-200 dark:border-zinc-800">
                <form action="{{ route('dashboard.settings.governorates.store') }}" method="POST">
                    @csrf
                    <div class="p-5 space-y-3">
                        <div class="flex items-center justify-between border-b border-zinc-200 dark:border-zinc-800 pb-2">
                            <h3 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100">إضافة محافظة / منطقة جغرافية</h3>
                            <button type="button" @click="addGovModal = false" class="text-zinc-400 hover:text-zinc-600 text-xs"><i class="fa-solid fa-xmark"></i></button>
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">اسم المحافظة (مثال: طرطوس)</label>
                            <input type="text" name="name" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 outline-none">
                        </div>
                    </div>
                    <div class="bg-zinc-50 dark:bg-zinc-800/60 px-5 py-3 border-t border-zinc-200 dark:border-zinc-800 flex justify-end gap-2">
                        <button type="button" @click="addGovModal = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-xs text-zinc-600">إلغاء</button>
                        <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-xs font-medium">إضافة المحافظة</button>
                    </div>
                </form>
            </div>
        </div>
    </div>


    <!-- Edit Category Modal -->
    <div x-show="editCatModal" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="editCatModal = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-sm w-full p-5 space-y-3">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">تعديل اسم التصنيف</h4>
                <button @click="editCatModal = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form :action="'{{ url('dashboard/settings/categories') }}/' + editingCat.id" method="POST" class="space-y-3 text-xs">
                @csrf
                @method('PUT')
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">اسم التصنيف الإغاثي</label>
                    <input type="text" name="name" x-model="editingCat.name" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="editCatModal = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">حفظ التعديل</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Governorate Modal -->
    <div x-show="editGovModal" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="editGovModal = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-sm w-full p-5 space-y-3">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">تعديل اسم المحافظة</h4>
                <button @click="editGovModal = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form :action="'{{ url('dashboard/settings/governorates') }}/' + editingGov.id" method="POST" class="space-y-3 text-xs">
                @csrf
                @method('PUT')
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">اسم المحافظة أو المنطقة</label>
                    <input type="text" name="name" x-model="editingGov.name" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="editGovModal = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">حفظ التعديل</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
