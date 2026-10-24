<!-- 3D Interactive NFC Hardware Terminal Simulator Component (Single-Screen Centered UI/UX) -->
<div x-data="nfcSimulator()" 
     x-cloak 
     @open-nfc-simulator.window="openModal($event.detail)"
     @keydown.escape.window="closeModal()">

    <!-- Modal Backdrop & Stage -->
    <div x-show="isOpen" 
         x-transition:enter="transition ease-out duration-300"
         x-transition:enter-start="opacity-0"
         x-transition:enter-end="opacity-100"
         x-transition:leave="transition ease-in duration-200"
         x-transition:leave-start="opacity-100"
         x-transition:leave-end="opacity-0"
         class="fixed inset-0 z-50 bg-zinc-950/85 backdrop-blur-md flex items-center justify-center p-2 sm:p-4 overflow-hidden">

        <!-- Main Single-Screen Terminal Window (Fits screen height without scrolling) -->
        <div @click.outside="closeModal()" 
             class="bg-gradient-to-b from-zinc-900 via-zinc-900 to-zinc-950 border border-zinc-700/80 rounded-2xl w-full max-w-4xl shadow-2xl overflow-hidden flex flex-col text-zinc-100 relative max-h-[92vh] h-[860px]">
            
            <!-- 1. Sleek Top Bar (Title + Selectors + Controls) -->
            <div class="px-5 py-3 bg-zinc-900/95 border-b border-zinc-800/80 flex flex-wrap items-center justify-between gap-3 shrink-0">
                
                <!-- Terminal Identity -->
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-lg bg-gradient-to-br from-emerald-500 to-teal-700 flex items-center justify-center text-white shadow-md shadow-emerald-900/30">
                        <i class="fa-solid fa-tower-broadcast text-xs"></i>
                    </div>
                    <div>
                        <div class="flex items-center gap-2">
                            <h3 class="text-xs font-bold text-white tracking-wide">أَثَــر • محطة التحقق اللاتلامسية الذكية</h3>
                            <span class="font-mono text-[9px] bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 px-1.5 py-0.2 rounded-full">3D Terminal</span>
                        </div>
                        <p class="text-[10px] text-zinc-400">منع الازدواجية والصرف الوهمي في الميدان ببطاقات RFID الذكية</p>
                    </div>
                </div>

                <!-- Inline Quick Switchers (Campaign & Beneficiary) -->
                <div class="flex items-center gap-2 text-xs flex-1 max-w-xl justify-end">
                    
                    <!-- Campaign Dropdown -->
                    <div class="relative w-44 sm:w-56">
                        <select x-model="selectedCampaignId" 
                                class="w-full bg-zinc-800/90 border border-zinc-700 hover:border-zinc-600 rounded-lg px-2.5 py-1.5 text-[11px] text-zinc-200 outline-none focus:border-emerald-500 transition-colors truncate">
                            <template x-for="camp in campaigns" :key="camp.id">
                                <option :value="camp.id" x-text="camp.title"></option>
                            </template>
                        </select>
                    </div>

                    <!-- Beneficiary Dropdown -->
                    <div class="relative w-48 sm:w-60">
                        <select x-model="selectedBeneficiaryId" 
                                @change="onBeneficiaryChange()"
                                class="w-full bg-zinc-800/90 border border-zinc-700 hover:border-zinc-600 rounded-lg px-2.5 py-1.5 text-[11px] text-zinc-200 outline-none focus:border-emerald-500 transition-colors truncate">
                            <template x-for="b in beneficiaries" :key="b.id">
                                <option :value="b.id" x-text="b.name + ' (' + b.district + ')'"></option>
                            </template>
                            <option value="unknown_fraud">⚠️ شريحة مجهولة (تجربة احتيال)</option>
                        </select>
                    </div>

                    <!-- Sound Toggle -->
                    <button @click="toggleSound()" 
                            class="p-1.5 rounded-lg border border-zinc-700 hover:border-zinc-600 text-zinc-300 transition-colors"
                            :class="{ 'bg-zinc-800 text-emerald-400': soundEnabled, 'bg-zinc-900 text-zinc-500': !soundEnabled }"
                            title="تبديل الصوت">
                        <i class="fa-solid text-xs" :class="soundEnabled ? 'fa-volume-high' : 'fa-volume-xmark'"></i>
                    </button>

                    <!-- Close -->
                    <button @click="closeModal()" class="w-7 h-7 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-zinc-400 hover:text-white flex items-center justify-center transition-colors">
                        <i class="fa-solid fa-xmark text-xs"></i>
                    </button>
                </div>
            </div>

            <!-- 2. Prime 3D Physical Stage (Center Hero Area) -->
            <div class="flex-1 flex flex-col items-center justify-between p-4 relative overflow-hidden select-none"
                 style="perspective: 1200px;"
                 @mousemove="handleCardTilt($event)"
                 @mouseleave="resetCardTilt()">

                <!-- Ambient Cyber Grid & Glow -->
                <div class="absolute inset-0 bg-[radial-gradient(#10b981_1px,transparent_1px)] [background-size:28px_28px] opacity-10 pointer-events-none"></div>
                <div class="absolute w-96 h-96 rounded-full bg-emerald-500/5 blur-3xl pointer-events-none"></div>

                <!-- Top Telemetry Pill -->
                <div class="relative z-10 flex items-center gap-2 bg-zinc-900/90 border border-zinc-800/80 px-3 py-1 rounded-full text-[10px] font-mono shadow-sm">
                    <span class="w-2 h-2 rounded-full transition-colors duration-300"
                          :class="{
                              'bg-cyan-400 animate-pulse': stageStatus === 'ready',
                              'bg-amber-400 animate-ping': stageStatus === 'tapping',
                              'bg-emerald-400 shadow-md shadow-emerald-400/80': stageStatus === 'success',
                              'bg-rose-500 shadow-md shadow-rose-500/80': stageStatus === 'error'
                          }"></span>
                    <span x-text="stageStatusText" class="text-zinc-300"></span>
                </div>

                <!-- ================= 3D CARD HERO OBJECT ================= -->
                <div class="relative z-20 cursor-pointer transition-all duration-700 ease-out my-auto"
                     :style="cardTransformStyle"
                     @click="triggerTap()"
                     title="انقر لتمرير البطاقة وفحصها على القارئ">
                    
                    <!-- Physical Card (ISO/IEC Standard Dimensions) -->
                    <div class="w-[330px] sm:w-[360px] h-[200px] sm:h-[215px] rounded-2xl p-5 relative overflow-hidden shadow-2xl border border-teal-500/40 bg-gradient-to-br from-zinc-900 via-zinc-950 to-teal-950/90 transition-all duration-300 group hover:border-emerald-400 hover:shadow-emerald-500/30">
                        
                        <!-- Damascus Subtle Geometry Watermark -->
                        <div class="absolute inset-0 bg-[radial-gradient(circle_at_50%_120%,rgba(20,184,166,0.18),transparent)] pointer-events-none"></div>
                        <div class="absolute top-0 right-0 w-36 h-36 bg-gradient-to-bl from-emerald-500/10 to-transparent rounded-bl-full pointer-events-none"></div>
                        
                        <!-- Card Header -->
                        <div class="flex items-start justify-between relative z-10">
                            <div class="flex items-center gap-2">
                                <div class="w-6 h-6 rounded bg-emerald-500/20 text-emerald-400 border border-emerald-400/30 flex items-center justify-center text-[10px] font-bold">
                                    أ
                                </div>
                                <div>
                                    <div class="text-[11px] font-bold tracking-tight text-white">منصة أَثَــر للإغاثة والتنمية</div>
                                    <div class="text-[8px] tracking-wider text-emerald-400 uppercase font-mono">Syrian Aid Smart Card</div>
                                </div>
                            </div>
                            <div class="flex items-center gap-1.5 text-emerald-400 text-xs">
                                <i class="fa-solid fa-wifi rotate-90 text-[13px] opacity-90"></i>
                                <span class="text-[9px] font-mono tracking-widest font-semibold">NFC</span>
                            </div>
                        </div>

                        <!-- Card Middle: Golden EMV Chip & Security Hologram -->
                        <div class="flex items-center justify-between my-3 relative z-10">
                            <!-- Metallic Golden Chip -->
                            <div class="w-11 h-9 rounded-md bg-gradient-to-br from-amber-200 via-amber-400 to-yellow-600 p-0.5 shadow-md shadow-amber-950/40 border border-amber-300 flex flex-col justify-between overflow-hidden">
                                <div class="w-full h-[1px] bg-amber-700/60 mt-2"></div>
                                <div class="w-full h-[1px] bg-amber-700/60 mb-2"></div>
                                <div class="absolute inset-y-0 left-1/2 w-[1px] bg-amber-700/60"></div>
                            </div>

                            <!-- Security Hologram Seal -->
                            <div class="w-10 h-10 rounded-full border border-teal-400/40 bg-gradient-to-tr from-teal-500/20 via-emerald-400/10 to-transparent flex items-center justify-center">
                                <i class="fa-solid fa-shield-heart text-teal-300 text-xs"></i>
                            </div>
                        </div>

                        <!-- Card Details (Beneficiary Name, National ID, UID - NO "درجة الاحتياج") -->
                        <div class="relative z-10 space-y-1.5">
                            <div class="text-xs font-bold text-white tracking-wide truncate" x-text="selectedBeneficiary ? selectedBeneficiary.name : 'محمد أحمد الصالح (أبو أحمد)'"></div>
                            
                            <div class="flex items-center justify-between text-[10px] font-mono text-zinc-400">
                                <span>الرقم الوطني: <strong class="text-zinc-200 font-bold" x-text="selectedBeneficiary ? selectedBeneficiary.national_id : '01010045891'"></strong></span>
                                <span class="text-teal-300" x-text="selectedBeneficiary ? selectedBeneficiary.district : 'جرمانا - ريف دمشق'"></span>
                            </div>

                            <div class="flex items-center justify-between pt-1.5 border-t border-zinc-800/80 text-[9px] font-mono text-zinc-400">
                                <span class="text-zinc-300 tracking-wider" x-text="'UID: ' + (selectedBeneficiary ? selectedBeneficiary.nfc_uid : '04:A2:3B:5C:8D:1E:80')"></span>
                                <span class="text-emerald-400 font-semibold" x-text="(selectedBeneficiary ? selectedBeneficiary.family_members : '6') + ' أفراد'"></span>
                            </div>
                        </div>

                        <!-- Metallic Light Specular Gloss Reflection -->
                        <div class="absolute inset-0 bg-gradient-to-tr from-white/0 via-white/5 to-white/0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none"></div>
                    </div>

                    <!-- Dynamic Depth Shadow -->
                    <div class="w-64 h-3 mx-auto rounded-full bg-emerald-500/15 blur-md mt-2 transition-all duration-300"
                         :class="{ 'scale-75 opacity-40': stageStatus === 'ready', 'scale-125 opacity-90 bg-emerald-400/40': stageStatus === 'success' }"></div>
                </div>

                <!-- ================= 3D POS FIELD TERMINAL SCANNER BASE ================= -->
                <div class="relative z-10 w-[300px] sm:w-[340px] bg-gradient-to-b from-zinc-800 via-zinc-900 to-zinc-950 rounded-2xl p-4 border-2 border-zinc-700 shadow-2xl transition-all duration-500"
                     :class="{
                         'border-teal-500/50 shadow-teal-500/20': stageStatus === 'ready',
                         'border-amber-500/80 shadow-amber-500/30 scale-[1.02]': stageStatus === 'tapping',
                         'border-emerald-500 shadow-emerald-500/40': stageStatus === 'success',
                         'border-rose-500 shadow-rose-500/40': stageStatus === 'error'
                     }">

                    <!-- OLED Graphic Display Screen -->
                    <div class="bg-black/95 border border-zinc-800 rounded-lg p-2.5 mb-3 shadow-inner text-center font-mono">
                        <div class="flex items-center justify-between text-[8px] text-zinc-500 mb-0.5">
                            <span>ATHAR-POS-DAMASCUS-01</span>
                            <span class="flex items-center gap-1 text-emerald-400">
                                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse"></span>
                                <span>ONLINE</span>
                            </span>
                        </div>
                        <div class="text-[11px] font-bold transition-all duration-300 py-0.5 tracking-wide"
                             :class="{
                                 'text-cyan-400': stageStatus === 'ready',
                                 'text-amber-300 animate-pulse': stageStatus === 'tapping',
                                 'text-emerald-400': stageStatus === 'success',
                                 'text-rose-400': stageStatus === 'error'
                             }"
                             x-text="terminalScreenMessage">
                        </div>
                        <div class="text-[8px] text-zinc-500 font-mono truncate" x-text="terminalScreenSubtext"></div>
                    </div>

                    <!-- Contactless Target Bezel & Antenna Field Rings -->
                    <div class="relative w-28 h-28 mx-auto rounded-full bg-zinc-900 border-2 border-dashed border-zinc-600 flex items-center justify-center overflow-hidden transition-colors duration-300"
                         :class="{
                             'border-emerald-500/80 bg-emerald-950/30': stageStatus === 'success',
                             'border-rose-500/80 bg-rose-950/30': stageStatus === 'error',
                             'border-amber-400/80 bg-amber-950/20': stageStatus === 'tapping'
                         }">
                        
                        <!-- Pulsing Waves -->
                        <template x-if="stageStatus === 'ready' || stageStatus === 'tapping'">
                            <div class="absolute inset-0 flex items-center justify-center pointer-events-none">
                                <span class="absolute w-24 h-24 rounded-full border border-teal-500/30 animate-ping"></span>
                                <span class="absolute w-16 h-16 rounded-full border border-teal-400/40 animate-pulse"></span>
                            </div>
                        </template>

                        <!-- Success Icon Burst -->
                        <template x-if="stageStatus === 'success'">
                            <div class="absolute inset-0 bg-emerald-500/20 flex items-center justify-center animate-pulse">
                                <i class="fa-solid fa-check text-3xl text-emerald-400"></i>
                            </div>
                        </template>

                        <!-- Error Icon Burst -->
                        <template x-if="stageStatus === 'error'">
                            <div class="absolute inset-0 bg-rose-500/20 flex items-center justify-center animate-pulse">
                                <i class="fa-solid fa-ban text-3xl text-rose-400"></i>
                            </div>
                        </template>

                        <!-- Center Target Glyph -->
                        <div x-show="stageStatus === 'ready' || stageStatus === 'tapping'" class="flex flex-col items-center text-zinc-400">
                            <i class="fa-solid fa-fingerprint text-2xl mb-0.5 transition-colors"
                               :class="stageStatus === 'tapping' ? 'text-amber-400' : 'text-teal-400'"></i>
                            <span class="text-[8px] font-mono tracking-wider text-zinc-400 font-semibold">حساس NFC</span>
                        </div>
                    </div>

                    <!-- Sensor Status LED -->
                    <div class="flex items-center justify-center gap-1.5 mt-2.5 pt-2 border-t border-zinc-800 text-[9px] font-mono text-zinc-400">
                        <span class="w-2 h-2 rounded-full shadow-sm transition-colors duration-300"
                              :class="{
                                  'bg-cyan-400 shadow-cyan-500/80': stageStatus === 'ready',
                                  'bg-amber-400 shadow-amber-500/80 animate-ping': stageStatus === 'tapping',
                                  'bg-emerald-400 shadow-emerald-500/80': stageStatus === 'success',
                                  'bg-rose-500 shadow-rose-500/80': stageStatus === 'error'
                              }"></span>
                        <span x-text="ledStatusLabel"></span>
                    </div>
                </div>

                <!-- ================= 3. INLINE COMPACT HUD RESULT (NO SCROLLING) ================= -->
                <div class="relative z-20 w-full max-w-xl mt-3 shrink-0">
                    
                    <!-- Ready Action Button -->
                    <div x-show="!lastReceipt && !lastError" class="flex flex-col items-center gap-2">
                        <button @click="triggerTap()" 
                                :disabled="stageStatus === 'tapping'"
                                class="bg-gradient-to-r from-emerald-600 via-teal-600 to-emerald-600 hover:from-emerald-500 hover:to-teal-500 text-white font-bold py-2.5 px-6 rounded-xl shadow-lg shadow-emerald-950/40 border border-emerald-400/40 flex items-center gap-2 transition-all transform active:scale-95 disabled:opacity-50 text-xs">
                            <i class="fa-solid fa-satellite-dish text-xs" :class="{ 'animate-spin': stageStatus === 'tapping' }"></i>
                            <span x-text="stageStatus === 'tapping' ? 'جاري فحص الشريحة والتحقق من منع الازدواجية...' : '⚡ انقر هنا أو على البطاقة للتمرير (Tap Card)'"></span>
                        </button>
                        <p class="text-[10px] text-zinc-500">ميزة الحوكمة الرقمية: تمنع المنظومة صرف أكثر من طرد لنفس المستفيد في ذات الحملة</p>
                    </div>

                    <!-- SUCCESS SLIP OVERLAY (Compact inline banner) -->
                    <div x-show="lastReceipt" 
                         x-transition:enter="transition ease-out duration-300"
                         x-transition:enter-start="opacity-0 transform -translate-y-2"
                         x-transition:enter-end="opacity-100 transform translate-y-0"
                         class="bg-zinc-950/95 border border-emerald-500/50 rounded-xl p-3 shadow-xl flex flex-col sm:flex-row items-center justify-between gap-3 font-mono text-[11px]">
                        
                        <div class="flex items-center gap-2.5">
                            <div class="w-8 h-8 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">
                                <i class="fa-solid fa-check text-sm"></i>
                            </div>
                            <div>
                                <div class="flex items-center gap-2">
                                    <span class="font-bold text-white">تم التحقق والصرف اللاتلامسي بنجاح ✓</span>
                                    <span class="text-[9px] bg-emerald-500/20 text-emerald-300 px-1.5 py-0.2 rounded border border-emerald-500/30">NFC VERIFIED</span>
                                </div>
                                <div class="text-[10px] text-zinc-400 flex items-center gap-2 mt-0.5">
                                    <span>المستفيد: <strong class="text-zinc-200" x-text="lastReceipt ? lastReceipt.beneficiary.name : ''"></strong></span>
                                    <span>•</span>
                                    <span class="text-teal-300 font-bold" x-text="lastReceipt ? lastReceipt.receipt.token : ''"></span>
                                    <span>•</span>
                                    <span class="text-emerald-400" x-text="lastReceipt && lastReceipt.inventory.remaining_stock !== null ? ('المتبقي بالمخزن: ' + lastReceipt.inventory.remaining_stock) : ''"></span>
                                </div>
                            </div>
                        </div>

                        <div class="flex items-center gap-2 shrink-0">
                            <button @click="printReceipt()" class="text-xs px-2.5 py-1.5 rounded-lg border border-zinc-700 hover:border-zinc-500 text-zinc-300 hover:text-white flex items-center gap-1 transition-colors">
                                <i class="fa-solid fa-print text-[10px]"></i>
                                <span>طباعة السند</span>
                            </button>
                            <button @click="resetSimulator()" class="text-xs px-2.5 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white font-semibold flex items-center gap-1 transition-colors">
                                <i class="fa-solid fa-rotate-left text-[10px]"></i>
                                <span>فحص بطاقة أخرى</span>
                            </button>
                        </div>
                    </div>

                    <!-- ANTI-FRAUD DUPLICATE DETECTED BANNER -->
                    <div x-show="lastError" 
                         x-transition:enter="transition ease-out duration-300"
                         x-transition:enter-start="opacity-0 transform -translate-y-2"
                         x-transition:enter-end="opacity-100 transform translate-y-0"
                         class="bg-rose-950/80 border border-rose-500/80 rounded-xl p-3 shadow-xl flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-rose-200">
                        
                        <div class="flex items-center gap-2.5">
                            <div class="w-8 h-8 rounded-full bg-rose-500/20 text-rose-400 flex items-center justify-center shrink-0">
                                <i class="fa-solid fa-ban text-sm"></i>
                            </div>
                            <div>
                                <div class="font-bold text-rose-300 flex items-center gap-2">
                                    <span x-text="lastError ? lastError.title : 'فشل عملية الصرف'"></span>
                                    <span class="text-[9px] bg-rose-500/20 text-rose-300 px-1.5 py-0.2 rounded border border-rose-500/40 font-mono">BLOCKED</span>
                                </div>
                                <p class="text-[10px] text-rose-300/90 mt-0.5 line-clamp-1" x-text="lastError ? lastError.message : ''"></p>
                            </div>
                        </div>

                        <button @click="resetSimulator()" class="text-xs px-3 py-1.5 rounded-lg bg-rose-900/60 hover:bg-rose-800 text-rose-200 border border-rose-700/60 font-semibold flex items-center gap-1 shrink-0 transition-colors">
                            <i class="fa-solid fa-rotate-left text-[10px]"></i>
                            <span>إعادة التجربة</span>
                        </button>
                    </div>

                </div>

            </div>

        </div>
    </div>
