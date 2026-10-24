@extends('layouts.dashboard')

@section('title', 'التعميمات والإشعارات الطارئة')
@section('page_title', 'مركز التعميمات والإشعارات الميدانية (Emergency Broadcast)')

@section('content')
<div class="space-y-6" x-data="{ broadcastModal: false }">

    <!-- Stats Row -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">إجمالي التعميمات الموجهة</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ number_format($totalSent) }}</div>
            <div class="text-[11px] text-zinc-400">إشعارات النظام عبر التطبيق المحمول</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">إشعارات غير مقروءة حالياً</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ number_format($unreadCount) }}</div>
            <div class="text-[11px] text-zinc-400">قيد الاستلام في هواتف الكوادر</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">بث التنبيهات المباشرة (FCM / Push)</div>
            <div class="text-xs font-semibold text-emerald-700 dark:text-emerald-400 pt-1 font-num">Active Broadcast Protocol</div>
            <div class="text-[11px] text-zinc-400">تنبيهات فورية للمتطوعين وفرق الطوارئ</div>
        </div>
    </div>

    <!-- Notifications Table -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل الإشعارات والتعميمات المرسلة</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">التنبيهات الإدارية الموجهة للكوادر والمستفيدين</p>
            </div>
            <button @click="broadcastModal = true" class="px-3 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-xs font-medium hover:bg-zinc-800 dark:hover:bg-white flex items-center gap-1.5 transition-colors">
                <i class="fa-solid fa-bullhorn text-[10px]"></i>
                <span>بث تعميم طارئ جديد</span>
            </button>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">المستلم / الحساب</th>
                        <th class="px-4 py-2.5 font-normal">عنوان التعميم</th>
                        <th class="px-4 py-2.5 font-normal">تفاصيل الرسالة</th>
                        <th class="px-4 py-2.5 font-normal">النوع</th>
                        <th class="px-4 py-2.5 font-normal">حالة القراءة</th>
                        <th class="px-4 py-2.5 font-normal">تاريخ البث</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($notifications as $notif)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-3 whitespace-nowrap">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $notif->user?->name ?? 'مستخدم عام' }}</div>
                                <div class="text-[10px] text-zinc-400 font-num">{{ $notif->user?->role ?? 'user' }} • {{ $notif->user?->phone }}</div>
                            </td>
                            <td class="px-4 py-3 font-medium text-zinc-900 dark:text-zinc-100">
                                {{ $notif->title }}
                            </td>
                            <td class="px-4 py-3 text-zinc-600 dark:text-zinc-400 max-w-sm">
                                <div class="line-clamp-2">{{ $notif->body }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px] text-zinc-500">
                                {{ $notif->type ?? 'general' }}
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($notif->is_read)
                                    <span class="text-zinc-400">مقروء</span>
                                @else
                                    <span class="text-emerald-700 dark:text-emerald-400 font-medium">غير مقروء</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px] text-zinc-400">
                                {{ $notif->created_at?->diffForHumans() ?? 'الآن' }}
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-4 py-8 text-center text-zinc-400">
                                لا توجد إشعارات مسجلة في النظام حتى الآن
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($notifications->hasPages())
            <div class="p-3 border-t border-zinc-200 dark:border-zinc-800">
                {{ $notifications->links() }}
            </div>
        @endif
    </div>

    <!-- Broadcast Modal -->
    <div x-show="broadcastModal" x-cloak class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
        <div class="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div x-show="broadcastModal" @click="broadcastModal = false" class="fixed inset-0 bg-zinc-950/60 backdrop-blur-xs transition-opacity"></div>
            <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>

            <div class="inline-block align-bottom bg-white dark:bg-zinc-900 rounded-lg text-right overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full border border-zinc-200 dark:border-zinc-800">
                <form action="{{ route('dashboard.notifications.broadcast') }}" method="POST">
                    @csrf
                    <div class="p-6 space-y-4">
                        <div class="flex items-center justify-between border-b border-zinc-200 dark:border-zinc-800 pb-3">
                            <h3 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100">بث تعميم ميداني فوري (Emergency Broadcast)</h3>
                            <button type="button" @click="broadcastModal = false" class="text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 text-xs">
                                <i class="fa-solid fa-xmark"></i>
                            </button>
                        </div>

                        <div>
                            <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">الجهة المستهدفة بالتعميم</label>
                            <select name="target" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 outline-none">
                                <option value="volunteers">جميع المتطوعين الميدانيين (Volunteers Only)</option>
                                <option value="organizations">جميع المنظمات والجمعيات الشريكة (NGOs Only)</option>
                                <option value="all">كافة المستخدمين في النظام (All Users)</option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">عنوان التنبيه أو التعميم</label>
                            <input type="text" name="title" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded px-3 py-2 text-xs text-zinc-900 dark:text-zinc-100 outline-none" placeholder="مثال: حالة استنفار لفرق الإغاثة في دمشق القديمة">
                        </div>

                        <div>
                            <label class="block text-xs font-medium text-zinc-700 dark:text-zinc-300 mb-1">نص التعميم والتعليمات الميدانية</label>
                            <textarea name="body" rows="4" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 rounded p-2.5 text-xs text-zinc-900 dark:text-zinc-100 outline-none" placeholder="اكتب التعليمات الواضحة المطلوب تنفيذها فوراً من قبل الكوادر..."></textarea>
                        </div>
                    </div>

                    <div class="bg-zinc-50 dark:bg-zinc-800/60 px-6 py-3 border-t border-zinc-200 dark:border-zinc-800 flex items-center justify-end gap-2">
                        <button type="button" @click="broadcastModal = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-xs text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800">
                            إلغاء
                        </button>
                        <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-xs font-medium hover:bg-zinc-800 dark:hover:bg-white">
                            تأكيد وإرسال البث
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

</div>
@endsection
