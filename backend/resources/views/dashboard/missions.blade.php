@extends('layouts.dashboard')

@section('title', 'إدارة مهام الاستجابة الطارئة')
@section('page_title', 'مهام الطوارئ الميدانية (Emergency Missions)')

@section('content')
<div class="space-y-5" x-data="{ createModalOpen: false, editModalOpen: false, editingMission: {}, openEdit(m) { this.editingMission = { ...m }; this.editModalOpen = true; } }">

    <!-- Top Action & Stat Row -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">المهام المفتوحة للاستجابة</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ $openMissionsCount }}</div>
            <div class="text-[11px] text-zinc-400">بانتظار اكتمال فرق المتطوعين</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">بلاغات طوارئ حرجة (SOS)</div>
            <div class="text-2xl font-semibold font-num text-rose-600 dark:text-rose-400">{{ $criticalMissionsCount }}</div>
            <div class="text-[11px] text-zinc-400">تدخل فوري وإسعافي عاجل</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 font-medium">بروتوكول البث اللحظي</div>
            <div class="text-xs font-semibold text-zinc-800 dark:text-zinc-200 pt-1 font-num">FCM Alert Broadcast</div>
            <div class="text-[11px] text-zinc-400">تنبيهات فورية لتطبيقات المتطوعين</div>
        </div>
    </div>

    <!-- Emergency Missions Table -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل مهام الطوارئ والإغاثة السريعة</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">تعبئة وتوجيه المتطوعين حسب المهارات الإسعافية والجغرافية</p>
            </div>
            <button type="button" @click="createModalOpen = true" class="px-3 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-xs font-medium hover:opacity-90">
                إطلاق مهمة طوارئ جديدة (SOS) +
            </button>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">عنوان المهمة والمنطقة</th>
                        <th class="px-4 py-2.5 font-normal">المحافظة</th>
                        <th class="px-4 py-2.5 font-normal">درجة الخطورة</th>
                        <th class="px-4 py-2.5 font-normal">المهارات المطلوبة</th>
                        <th class="px-4 py-2.5 font-normal">المتطوعون (المنضم / المطلوب)</th>
                        <th class="px-4 py-2.5 font-normal">الحالة</th>
                        <th class="px-4 py-2.5 text-center font-normal">الإجراء</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($missions as $m)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $m->title }}</div>
                                <div class="text-[11px] text-zinc-400 mt-0.5 line-clamp-1">{{ $m->description }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap">
                                <span class="text-zinc-800 dark:text-zinc-200">{{ $m->governorate?->name ?? 'دمشق' }}</span>
                                <span class="text-[10px] text-zinc-400 block">{{ $m->district ?? 'مركز المحافظة' }}</span>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($m->urgency === 'critical')
                                    <span class="text-rose-600 dark:text-rose-400 font-semibold font-num">حرجة (SOS)</span>
                                @elseif($m->urgency === 'high')
                                    <span class="text-amber-600 dark:text-amber-400 font-medium">أولوية مرتفعة</span>
                                @else
                                    <span class="text-zinc-500">متوسطة</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if(!empty($m->required_skills))
                                    <span class="text-zinc-600 dark:text-zinc-400">
                                        {{ is_array($m->required_skills) ? implode(', ', $m->required_skills) : $m->required_skills }}
                                    </span>
                                @else
                                    <span class="text-zinc-400">عامة</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num">
                                <span class="font-medium text-zinc-900 dark:text-zinc-100">{{ $m->volunteers_joined }}</span>
                                <span class="text-zinc-400">/ {{ $m->volunteers_needed }}</span>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($m->status === 'open')
                                    <span class="text-blue-600 dark:text-blue-400 font-medium">مفتوحة للانضمام</span>
                                @elseif($m->status === 'in_progress')
                                    <span class="text-amber-600 dark:text-amber-400 font-medium">قيد التنفيذ الميداني</span>
                                @else
                                    <span class="text-zinc-400">مكتملة</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                <div class="flex items-center justify-center gap-2">
                                    <button type="button" @click="openEdit({{ json_encode([
                                        'id' => $m->id,
                                        'title' => $m->title,
                                        'description' => $m->description,
                                        'urgency' => $m->urgency,
                                        'governorate_id' => $m->governorate_id,
                                        'district' => $m->district,
                                        'volunteers_needed' => $m->volunteers_needed,
                                        'required_skills' => is_array($m->required_skills) ? implode(', ', $m->required_skills) : $m->required_skills,
                                        'status' => $m->status,
                                    ]) }})" class="text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 text-xs hover:underline">
                                        تعديل
                                    </button>
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    @if($m->status !== 'completed')
                                        <form action="{{ route('dashboard.missions.close', $m->id) }}" method="POST" class="inline">
                                            @csrf
                                            <button type="submit" class="text-xs text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-100 hover:underline">
                                                اكتمال
                                            </button>
                                        </form>
                                    @else
                                        <form action="{{ route('dashboard.missions.reopen', $m->id) }}" method="POST" class="inline">
                                            @csrf
                                            <button type="submit" class="text-xs text-emerald-600 dark:text-emerald-400 hover:underline" title="إعادة فتح المهمة للاستجابة الميدانية">
                                                (إعادة الفتح)
                                            </button>
                                        </form>
                                    @endif
                                    <span class="text-zinc-300 dark:text-zinc-700">|</span>
                                    <form action="{{ route('dashboard.missions.destroy', $m->id) }}" method="POST" onsubmit="return confirm('تأكيد حذف مهمة الطوارئ هذه؟');" class="inline">
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
                                لا توجد مهام طوارئ مفتوحة حالياً
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        <div class="p-3 border-t border-zinc-100 dark:border-zinc-800 text-xs">
            {{ $missions->links() }}
        </div>
    </div>

    <!-- Create Mission Modal -->
    <div x-show="createModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="createModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-3 max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">إطلاق مهمة طوارئ واستجابة عاجلة</h4>
                <button @click="createModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form action="{{ route('dashboard.missions.store') }}" method="POST" class="space-y-3 text-xs">
                @csrf
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">عنوان البلاغ أو المهمة</label>
                    <input type="text" name="title" required placeholder="مثال: إغاثة طارئة - انهيار بناء سكني في حي الميدان" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المحافظة</label>
                        <select name="governorate_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            @foreach($governorates as $gov)
                                <option value="{{ $gov->id }}">{{ $gov->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المنطقة / الحي التفصيلي</label>
                        <input type="text" name="district" placeholder="مثال: حي التضامن - شارع فلسطين" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">درجة الخطورة والاستعجال</label>
                        <select name="urgency" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="critical">حرجة وفورية (SOS)</option>
                            <option value="high" selected>مرتفعة</option>
                            <option value="medium">متوسطة</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">العدد المطلوب من المتطوعين</label>
                        <input type="number" name="volunteers_needed" required min="1" value="4" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num">
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المهارات المطلوبة (مفصولة بفاصلة)</label>
                    <input type="text" name="required_skills" placeholder="مثال: إسعاف أولي, سيارة دفع رباعي, لوجستيات" value="إسعاف أولي, إغاثة ميدانية" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">تفاصيل وتوجيهات الاستجابة</label>
                    <textarea name="description" required rows="3" placeholder="تفاصيل الموقع ونقطة التجمع والمعدات المطلوبة..." class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none"></textarea>
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="createModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">بث وتعميم المهمة</button>
                </div>
            </form>
        </div>
    </div>


    <!-- Edit Emergency Mission Modal -->
    <div x-show="editModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="editModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-lg w-full p-5 space-y-3 max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">تعديل بيانات مهمة الطوارئ الميدانية</h4>
                <button @click="editModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form :action="'{{ url('dashboard/missions') }}/' + editingMission.id" method="POST" class="space-y-3 text-xs">
                @csrf
                @method('PUT')
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">عنوان البلاغ أو المهمة</label>
                    <input type="text" name="title" x-model="editingMission.title" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">درجة الخطورة والاستعجال</label>
                        <select name="urgency" x-model="editingMission.urgency" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="critical">حرجة وفورية (Red Alert)</option>
                            <option value="high">مرتفعة</option>
                            <option value="medium">متوسطة</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">حالة المهمة</label>
                        <select name="status" x-model="editingMission.status" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="open">مفتوحة للانضمام</option>
                            <option value="in_progress">قيد التنفيذ الميداني</option>
                            <option value="completed">مكتملة وموثقة</option>
                        </select>
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المحافظة</label>
                        <select name="governorate_id" x-model="editingMission.governorate_id" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            @foreach($governorates as $gov)
                                <option value="{{ $gov->id }}">{{ $gov->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المنطقة / الحي</label>
                        <input type="text" name="district" x-model="editingMission.district" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">عدد المتطوعين المطلوب</label>
                        <input type="number" name="volunteers_needed" x-model="editingMission.volunteers_needed" required min="1" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none font-num">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">المهارات المطلوبة (مفصولة بفاصلة)</label>
                        <input type="text" name="required_skills" x-model="editingMission.required_skills" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">تفاصيل المهمة وتعليمات السلامة</label>
                    <textarea name="description" rows="2" x-model="editingMission.description" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none"></textarea>
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
