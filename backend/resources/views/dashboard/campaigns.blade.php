@extends('layouts.dashboard')

@section('title', 'حملات الإغاثة والتوزيع الميداني')
@section('page_title', 'حملات الإغاثة والتوزيع (Aid Campaigns)')

@section('content')
<div class="space-y-5" x-data="{ createModalOpen: false, editModalOpen: false, editingCampaign: {}, openEdit(camp) { this.editingCampaign = { ...camp }; this.editModalOpen = true; } }">

    <!-- Top Action & Stat Row -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">إجمالي الحملات</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ $totalCampaigns }}</div>
            <div class="text-[11px] text-zinc-400">حملات التوزيع المعتمدة</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">الحملات النشطة حالياً</div>
            <div class="text-2xl font-semibold font-num text-emerald-700 dark:text-emerald-400">{{ $activeCampaigns }}</div>
            <div class="text-[11px] text-zinc-400">متاحة للتوزيع الميداني</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">المستهدف الكلي للأسر</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ number_format($totalTarget) }}</div>
            <div class="text-[11px] text-zinc-400">أسرة مستحقة</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">الحصص المسلمة فعلياً</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ number_format($totalDistributed) }}</div>
            <div class="text-[11px] text-zinc-400">موثقة ببطاقة NFC</div>
        </div>
    </div>

    <!-- Campaigns Management Table Header -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل الحملات الإغاثية وجداول التوزيع</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">منع الازدواجية وضبط حصة الأسرة الواحدة لكل حملة</p>
            </div>
            <button type="button" @click="createModalOpen = true" class="px-3 py-1.5 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 text-xs font-semibold shadow-sm transition-colors flex items-center gap-1.5">
                <i class="fa-solid fa-plus text-[10px]"></i>
                <span>إنشاء حملة إغاثية جديدة</span>
            </button>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px] bg-zinc-50/50 dark:bg-zinc-900/50">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">عنوان الحملة</th>
                        <th class="px-4 py-2.5 font-normal">القطاع / التصنيف</th>
                        <th class="px-4 py-2.5 font-normal">مادة التوزيع والحصة</th>
                        <th class="px-4 py-2.5 font-normal">الفترة الزمنية</th>
                        <th class="px-4 py-2.5 font-normal">نسبة الإنجاز (المسلم / المستهدف)</th>
                        <th class="px-4 py-2.5 font-normal">الحالة</th>
                        <th class="px-4 py-2.5 text-center font-normal">الإجراء</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($campaigns as $camp)
                        @php
                            $target = max(1, $camp->target_families_count);
                            $dist = $camp->distributed_families_count;
                            $pct = round(($dist / $target) * 100);
                        @endphp
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50 transition-colors">
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $camp->title }}</div>
                                <div class="text-[11px] text-zinc-400 mt-0.5 line-clamp-1">{{ $camp->description }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap">
                                <span class="text-zinc-600 dark:text-zinc-400">{{ $camp->category?->name ?? 'إغاثة عامة' }}</span>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap">
                                <span class="font-medium text-zinc-800 dark:text-zinc-200">{{ $camp->item_type }}</span>
                                <span class="text-[10px] text-zinc-400 block font-num">{{ $camp->items_allocated_per_family }} لكل أسرة</span>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px] text-zinc-500">
                                <div>{{ $camp->start_date ? $camp->start_date->format('Y-m-d') : '-' }}</div>
                                <div class="text-zinc-400">إلى: {{ $camp->end_date ? $camp->end_date->format('Y-m-d') : 'مفتوحة' }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap">
                                <div class="font-num text-xs font-semibold text-zinc-900 dark:text-zinc-100">
                                    {{ number_format($dist) }} / {{ number_format($target) }} ({{ $pct }}%)
                                </div>
                                <div class="w-28 h-1.5 bg-zinc-100 dark:bg-zinc-800 rounded-full mt-1.5 overflow-hidden">
                                    <div class="h-full bg-gradient-to-r from-teal-600 to-emerald-600 rounded-full" style="width: {{ min(100, $pct) }}%"></div>
                                </div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($camp->status === 'active')
                                    <span class="inline-flex items-center gap-1 text-[11px] font-semibold text-emerald-700 dark:text-emerald-400 bg-emerald-50 dark:bg-emerald-950/40 px-2 py-0.5 rounded border border-emerald-200 dark:border-emerald-800/60">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
                                        نشطة بالميدان
                                    </span>
                                @else
                                    <span class="inline-flex items-center gap-1 text-[11px] text-zinc-500 bg-zinc-100 dark:bg-zinc-800 px-2 py-0.5 rounded">
                                        مكتملة ومغلقة
                                    </span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                <div class="flex items-center justify-center gap-2">
                                    <button type="button" @click="openEdit({{ json_encode([
                                        'id' => $camp->id,
                                        'title' => $camp->title,
                                        'description' => $camp->description,
                                        'category_id' => $camp->category_id,
                                        'item_type' => $camp->item_type,
                                        'items_allocated_per_family' => $camp->items_allocated_per_family,
                                        'start_date' => $camp->start_date ? $camp->start_date->format('Y-m-d') : '',
                                        'end_date' => $camp->end_date ? $camp->end_date->format('Y-m-d') : '',
                                        'target_families_count' => $camp->target_families_count,
                                        'status' => $camp->status,
                                    ]) }})" class="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 text-xs hover:underline">
                                        تعديل
                                    </button>
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    <form action="{{ route('dashboard.campaigns.toggle', $camp->id) }}" method="POST" class="inline">
                                        @csrf
                                        <button type="submit" class="text-xs text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 hover:underline">
                                            {{ $camp->status === 'active' ? 'إغلاق' : 'تفعيل' }}
                                        </button>
                                    </form>
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    <form action="{{ route('dashboard.campaigns.destroy', $camp->id) }}" method="POST" onsubmit="return confirm('تأكيد حذف هذه الحملة الإغاثية؟');" class="inline">
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
                                لا توجد حملات إغاثية مسجلة حالياً
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="p-3 border-t border-zinc-100 dark:border-zinc-800 text-xs">
            {{ $campaigns->links() }}
        </div>
    </div>

    <!-- Create Campaign Modal -->
    <div x-show="createModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="createModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-3 max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">إنشاء حملة إغاثية جديدة</h4>
                <button @click="createModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form action="{{ route('dashboard.campaigns.store') }}" method="POST" class="space-y-3 text-xs">
                @csrf
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">اسم الحملة الإغاثية</label>
                    <input type="text" name="title" required placeholder="مثال: حملة دفء الشتاء 2026 للإغاثة العاجلة" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">القطاع الإغاثي</label>
                    <select name="category_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                        @foreach($categories as $cat)
                            <option value="{{ $cat->id }}">{{ $cat->name }}</option>
                        @endforeach
                    </select>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المادة الموزعة</label>
                        <input type="text" name="item_type" required value="سلة غذائية وطبية متكاملة" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">الحصة لكل أسرة</label>
                        <input type="number" name="items_allocated_per_family" required min="1" value="1" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">تاريخ البدء</label>
                        <input type="date" name="start_date" required value="{{ date('Y-m-d') }}" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">تاريخ الانتهاء المتوقع</label>
                        <input type="date" name="end_date" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num">
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">عدد الأسر المستهدفة</label>
                    <input type="number" name="target_families_count" required min="1" value="150" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num font-semibold">
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">وصف الحملة وأهدافها</label>
                    <textarea name="description" rows="2" placeholder="توزيع طرود إغاثية للأسر الأشد هشاشة..." class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none"></textarea>
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="createModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded-md bg-teal-700 hover:bg-teal-800 text-white dark:bg-teal-600 dark:hover:bg-teal-500 font-semibold shadow-sm transition-colors">حفظ وإطلاق الحملة</button>
                </div>
            </form>
        </div>
    </div>


    <!-- Edit Campaign Modal -->
    <div x-show="editModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="editModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-3 max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">تعديل بيانات الحملة الإغاثية</h4>
                <button @click="editModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form :action="'{{ url('dashboard/campaigns') }}/' + editingCampaign.id" method="POST" class="space-y-3 text-xs">
                @csrf
                @method('PUT')
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">اسم الحملة الإغاثية</label>
                    <input type="text" name="title" x-model="editingCampaign.title" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">القطاع الإغاثي</label>
                    <select name="category_id" x-model="editingCampaign.category_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                        @foreach($categories as $cat)
                            <option value="{{ $cat->id }}">{{ $cat->name }}</option>
                        @endforeach
                    </select>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المادة الموزعة</label>
                        <input type="text" name="item_type" x-model="editingCampaign.item_type" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">الحصة لكل أسرة</label>
                        <input type="number" name="items_allocated_per_family" x-model="editingCampaign.items_allocated_per_family" required min="1" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">تاريخ البدء</label>
                        <input type="date" name="start_date" x-model="editingCampaign.start_date" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">تاريخ الانتهاء المتوقع</label>
                        <input type="date" name="end_date" x-model="editingCampaign.end_date" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">عدد الأسر المستهدفة</label>
                        <input type="number" name="target_families_count" x-model="editingCampaign.target_families_count" required min="1" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num font-semibold">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">حالة الحملة</label>
                        <select name="status" x-model="editingCampaign.status" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="active">نشطة ومتاحة للتوزيع</option>
                            <option value="completed">مكتملة ومغلقة</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">وصف الحملة وأهدافها</label>
                    <textarea name="description" rows="2" x-model="editingCampaign.description" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none"></textarea>
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