</div>

<script>
function nfcSimulator() {
    return {
        isOpen: false,
        soundEnabled: true,
        beneficiaries: [],
        campaigns: [],
        selectedBeneficiaryId: null,
        selectedBeneficiary: null,
        selectedCampaignId: null,
        
        // Stage Physics & Visuals
        stageStatus: 'ready', // 'ready', 'tapping', 'success', 'error'
        stageStatusText: 'جاهز للقراءة اللاتلامسية (13.56 MHz RFID)',
        terminalScreenMessage: '>> READY TO SCAN <<',
        terminalScreenSubtext: 'HOVER OR CLICK CARD TO DISBURSE',
        ledStatusLabel: 'حالة الحساس: انتظار التردد (Standby)',
        
        // 3D Card tilt dynamic variables
        tiltX: 0,
        tiltY: 0,
        isTappingAnim: false,

        // Output Payloads
        lastReceipt: null,
        lastError: null,

        // Web Audio Synthesizer Context
        audioCtx: null,

        init() {
            this.fetchSimulatorData();
        },

        async fetchSimulatorData() {
            try {
                const res = await fetch('{{ route("dashboard.distributions.nfc-data") }}');
                const data = await res.json();
                if (data.success) {
                    this.beneficiaries = data.beneficiaries;
                    this.campaigns = data.campaigns;

                    if (this.beneficiaries.length > 0) {
                        this.selectedBeneficiaryId = this.beneficiaries[0].id;
                        this.selectedBeneficiary = this.beneficiaries[0];
                    }
                    if (this.campaigns.length > 0) {
                        this.selectedCampaignId = this.campaigns[0].id;
                    }
                }
            } catch (err) {
                console.warn('NFC Simulator data fetch failed', err);
            }
        },

        openModal(detail) {
            this.isOpen = true;
            this.resetSimulator();
            if (detail && detail.beneficiary_id) {
                this.selectedBeneficiaryId = detail.beneficiary_id;
                this.onBeneficiaryChange();
            }
        },

        closeModal() {
            this.isOpen = false;
            this.resetSimulator();
        },

        toggleSound() {
            this.soundEnabled = !this.soundEnabled;
        },

        onBeneficiaryChange() {
            if (this.selectedBeneficiaryId === 'unknown_fraud') {
                this.selectedBeneficiary = {
                    name: 'شريحة غير معتمدة (Unknown Rogue NFC Chip)',
                    national_id: '99999999999',
                    family_members: 0,
                    district: 'مجهول الهوية',
                    governorate: 'خارج المنظومة',
                    nfc_uid: 'DEAD:BEEF:CAFE:01',
                    qr_token: 'ROGUE-NFC-ATTACK',
                };
            } else {
                this.selectedBeneficiary = this.beneficiaries.find(b => b.id == this.selectedBeneficiaryId) || this.beneficiaries[0];
            }
            this.lastReceipt = null;
            this.lastError = null;
            this.resetStageVisuals();
        },

        handleCardTilt(e) {
            if (this.isTappingAnim) return;
            const rect = e.currentTarget.getBoundingClientRect();
            const x = e.clientX - rect.left - (rect.width / 2);
            const y = e.clientY - rect.top - (rect.height / 2);
            this.tiltX = -(y / rect.height) * 18; // smooth tilt
            this.tiltY = (x / rect.width) * 18;
        },

        resetCardTilt() {
            if (this.isTappingAnim) return;
            this.tiltX = 0;
            this.tiltY = 0;
        },

        get cardTransformStyle() {
            if (this.isTappingAnim) {
                // Realistic multi-axis descent onto the reader bezel
                return 'transform: translateY(140px) translateZ(50px) rotateX(66deg) rotateY(0deg) rotateZ(1.5deg) scale(0.95); transition: transform 0.65s cubic-bezier(0.25, 1, 0.5, 1);';
            }
            return `transform: rotateX(${this.tiltX}deg) rotateY(${this.tiltY}deg); transition: transform 0.2s ease-out;`;
        },

        resetStageVisuals() {
            this.stageStatus = 'ready';
            this.stageStatusText = 'جاهز للقراءة اللاتلامسية (13.56 MHz RFID)';
            this.terminalScreenMessage = '>> READY TO SCAN <<';
            this.terminalScreenSubtext = 'HOVER OR CLICK CARD TO DISBURSE';
            this.ledStatusLabel = 'حالة الحساس: انتظار التردد (Standby)';
            this.isTappingAnim = false;
        },

        resetSimulator() {
            this.resetStageVisuals();
            this.lastReceipt = null;
            this.lastError = null;
        },

        async triggerTap() {
            if (this.stageStatus === 'tapping') return;

            // 1. Realistic Smooth Approach Physics
            this.isTappingAnim = true;
            this.stageStatus = 'tapping';
            this.stageStatusText = 'جاري التحقق اللاتلامسي والمطابقة السحابية...';
            this.terminalScreenMessage = 'READING RFID SECTORS...';
            this.terminalScreenSubtext = 'TRANSMITTING VIA SECURE FIELD BUS';
            this.ledStatusLabel = 'حالة الحساس: قراءة المجال الكهرومغناطيسي (Scanning)';
            this.lastReceipt = null;
            this.lastError = null;

            this.playRfChirp();

            const cardUid = this.selectedBeneficiary ? this.selectedBeneficiary.nfc_uid : '04:A2:3B:5C:8D:1E:80';

            // Natural hardware contact handshake delay (550ms)
            await new Promise(r => setTimeout(r, 550));

            try {
                const csrfToken = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content');
                const response = await fetch('{{ route("dashboard.distributions.simulate-nfc-tap") }}', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': csrfToken,
                        'Accept': 'application/json',
                    },
                    body: JSON.stringify({
                        card_uid: cardUid,
                        campaign_id: this.selectedCampaignId,
                        latitude: 33.5138,
                        longitude: 36.2765,
                    })
                });

                const result = await response.json();

                if (response.ok && result.success) {
                    this.stageStatus = 'success';
                    this.stageStatusText = 'تم التحقق والصرف اللاتلامسي بنجاح ✓';
                    this.terminalScreenMessage = 'GRANTED: 1 PACKAGE DISBURSED';
                    this.terminalScreenSubtext = 'AUTHENTICATED • SHA-256 HASH STORED';
                    this.ledStatusLabel = 'حالة الحساس: تم الاعتماد والتسليم (Success)';
                    this.lastReceipt = result;

                    this.playBeepSuccess();
                } else {
                    this.stageStatus = 'error';
                    this.stageStatusText = result.title || 'تم إحباط عملية الصرف!';
                    this.terminalScreenMessage = result.status_code === 'DUPLICATE_BLOCKED' ? 'ALERT: DUPLICATE BLOCKED' : 'ACCESS DENIED';
                    this.terminalScreenSubtext = result.status_code === 'DUPLICATE_BLOCKED' ? 'DOUBLE DIPPING PREVENTED' : (result.message || 'INVALID NFC CHIP');
                    this.ledStatusLabel = 'حالة الحساس: رفض وإحباط الصرف (Blocked)';
                    this.lastError = result;

                    this.playBeepError();
                }
            } catch (err) {
                this.stageStatus = 'error';
                this.stageStatusText = 'خطأ في الاتصال بالخادم';
                this.terminalScreenMessage = 'COMMUNICATION ERROR';
                this.terminalScreenSubtext = 'CHECK SERVER NETWORK';
                this.lastError = {
                    title: 'خطأ اتصال',
                    message: 'تعذر الاتصال بخادم التحقق اللاتلامسي.'
                };
                this.playBeepError();
            } finally {
                // Return card smoothly after 950ms
                setTimeout(() => {
                    this.isTappingAnim = false;
                }, 950);
            }
        },

        // Web Audio Synthesizer
        getAudioContext() {
            if (!this.audioCtx) {
                const AudioCtxClass = window.AudioContext || window.webkitAudioContext;
                if (AudioCtxClass) {
                    this.audioCtx = new AudioCtxClass();
                }
            }
            if (this.audioCtx && this.audioCtx.state === 'suspended') {
                this.audioCtx.resume();
            }
            return this.audioCtx;
        },

        playRfChirp() {
            if (!this.soundEnabled) return;
            const ctx = this.getAudioContext();
            if (!ctx) return;

            try {
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(800, ctx.currentTime);
                osc.frequency.exponentialRampToValueAtTime(1400, ctx.currentTime + 0.08);

                gain.gain.setValueAtTime(0.08, ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.08);

                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start();
                osc.stop(ctx.currentTime + 0.09);
            } catch (e) {}
        },

        playBeepSuccess() {
            if (!this.soundEnabled) return;
            const ctx = this.getAudioContext();
            if (!ctx) return;

            try {
                const now = ctx.currentTime;
                const osc1 = ctx.createOscillator();
                const gain1 = ctx.createGain();
                osc1.type = 'sine';
                osc1.frequency.setValueAtTime(1760, now);
                gain1.gain.setValueAtTime(0.18, now);
                gain1.gain.exponentialRampToValueAtTime(0.001, now + 0.08);
                osc1.connect(gain1);
                gain1.connect(ctx.destination);
                osc1.start(now);
                osc1.stop(now + 0.09);

                const osc2 = ctx.createOscillator();
                const gain2 = ctx.createGain();
                osc2.type = 'sine';
                osc2.frequency.setValueAtTime(2637, now + 0.09);
                gain2.gain.setValueAtTime(0.22, now + 0.09);
                gain2.gain.exponentialRampToValueAtTime(0.001, now + 0.28);
                osc2.connect(gain2);
                gain2.connect(ctx.destination);
                osc2.start(now + 0.09);
                osc2.stop(now + 0.30);
            } catch (e) {}
        },

        playBeepError() {
            if (!this.soundEnabled) return;
            const ctx = this.getAudioContext();
            if (!ctx) return;

            try {
                const now = ctx.currentTime;
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.type = 'sawtooth';
                osc.frequency.setValueAtTime(220, now);
                osc.frequency.setValueAtTime(180, now + 0.12);
                
                gain.gain.setValueAtTime(0.2, now);
                gain.gain.exponentialRampToValueAtTime(0.001, now + 0.35);

                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start(now);
                osc.stop(now + 0.36);
            } catch (e) {}
        },

        printReceipt() {
            window.print();
        }
    };
}
</script>
