<!DOCTYPE html>
<html lang="ar" dir="rtl" x-data="{ 
    darkMode: localStorage.getItem('theme') === 'dark',
    sidebarOpen: true,
    mobileOpen: false,
    toggleTheme() {
        this.darkMode = !this.darkMode;
        localStorage.setItem('theme', this.darkMode ? 'dark' : 'light');
        if (this.darkMode) {
            document.documentElement.classList.add('dark');
        } else {
            document.documentElement.classList.remove('dark');
        }
    }
}" x-init="if (darkMode) document.documentElement.classList.add('dark')" :class="{ 'dark': darkMode }">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'مركز قيادة العمليات الإغاثية') | أَثَــر</title>

    <!-- Google Fonts: IBM Plex Sans Arabic + JetBrains Mono -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">

    <!-- FontAwesome 6 Icons (Subdued, monoline usage) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['"IBM Plex Sans Arabic"', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
                        mono: ['"JetBrains Mono"', 'monospace'],
                    },
                    colors: {
                        brand: {
                            50: '#f0fdfa',
                            100: '#ccfbf1',
                            200: '#99f6e4',
                            500: '#14b8a6',
                            600: '#0d9488',
                            700: '#0f766e',
                            800: '#115e59',
                            900: '#134e4a',
                            DEFAULT: '#0f766e',
                            accent: '#059669',
                        }
                    }
                }
            }
        }
    </script>

    <!-- Alpine.js -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.13.5/dist/cdn.min.js"></script>

    <style>
        body {
            font-family: 'IBM Plex Sans Arabic', -apple-system, BlinkMacSystemFont, sans-serif;
            letter-spacing: -0.01em;
        }
        .font-num {
            font-family: 'JetBrains Mono', 'IBM Plex Sans Arabic', monospace;
            font-feature-settings: 'tnum' on;
        }
        [x-cloak] { display: none !important; }
        
        /* Thin, elegant scrollbar */
        ::-webkit-scrollbar { width: 5px; height: 5px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: #d4d4d8; border-radius: 2px; }
        ::-webkit-scrollbar-thumb:hover { background: #a1a1aa; }
        .dark ::-webkit-scrollbar-thumb { background: #27272a; }
        .dark ::-webkit-scrollbar-thumb:hover { background: #3f3f46; }
    </style>

    @yield('styles')
</head>
<body class="bg-zinc-50 dark:bg-zinc-950 text-zinc-900 dark:text-zinc-100 min-h-screen flex antialiased selection:bg-teal-700 selection:text-white dark:selection:bg-teal-600 dark:selection:text-white">

    <!-- Mobile Backdrop -->
    <div x-show="mobileOpen" 
         x-cloak
         @click="mobileOpen = false" 
         class="fixed inset-0 bg-zinc-950/40 backdrop-blur-sm z-40 lg:hidden"></div>

    <!-- Sidebar Navigation -->
    <aside :class="{
        'w-64': sidebarOpen,
        'w-16': !sidebarOpen,
        'translate-x-0': mobileOpen,
        'translate-x-full lg:translate-x-0': !mobileOpen
    }" class="fixed lg:sticky top-0 right-0 h-screen bg-white dark:bg-zinc-900 border-l border-zinc-200 dark:border-zinc-800 flex flex-col justify-between z-50 transition-all duration-200 select-none">

        <div>
            <!-- Organization Branding -->
            <div class="h-14 px-4 border-b border-zinc-200 dark:border-zinc-800 flex items-center justify-between">
                <div class="flex items-center gap-3 overflow-hidden">
                    <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-teal-700 to-emerald-800 text-white flex items-center justify-center font-bold text-sm shrink-0 shadow-sm border border-teal-600/30">
                        أ
                    </div>
                    <div x-show="sidebarOpen" class="transition-opacity">
                        <div class="text-sm font-semibold text-zinc-900 dark:text-zinc-100 leading-none">منصة أَثَـر</div>
                        <div class="text-[10px] text-zinc-400 dark:text-zinc-500 mt-1">نظام العمليات الميدانية</div>
                    </div>
                </div>
                <button @click="sidebarOpen = !sidebarOpen" class="hidden lg:flex text-zinc-400 hover:text-zinc-600 dark:hover:text-zinc-200 p-1 text-xs">
                    <i :class="sidebarOpen ? 'fa-solid fa-chevron-right' : 'fa-solid fa-chevron-left'"></i>
                </button>
                <button @click="mobileOpen = false" class="lg:hidden text-zinc-400 hover:text-zinc-600 p-1 text-sm">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <!-- Operations Status Indicator -->
            <div x-show="sidebarOpen" class="px-4 py-2 border-b border-zinc-100 dark:border-zinc-800/60 flex items-center justify-between text-[11px]">
                <span class="inline-flex items-center gap-2 text-emerald-700 dark:text-emerald-400 font-medium">
                    <span class="relative flex h-2 w-2">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-2 w-2 bg-emerald-600"></span>
                    </span>
                    <span>النظام متصل • العمليات نشطة</span>
                </span>
                <span class="font-num text-[10px] text-zinc-400 bg-zinc-100 dark:bg-zinc-800 px-1.5 py-0.5 rounded">SYR</span>
            </div>

            <!-- Navigation Links -->
            <nav class="p-2 space-y-0.5 text-xs overflow-y-auto max-h-[calc(100vh-7.5rem)]">
                
                <div x-show="sidebarOpen" class="px-3 pt-2 pb-1 text-[10px] font-semibold text-zinc-400 dark:text-zinc-500 uppercase tracking-wider">
                    العمليات والميدان
                </div>

                <!-- 1. Main Dashboard -->
                <a href="{{ route('dashboard.index') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.index') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-regular fa-compass w-4 text-center text-xs {{ request()->routeIs('dashboard.index') ? 'text-teal-700 dark:text-teal-300' : '' }}"></i>
                    <span x-show="sidebarOpen" class="truncate">غرفة العمليات المركزية</span>
                </a>

                <!-- 2. Live GIS Map -->
                <a href="{{ route('dashboard.gis') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.gis') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-map-location-dot w-4 text-center text-xs {{ request()->routeIs('dashboard.gis') ? 'text-teal-700 dark:text-teal-300' : '' }}"></i>
                    <span x-show="sidebarOpen" class="truncate">الخريطة الميدانية (GIS)</span>
                </a>

                <div x-show="sidebarOpen" class="px-3 pt-3 pb-1 text-[10px] font-semibold text-zinc-400 dark:text-zinc-500 uppercase tracking-wider">
                    إدارة الإغاثة والحملات
                </div>

                <!-- 3. Aid Campaigns -->
                <a href="{{ route('dashboard.campaigns') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.campaigns*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-hand-holding-heart w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">حملات الإغاثة والتوزيع</span>
                </a>

                <!-- 4. AI Triage Board -->
                <a href="{{ route('dashboard.cases') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.cases*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-list-check w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">الفرز والتدقيق الذكي</span>
                </a>

                <!-- 5. AI Intelligence & Fraud Lab -->
                <a href="{{ route('dashboard.ai') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.ai*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-microchip w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">مختبر الذكاء الاصطناعي (AI)</span>
                </a>

                <!-- 6. Field Surveys & Assessments -->
                <a href="{{ route('dashboard.assessments') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.assessments*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-house-chimney-crack w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">المعاينات وتقييم السكن</span>
                </a>

                <!-- 7. Emergency Missions -->
                <a href="{{ route('dashboard.missions') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.missions*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-truck-medical w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">مهام الاستجابة الطارئة</span>
                </a>

                <div x-show="sidebarOpen" class="px-3 pt-3 pb-1 text-[10px] font-semibold text-zinc-400 dark:text-zinc-500 uppercase tracking-wider">
                    المستفيدون والمخزون
                </div>

                <!-- 8. Beneficiaries & NFC Hub -->
                <a href="{{ route('dashboard.beneficiaries') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.beneficiaries*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-regular fa-address-card w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">المستفيدون وبطاقات NFC</span>
                </a>

                <!-- 9. NFC Distributions Audit Ledger -->
                <a href="{{ route('dashboard.distributions') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.distributions*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-clipboard-check w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">سجل التوزيع والمطابقة (NFC)</span>
                </a>

                <!-- 10. Logistics & Inventory -->
                <a href="{{ route('dashboard.inventory') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.inventory*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-boxes-stacked w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">المستودعات واللوجستيات</span>
                </a>

                <div x-show="sidebarOpen" class="px-3 pt-3 pb-1 text-[10px] font-semibold text-zinc-400 dark:text-zinc-500 uppercase tracking-wider">
                    الكوادر والشركاء
                </div>

                <!-- 11. Volunteer Roster & Opportunities -->
                <a href="{{ route('dashboard.volunteers') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.volunteers*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-user-group w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">سجل المتطوعين والفرص</span>
                </a>

                <!-- 12. NGO Partners -->
                <a href="{{ route('dashboard.organizations') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.organizations*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-building-shield w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">المنظمات والشركاء</span>
                </a>

                <!-- 13. Users & Access Control -->
                <a href="{{ route('dashboard.users') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.users*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-users-gear w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">إدارة الحسابات والصلاحيات</span>
                </a>

                <div x-show="sidebarOpen" class="px-3 pt-3 pb-1 text-[10px] font-semibold text-zinc-400 dark:text-zinc-500 uppercase tracking-wider">
                    الحوكمة والمالية
                </div>

                <!-- 14. Financial Donations Ledger -->
                <a href="{{ route('dashboard.donations') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.donations*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-receipt w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">الشفافية والتبرعات</span>
                </a>

                <!-- 15. Executive Analytics -->
                <a href="{{ route('dashboard.analytics') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.analytics') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-chart-simple w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">التحليلات الميدانية</span>
                </a>

                <!-- 16. Emergency Broadcast & Notifications -->
                <a href="{{ route('dashboard.notifications') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.notifications*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-bullhorn w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">التعميمات والإشعارات</span>
                </a>

                <!-- 17. System Settings & Diagnostics -->
                <a href="{{ route('dashboard.settings') }}" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors {{ request()->routeIs('dashboard.settings*') ? 'bg-teal-50 text-teal-900 dark:bg-teal-950/60 dark:text-teal-200 font-semibold border-r-2 border-teal-600 dark:border-teal-400' : 'text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100' }}">
                    <i class="fa-solid fa-sliders w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">إعدادات المنظومة والتشخيص</span>
                </a>

                <!-- 18. Official Impact Report -->
                <a href="{{ route('dashboard.reports.annual') }}" target="_blank" 
                   class="flex items-center gap-2.5 px-3 py-2 rounded-md font-medium transition-colors text-zinc-600 dark:text-zinc-400 hover:bg-zinc-100 dark:hover:bg-zinc-800 hover:text-zinc-900 dark:hover:text-zinc-100">
                    <i class="fa-regular fa-file-lines w-4 text-center text-xs"></i>
                    <span x-show="sidebarOpen" class="truncate">تقرير الأثر السنوي</span>
                    <i x-show="sidebarOpen" class="fa-solid fa-arrow-up-right-from-square mr-auto text-[9px] text-zinc-400"></i>
                </a>
            </nav>
        </div>

        <!-- Sidebar Footer -->
        <div class="p-3 border-t border-zinc-200 dark:border-zinc-800">
            <div class="flex items-center justify-between text-xs text-zinc-500 dark:text-zinc-400">
                <div x-show="sidebarOpen" class="truncate">
                    <span class="block font-medium text-zinc-800 dark:text-zinc-200 truncate">إدارة العمليات المركزية</span>
                    <span class="text-[10px] font-num text-zinc-400">v2.4.0 • Enterprise</span>
                </div>
                <button @click="toggleTheme()" class="p-1.5 rounded hover:bg-zinc-100 dark:hover:bg-zinc-800 text-zinc-500 dark:text-zinc-400" title="المظهر">
                    <i class="fa-solid fa-moon dark:hidden text-xs"></i>
                    <i class="fa-solid fa-sun hidden dark:inline text-xs"></i>
                </button>
            </div>
        </div>
    </aside>

    <!-- Main Content Shell -->
    <div class="flex-1 flex flex-col min-w-0">
        
        <!-- Top App Bar -->
        <header class="h-14 bg-white dark:bg-zinc-900 border-b border-zinc-200 dark:border-zinc-800 sticky top-0 z-30 px-4 sm:px-6 flex items-center justify-between">
            <div class="flex items-center gap-3">
                <button @click="mobileOpen = true" class="lg:hidden text-zinc-600 dark:text-zinc-300 p-1.5 text-sm">
                    <i class="fa-solid fa-bars"></i>
                </button>

                <div>
                    <h2 class="text-sm font-semibold text-zinc-900 dark:text-zinc-100">@yield('page_title', 'غرفة العمليات المركزية')</h2>
                </div>
            </div>

            <!-- Top Header Right Actions -->
            <div class="flex items-center gap-3">
                
                <!-- 3D NFC Terminal Simulator Launcher -->
                <button type="button"
                        onclick="window.dispatchEvent(new CustomEvent('open-nfc-simulator'))"
                        class="inline-flex items-center gap-2 text-xs font-semibold text-white bg-gradient-to-r from-teal-700 to-emerald-700 hover:from-teal-600 hover:to-emerald-600 px-3 py-1.5 rounded-md shadow-sm shadow-emerald-950/20 hover:shadow-emerald-500/20 transition-all border border-emerald-400/30">
                    <span class="relative flex h-2 w-2">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-200 opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-2 w-2 bg-white"></span>
                    </span>
                    <i class="fa-solid fa-satellite-dish text-xs"></i>
                    <span class="hidden md:inline">محاكي قارئ NFC ثلاثي الأبعاد</span>
                    <span class="md:hidden">قارئ NFC</span>
                </button>

                <!-- Printable Impact Report -->
                <a href="{{ route('dashboard.reports.annual') }}" target="_blank" 
                   class="hidden sm:inline-flex items-center gap-1.5 text-xs text-zinc-700 dark:text-zinc-300 hover:text-teal-700 dark:hover:text-teal-300 hover:border-teal-300 dark:hover:border-teal-700 px-2.5 py-1.5 rounded border border-zinc-200 dark:border-zinc-700 bg-white dark:bg-zinc-800 transition-colors">
                    <i class="fa-regular fa-file-pdf text-xs text-rose-600"></i>
                    <span>تصدير تقرير الأثر الإنساني</span>
                </a>

                <!-- Emergency Contact Pill -->
                <div class="inline-flex items-center gap-1.5 text-xs text-rose-700 dark:text-rose-400 font-num bg-rose-50 dark:bg-rose-950/40 px-2.5 py-1 rounded border border-rose-200/80 dark:border-rose-900/60 font-medium">
                    <span class="w-1.5 h-1.5 rounded-full bg-rose-500 animate-pulse"></span>
                    <span>غرفة الطوارئ: 110-إغاثة</span>
                </div>
            </div>
        </header>

        <!-- Flash Messages -->
        @if(session('success') || session('warning') || session('error'))
            <div class="px-4 sm:px-6 pt-4">
                @if(session('success'))
                    <div class="bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 px-4 py-3 rounded-md text-xs flex items-center justify-between">
                        <span>{{ session('success') }}</span>
                        <button onclick="this.parentElement.remove()" class="text-zinc-400 hover:text-white dark:hover:text-zinc-900 text-xs mr-3"><i class="fa-solid fa-xmark"></i></button>
                    </div>
                @endif
                @if(session('warning'))
                    <div class="bg-amber-50 border border-amber-200 text-amber-900 px-4 py-3 rounded-md text-xs flex items-center justify-between">
                        <span>{{ session('warning') }}</span>
                        <button onclick="this.parentElement.remove()" class="text-amber-600 hover:text-amber-900 text-xs mr-3"><i class="fa-solid fa-xmark"></i></button>
                    </div>
                @endif
                @if(session('error'))
                    <div class="bg-rose-50 border border-rose-200 text-rose-900 px-4 py-3 rounded-md text-xs flex items-center justify-between">
                        <span>{{ session('error') }}</span>
                        <button onclick="this.parentElement.remove()" class="text-rose-600 hover:text-rose-900 text-xs mr-3"><i class="fa-solid fa-xmark"></i></button>
                    </div>
                @endif
            </div>
        @endif

        <!-- Main Content Area -->
        <main class="p-4 sm:p-6 flex-1 space-y-6">
            @yield('content')
        </main>

        <!-- Footer -->
        <footer class="border-t border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 px-4 sm:px-6 py-3 text-xs text-zinc-400 flex flex-col sm:flex-row items-center justify-between gap-2">
            <span>منصة أَثَــر للإغاثة والتنمية • نظام التوثيق والرقابة اللاتلامسي المعتمد (NFC) • 2026</span>
            <span class="font-num text-[11px]">Syrian Operations Ledger</span>
        </footer>
    </div>

    @yield('scripts')

    <!-- 3D Interactive NFC Hardware Terminal Simulator Global Component -->
    @include('dashboard.components.nfc-3d-simulator')
</body>
</html>
