<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>التحقق الرسمي من جواز السفر التطوعي — منظمة أثر</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800;900&family=IBM+Plex+Sans+Arabic:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Cairo', 'IBM Plex Sans Arabic', sans-serif; }
    </style>
</head>
<body class="bg-slate-900 text-slate-100 min-h-screen flex items-center justify-center p-4">
    <div class="max-w-lg w-full bg-slate-800/90 border border-slate-700/80 rounded-3xl p-6 md:p-8 shadow-2xl backdrop-blur-xl relative overflow-hidden">
        <!-- Gold Accent Glow -->
        <div class="absolute -top-24 -right-24 w-48 h-48 bg-amber-500/20 rounded-full blur-3xl pointer-events-none"></div>
        <div class="absolute -bottom-24 -left-24 w-48 h-48 bg-sky-500/20 rounded-full blur-3xl pointer-events-none"></div>

        <!-- Official Header -->
        <div class="text-center space-y-2 mb-6">
            <div class="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-amber-400 to-amber-600 shadow-lg shadow-amber-500/30 text-white mb-2">
                <svg class="w-9 h-9" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                </svg>
            </div>
            <div class="inline-block px-3 py-1 bg-emerald-500/20 border border-emerald-500/40 rounded-full text-emerald-400 text-xs font-bold tracking-wide">
                ✓ سجل معتمد وموثق رسمياً
            </div>
            <h1 class="text-xl md:text-2xl font-black text-white">منظمة أثر للإغاثة والتنمية</h1>
            <p class="text-xs text-slate-400">بوابة التحقق الرقمي المركزي من وثائق المتطوعين الميدانيين</p>
        </div>

        <!-- Volunteer Credentials Card -->
        <div class="bg-slate-900/80 border border-slate-700/60 rounded-2xl p-5 space-y-4 mb-6">
            <div class="flex items-center justify-between border-b border-slate-800 pb-3">
                <span class="text-xs text-slate-400 font-medium">اسم المتطوع المعتمد:</span>
                <span class="text-sm font-bold text-white">{{ $volunteer->name }}</span>
            </div>
            <div class="flex items-center justify-between border-b border-slate-800 pb-3">
                <span class="text-xs text-slate-400 font-medium">الرتبة الميدانية:</span>
                <span class="text-xs font-bold px-2.5 py-1 bg-amber-500/10 border border-amber-500/30 text-amber-400 rounded-lg">
                    {{ $rank }}
                </span>
            </div>
            <div class="flex items-center justify-between border-b border-slate-800 pb-3">
                <span class="text-xs text-slate-400 font-medium">الساعات الميدانية المعتمدة:</span>
                <span class="text-base font-black text-sky-400">{{ number_format($volunteer->volunteer_hours ?? 0, 1) }} ساعة</span>
            </div>
            <div class="flex items-center justify-between border-b border-slate-800 pb-3">
                <span class="text-xs text-slate-400 font-medium">مجموع نقاط العطاء (Points):</span>
                <span class="text-sm font-bold text-emerald-400">{{ number_format($volunteer->volunteer_points ?? 0) }} نقطة</span>
            </div>
            <div class="flex items-center justify-between">
                <span class="text-xs text-slate-400 font-medium">تاريخ الانضمام:</span>
                <span class="text-xs text-slate-300 font-mono">{{ $volunteer->created_at->format('Y-m-d') }}</span>
            </div>
        </div>

        <!-- Trust & Security Seal -->
        <div class="p-4 bg-gradient-to-r from-sky-950/40 to-slate-900 border border-sky-800/40 rounded-2xl flex items-center gap-3 mb-6">
            <div class="w-10 h-10 rounded-xl bg-sky-500/20 text-sky-400 flex items-center justify-center shrink-0">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                </svg>
            </div>
            <div class="text-right">
                <div class="text-xs font-bold text-sky-300">توثيق مشفر بتقنية SHA-256</div>
                <div class="text-[11px] text-slate-400">هذه الشهادة صادرة من نظام Athar Humanitarian OS ولا تقبل التزوير أو التكرار.</div>
            </div>
        </div>

        <!-- Action / Footer -->
        <div class="text-center">
            <a href="{{ route('dashboard.index') }}" class="inline-flex items-center justify-center w-full py-3 px-4 bg-sky-600 hover:bg-sky-500 text-white rounded-xl text-xs font-bold transition shadow-lg shadow-sky-600/30">
                الدخول لغرفة عمليات أثر المركزية
            </a>
            <p class="text-[10px] text-slate-500 mt-3">منظومة أثر الذكية — الجمهورية العربية السورية © {{ date('Y') }}</p>
        </div>
    </div>
</body>
</html>
