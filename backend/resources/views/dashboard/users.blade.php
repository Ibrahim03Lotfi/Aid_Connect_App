@extends('layouts.dashboard')

@section('title', 'إدارة المستخدمين والصلاحيات')
@section('page_title', 'إدارة المستخدمين والصلاحيات (Users & Access Control)')

@section('content')
<div class="space-y-6" x-data="{ createModalOpen: false, editModalOpen: false, editingUser: {}, openEdit(u) { this.editingUser = { ...u }; this.editModalOpen = true; } }">

    <!-- Metrics Bar -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">إجمالي الحسابات المسجلة</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ number_format($totalUsers) }}</div>
            <div class="text-[11px] text-zinc-400">كافة المسجلين عبر المنصة والتطبيق</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">إدارة العمليات (Admins)</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ number_format($adminCount) }}</div>
            <div class="text-[11px] text-zinc-400">صلاحيات كاملة للتحكم والتدقيق</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">المتطوعون الميدانيون</div>
            <div class="text-2xl font-semibold font-num text-emerald-700 dark:text-emerald-400">{{ number_format($volunteerCount) }}</div>
            <div class="text-[11px] text-zinc-400">فرق الكشف والتسليم اللاتلامسي</div>
        </div>

        <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg p-4 space-y-1">
            <div class="text-xs text-zinc-500 dark:text-zinc-400 font-medium">المنظمات والجمعيات الشريكة</div>
            <div class="text-2xl font-semibold font-num text-zinc-900 dark:text-zinc-100">{{ number_format($orgCount) }}</div>
            <div class="text-[11px] text-zinc-400">حسابات مؤسسية معتمدة</div>
        </div>
    </div>

    <!-- Users Table -->
    <div class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg overflow-hidden">
        <div class="px-4 py-3 border-b border-zinc-200 dark:border-zinc-800 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div>
                <h3 class="text-xs font-semibold text-zinc-900 dark:text-zinc-100 uppercase tracking-wider">سجل الحسابات والتحكم بالوصول</h3>
                <p class="text-[11px] text-zinc-400 mt-0.5">تعديل الصلاحيات وتفعيل أو تجميد وصول المستخدمين للنظام</p>
            </div>

            <!-- Filters & Search -->
            <div class="flex items-center gap-2">
                <button type="button" @click="createModalOpen = true" class="px-3 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-xs font-medium hover:bg-zinc-800 dark:hover:bg-white flex items-center gap-1.5 transition-colors">
                    <i class="fa-solid fa-user-plus text-[10px]"></i>
                    <span>إضافة مستخدم جديد</span>
                </button>
            </div>

            <!-- Filters & Search -->
            <form action="{{ route('dashboard.users') }}" method="GET" class="flex flex-wrap items-center gap-2 text-xs">
                <input type="text" name="search" value="{{ request('search') }}" placeholder="بحث بالاسم أو الهاتف..." class="bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 text-xs rounded px-2.5 py-1.5 outline-none">

                <select name="role" onchange="this.form.submit()" class="bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 text-xs rounded px-2.5 py-1.5 outline-none">
                    <option value="">جميع الصلاحيات</option>
                    <option value="admin" {{ request('role') == 'admin' ? 'selected' : '' }}>مدير نظام (Admin)</option>
                    <option value="volunteer" {{ request('role') == 'volunteer' ? 'selected' : '' }}>متطوع ميداني (Volunteer)</option>
                    <option value="organization" {{ request('role') == 'organization' ? 'selected' : '' }}>منظمة شريكة (Organization)</option>
                    <option value="donor" {{ request('role') == 'donor' ? 'selected' : '' }}>متبرع / كفيل (Donor)</option>
                    <option value="user" {{ request('role') == 'user' ? 'selected' : '' }}>مستخدم عام (Citizen)</option>
                </select>
            </form>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-right text-xs">
                <thead class="text-zinc-400 border-b border-zinc-100 dark:border-zinc-800 text-[11px]">
                    <tr>
                        <th class="px-4 py-2.5 font-normal">اسم المستخدم والبريد</th>
                        <th class="px-4 py-2.5 font-normal">رقم الهاتف</th>
                        <th class="px-4 py-2.5 font-normal">الدور / الصلاحية</th>
                        <th class="px-4 py-2.5 font-normal">الحالة</th>
                        <th class="px-4 py-2.5 font-normal">تاريخ الانضمام</th>
                        <th class="px-4 py-2.5 text-center font-normal">الإجراءات</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800 text-zinc-700 dark:text-zinc-300">
                    @forelse($users as $u)
                        <tr class="hover:bg-zinc-50 dark:hover:bg-zinc-800/50">
                            <td class="px-4 py-3">
                                <div class="font-medium text-zinc-900 dark:text-zinc-100">{{ $u->name }}</div>
                                <div class="text-[10px] text-zinc-400 font-num">{{ $u->email }}</div>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px] text-zinc-800 dark:text-zinc-200">
                                {{ $u->phone }}
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap">
                                <form action="{{ route('dashboard.users.role', $u->id) }}" method="POST" class="inline-block">
                                    @csrf
                                    <select name="role" onchange="this.form.submit()" class="bg-transparent border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 text-[11px] rounded px-2 py-1 outline-none">
                                        <option value="admin" {{ $u->role === 'admin' ? 'selected' : '' }}>مدير (Admin)</option>
                                        <option value="volunteer" {{ $u->role === 'volunteer' ? 'selected' : '' }}>متطوع (Volunteer)</option>
                                        <option value="organization" {{ $u->role === 'organization' ? 'selected' : '' }}>منظمة (Organization)</option>
                                        <option value="donor" {{ $u->role === 'donor' ? 'selected' : '' }}>متبرع (Donor)</option>
                                        <option value="user" {{ $u->role === 'user' ? 'selected' : '' }}>مواطن (Citizen)</option>
                                    </select>
                                </form>
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-[11px]">
                                @if($u->is_active ?? true)
                                    <span class="text-emerald-700 dark:text-emerald-400 font-medium">نشط ومفعل</span>
                                @else
                                    <span class="text-rose-600 dark:text-rose-400 font-medium">مجمد / موقوف</span>
                                @endif
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap font-num text-[11px] text-zinc-400">
                                {{ $u->created_at?->format('Y-m-d') }}
                            </td>
                            <td class="px-4 py-3 whitespace-nowrap text-center">
                                <div class="flex items-center justify-center gap-1.5">
                                    <button type="button" @click="openEdit({{ json_encode([
                                        'id' => $u->id,
                                        'name' => $u->name,
                                        'email' => $u->email,
                                        'phone' => $u->phone,
                                        'role' => $u->role,
                                    ]) }})" class="px-2 py-1 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 text-[11px]">
                                        تعديل
                                    </button>

                                    <form action="{{ route('dashboard.users.toggle', $u->id) }}" method="POST" class="inline-block">
                                        @csrf
                                        @if($u->is_active ?? true)
                                            <button type="submit" class="px-2 py-1 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600 dark:text-zinc-400 hover:text-amber-600 text-[11px]">
                                                تجميد
                                            </button>
                                        @else
                                            <button type="submit" class="px-2 py-1 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 text-[11px] font-medium">
                                                تفعيل
                                            </button>
                                        @endif
                                    </form>

                                    @if($u->id !== auth()->id())
                                        <form action="{{ route('dashboard.users.destroy', $u->id) }}" method="POST" onsubmit="return confirm('تأكيد حذف هذا المستخدم وسجلاته نهائياً؟');" class="inline-block">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="px-2 py-1 rounded text-rose-600 hover:text-rose-800 text-[11px]">
                                                حذف
                                            </button>
                                        </form>
                                    @endif
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-4 py-8 text-center text-zinc-400">
                                لم يتم العثور على حسابات تطابق البحث
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($users->hasPages())
            <div class="p-3 border-t border-zinc-200 dark:border-zinc-800">
                {{ $users->links() }}
            </div>
        @endif
    </div>


    <!-- Modal 1: Create User Modal -->
    <div x-show="createModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="createModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-md w-full p-5 space-y-3 max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">إنشاء حساب مستخدم جديد</h4>
                <button @click="createModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form action="{{ route('dashboard.users.store') }}" method="POST" class="space-y-3 text-xs">
                @csrf
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">الاسم الكامل</label>
                    <input type="text" name="name" required placeholder="مثال: د. سامر العلي" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">البريد الإلكتروني</label>
                    <input type="email" name="email" required placeholder="samer@athar.sy" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">رقم الهاتف</label>
                        <input type="text" name="phone" required placeholder="09xxxxxxxx" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">الدور والصلاحية</label>
                        <select name="role" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="admin">مدير نظام (Admin)</option>
                            <option value="volunteer" selected>متطوع ميداني (Volunteer)</option>
                            <option value="organization">منظمة شريكة (Organization)</option>
                            <option value="donor">متبرع (Donor)</option>
                            <option value="user">مواطن عام (Citizen)</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">كلمة المرور الافتتاحية</label>
                    <input type="password" name="password" required minlength="6" placeholder="******" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                </div>

                <div class="flex justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
                    <button type="button" @click="createModalOpen = false" class="px-3 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 text-zinc-600">إلغاء</button>
                    <button type="submit" class="px-4 py-1.5 rounded bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-medium">إنشاء الحساب</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 2: Edit User Modal -->
    <div x-show="editModalOpen" x-cloak class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-zinc-950/50 backdrop-blur-sm">
        <div @click.away="editModalOpen = false" class="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-lg max-w-md w-full p-5 space-y-3 max-h-[90vh] overflow-y-auto">
            <div class="flex items-center justify-between border-b border-zinc-100 dark:border-zinc-800 pb-2">
                <h4 class="font-semibold text-zinc-900 dark:text-zinc-100 text-xs">تعديل بيانات المستخدم</h4>
                <button @click="editModalOpen = false" class="text-zinc-400 hover:text-zinc-600 p-1 text-xs"><i class="fa-solid fa-xmark"></i></button>
            </div>

            <form :action="'{{ url('dashboard/users') }}/' + editingUser.id" method="POST" class="space-y-3 text-xs">
                @csrf
                @method('PUT')
                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">الاسم الكامل</label>
                    <input type="text" name="name" x-model="editingUser.name" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">البريد الإلكتروني</label>
                    <input type="email" name="email" x-model="editingUser.email" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                </div>

                <div class="grid grid-cols-2 gap-2">
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">رقم الهاتف</label>
                        <input type="text" name="phone" x-model="editingUser.phone" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
                    </div>
                    <div>
                        <label class="block text-zinc-600 dark:text-zinc-400 mb-1">الدور والصلاحية</label>
                        <select name="role" x-model="editingUser.role" required class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 rounded p-2 outline-none">
                            <option value="admin">مدير نظام (Admin)</option>
                            <option value="volunteer">متطوع ميداني (Volunteer)</option>
                            <option value="organization">منظمة شريكة (Organization)</option>
                            <option value="donor">متبرع (Donor)</option>
                            <option value="user">مواطن عام (Citizen)</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block text-zinc-600 dark:text-zinc-400 mb-1">تغيير كلمة المرور (اتركه فارغاً للإبقاء عليها)</label>
                    <input type="password" name="password" minlength="6" placeholder="******" class="w-full bg-zinc-50 dark:bg-zinc-800 border border-zinc-200 dark:border-zinc-700 text-zinc-800 dark:text-zinc-200 font-num rounded p-2 outline-none">
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
