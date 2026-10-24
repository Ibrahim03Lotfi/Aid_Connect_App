<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\AidCampaign;
use App\Models\AidCase;
use App\Models\AidDistribution;
use App\Models\Beneficiary;
use App\Models\CaseDonation;
use App\Models\CaseImageFingerprint;
use App\Models\Category;
use App\Models\EmergencyMission;
use App\Models\FieldAssessment;
use App\Models\Governorate;
use App\Models\InventoryItem;
use App\Models\InventoryTransaction;
use App\Models\NfcCard;
use App\Models\Notification;
use App\Models\OrganizationRequest;
use App\Models\User;
use App\Models\VolunteerApplication;
use App\Models\VolunteerLog;
use App\Models\VolunteerOpportunity;
use App\Models\Warehouse;
use App\Services\Ai\ArabicTriageClassifierService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminDashboardController extends Controller
{
    /**
     * 5.1 Main Operations Dashboard & KPIs
     */
    public function index()
    {
        // 1. Total families aided this month (purely from manual DB distributions)
        $startOfMonth = now()->startOfMonth();
        $totalFamiliesAidedMonth = AidDistribution::where('distributed_at', '>=', $startOfMonth)
            ->distinct('beneficiary_id')
            ->count('beneficiary_id');

        // 2. Active volunteers currently in the field
        $activeVolunteersInField = User::where('role', 'volunteer')->count();

        // 3. Pending field visits
        $pendingFieldVisits = AidCase::whereIn('status', ['pending', 'submitted', 'under_review'])->count();

        // 4. Warehouse aid packages remaining
        $warehousePackagesRemaining = (int) InventoryItem::sum('available_stock');

        // Recent distributions
        $recentDistributions = AidDistribution::with(['beneficiary', 'volunteer', 'campaign'])
            ->latest('distributed_at')
            ->take(6)
            ->get();

        // Critical / High AI Urgency Cases
        $criticalCases = AidCase::with(['governorate', 'category'])
            ->where(function ($q) {
                $q->where('priority', 'urgent')
                  ->orWhere('ai_urgency_index', '>=', 75);
            })
            ->latest()
            ->take(5)
            ->get();

        // Active Emergency Missions
        $activeMissions = EmergencyMission::with(['governorate'])
            ->where('status', 'active')
            ->latest()
            ->take(4)
            ->get();

        return view('dashboard.index', compact(
            'totalFamiliesAidedMonth',
            'activeVolunteersInField',
            'pendingFieldVisits',
            'warehousePackagesRemaining',
            'recentDistributions',
            'criticalCases',
            'activeMissions'
        ));
    }

    /**
     * 5.2 Full-screen Live GIS Operations Map
     */
    public function gisMap(Request $request)
    {
        $governorates = Governorate::all();
        $warehouses = Warehouse::all();
        return view('dashboard.gis', compact('governorates', 'warehouses'));
    }

    /**
     * GIS Data Endpoint (GeoJSON/JSON for Leaflet)
     */
    public function gisData(Request $request)
    {
        // Coordinate reference map for Syrian governorates if not explicitly on record
        $govCoords = [
            'دمشق' => [33.5138, 36.2765],
            'ريف دمشق' => [33.5350, 36.3800],
            'حلب' => [36.2021, 37.1343],
            'حمص' => [34.7324, 36.7136],
            'حماة' => [35.1318, 36.7578],
            'اللاذقية' => [35.5317, 35.7901],
            'طرطوس' => [34.8890, 35.8866],
            'درعا' => [32.6255, 36.1054],
            'السويداء' => [32.7089, 36.5695],
            'دير الزور' => [35.3359, 40.1408],
            'الحسكة' => [36.5023, 40.7483],
            'الرقة' => [35.9594, 39.0089],
            'إدلب' => [35.9306, 36.6339],
            'القنيطرة' => [33.1259, 35.8246],
        ];

        // 1. Pending Aid Cases (Red Markers)
        $cases = AidCase::with('governorate')
            ->whereIn('status', ['pending', 'submitted', 'under_review'])
            ->get()
            ->map(function ($case, $idx) use ($govCoords) {
                $govName = $case->governorate?->name ?? 'دمشق';
                $baseCoord = $govCoords[$govName] ?? [33.5138, 36.2765];
                // slight jitter for distinct markers
                $lat = $baseCoord[0] + (($idx % 5) - 2) * 0.012;
                $lng = $baseCoord[1] + ((($idx * 3) % 7) - 3) * 0.012;

                return [
                    'id' => $case->id,
                    'type' => 'case',
                    'title' => $case->title,
                    'governorate' => $govName,
                    'urgency_index' => $case->ai_urgency_index ?? 0,
                    'triage_tier' => $case->ai_triage_tier ?? 'Tier 3 (عادي)',
                    'status' => $case->status,
                    'lat' => $lat,
                    'lng' => $lng,
                ];
            });

        // 2. Active Field Volunteers (Blue Dots)
        $volunteers = User::where('role', 'volunteer')
            ->get()
            ->map(function ($vol, $idx) use ($govCoords) {
                $govName = $vol->governorate ?? 'دمشق';
                $baseCoord = $govCoords[$govName] ?? [33.5138, 36.2765];
                $lat = $vol->latitude ?? ($baseCoord[0] + (($idx % 4) - 1.5) * 0.018);
                $lng = $vol->longitude ?? ($baseCoord[1] + ((($idx * 2) % 5) - 2) * 0.018);

                return [
                    'id' => $vol->id,
                    'type' => 'volunteer',
                    'name' => $vol->name,
                    'phone' => $vol->phone,
                    'vehicle' => $vol->vehicle_type ?? 'سيارة ميدانية',
                    'hours' => $vol->volunteer_hours ?? 0,
                    'lat' => $lat,
                    'lng' => $lng,
                ];
            });

        // 3. Aid Distribution Centers & Warehouses (Green Markers) - Purely from database
        $warehouses = Warehouse::all()->map(function ($wh) {
            return [
                'id' => $wh->id,
                'name' => $wh->name,
                'governorate' => $wh->governorate,
                'district' => $wh->district ?? '',
                'stock' => $wh->stock_capacity,
                'lat' => (float) $wh->latitude,
                'lng' => (float) $wh->longitude,
                'manager' => $wh->manager_name ?? '',
                'phone' => $wh->phone ?? '',
            ];
        });

        return response()->json([
            'cases' => $cases,
            'volunteers' => $volunteers,
            'warehouses' => $warehouses,
        ]);
    }

    /**
     * Store newly added warehouse with Syrian coordinates
     */
    public function storeWarehouse(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'governorate' => 'required|string',
            'district' => 'nullable|string|max:255',
            'address' => 'nullable|string|max:500',
            'stock_capacity' => 'nullable|string|max:100',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'manager_name' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:50',
        ]);

        if (empty($validated['stock_capacity'])) {
            $validated['stock_capacity'] = 'جاهز للتوزيع';
        }

        Warehouse::create($validated);

        return redirect()->back()->with('success', "تمت إضافة المستودع '{$validated['name']}' بنجاح وتحديده على الخريطة.");
    }

    /**
     * Update warehouse details
     */
    public function updateWarehouse(Request $request, $id)
    {
        $wh = Warehouse::findOrFail($id);
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'governorate' => 'required|string',
            'district' => 'nullable|string|max:255',
            'address' => 'nullable|string|max:500',
            'stock_capacity' => 'nullable|string|max:100',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'manager_name' => 'nullable|string|max:255',
            'phone' => 'nullable|string|max:50',
        ]);

        $wh->update($validated);

        return redirect()->back()->with('success', "تم تحديث بيانات المستودع '{$wh->name}' بنجاح.");
    }

    /**
     * Delete a warehouse
     */
    public function destroyWarehouse($id)
    {
        $wh = Warehouse::findOrFail($id);
        $name = $wh->name;
        $wh->delete();

        return redirect()->back()->with('success', "تم حذف المستودع '{$name}' بنجاح.");
    }

    public function cases(Request $request)
    {
        $query = AidCase::with(['governorate', 'category', 'images', 'attachments', 'comments.user']);

        if ($request->filled('status') && $request->status !== 'all') {
            $query->where('status', $request->status);
        }

        if ($request->filled('governorate_id')) {
            $query->where('governorate_id', $request->governorate_id);
        }

        if ($request->filled('min_urgency')) {
            $query->where('ai_urgency_index', '>=', (int) $request->min_urgency);
        }

        $cases = $query->orderByDesc('ai_urgency_index')->orderByDesc('id')->paginate(50);
        $volunteers = User::where('role', 'volunteer')->get();
        $governorates = Governorate::all();
        $categories = Category::all();

        return view('dashboard.cases', compact('cases', 'volunteers', 'governorates', 'categories'));
    }

    /**
     * Assign volunteer to case
     */
    public function assignVolunteer(Request $request, $id)
    {
        $request->validate([
            'volunteer_id' => 'required|exists:users,id',
            'notes' => 'nullable|string',
        ]);

        $case = AidCase::findOrFail($id);
        $case->update([
            'status' => 'assigned_for_inspection',
        ]);

        return redirect()->back()->with('success', 'تم إسناد الحالة إلى المتطوع الميداني بنجاح.');
    }

    /**
     * Approve case for public donations & funding
     */
    public function approveCase(Request $request, $id)
    {
        $case = AidCase::findOrFail($id);
        $case->update([
            'status' => 'approved',
        ]);

        return redirect()->back()->with('success', "تم اعتماد الحالة رقم #{$case->id} ونشرها لبدء جمع التبرعات.");
    }

    /**
     * Reject case with official reason
     */
    public function rejectCase(Request $request, $id)
    {
        $request->validate([
            'rejection_reason' => 'required|string|max:500',
        ]);

        $case = AidCase::findOrFail($id);
        $case->update([
            'status' => 'rejected',
        ]);

        return redirect()->back()->with('warning', "تم رفض الحالة رقم #{$case->id}. السبب: {$request->rejection_reason}");
    }

    /**
     * Store a new aid case manually
     */
    public function storeCase(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'category_id' => 'required|exists:categories,id',
            'governorate_id' => 'required|exists:governorates,id',
            'priority' => 'required|in:urgent,high,medium,low',
            'target_amount' => 'nullable|numeric|min:0',
        ]);

        $service = new ArabicTriageClassifierService();
        $aiResult = $service->classifyCase($validated['title'], $validated['description']);

        $adminUser = User::where('role', 'admin')->first() ?: User::first();

        $case = AidCase::create([
            'title' => $validated['title'],
            'description' => $validated['description'],
            'category_id' => $validated['category_id'],
            'governorate_id' => $validated['governorate_id'],
            'organization_id' => $adminUser?->id,
            'priority' => $validated['priority'],
            'target_amount' => $validated['target_amount'] ?? 0,
            'collected_amount' => 0,
            'status' => 'approved',
            'ai_urgency_index' => $aiResult['urgency_index'] ?? 75,
            'ai_triage_tier' => $aiResult['tier_label'] ?? 'Tier 2 (High)',
            'ai_fraud_status' => 'clean',
        ]);

        return redirect()->back()->with('success', "تم تسجيل الحالة الإغاثية رقم #{$case->id} بنجاح واعتمادها في المنظومة.");
    }

    /**
     * Update an aid case
     */
    public function updateCase(Request $request, $id)
    {
        $case = AidCase::findOrFail($id);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'category_id' => 'required|exists:categories,id',
            'governorate_id' => 'required|exists:governorates,id',
            'priority' => 'required|in:urgent,high,medium,low',
            'status' => 'required|in:pending,assigned_for_inspection,approved,rejected',
            'target_amount' => 'nullable|numeric|min:0',
        ]);

        $case->update($validated);

        return redirect()->back()->with('success', "تم تحديث بيانات الحالة رقم #{$case->id} بنجاح.");
    }

    /**
     * Delete an aid case
     */
    public function destroyCase($id)
    {
        $case = AidCase::findOrFail($id);
        $caseId = $case->id;
        $case->delete();

        return redirect()->back()->with('success', "تم حذف الحالة رقم #{$caseId} بنجاح.");
    }

    /**
     * 5.4 Beneficiary & NFC Card Management Hub
     */
    public function beneficiaries(Request $request)
    {
        $query = Beneficiary::with(['nfcCard', 'governorate', 'distributions.campaign', 'distributions.volunteer']);

        if ($request->filled('search')) {
            $term = $request->search;
            $query->where(function ($q) use ($term) {
                $q->where('full_name', 'like', "%{$term}%")
                  ->orWhere('national_id', 'like', "%{$term}%")
                  ->orWhere('file_number', 'like', "%{$term}%")
                  ->orWhere('phone', 'like', "%{$term}%");
            });
        }

        $beneficiaries = $query->latest()->paginate(12);
        $governorates = Governorate::all();

        return view('dashboard.beneficiaries', compact('beneficiaries', 'governorates'));
    }

    /**
     * Register new beneficiary family & pair NFC Card
     */
    public function storeBeneficiary(Request $request)
    {
        $validated = $request->validate([
            'full_name' => 'required|string|max:255',
            'national_id' => 'required|string|unique:beneficiaries,national_id',
            'phone' => 'required|string|max:20',
            'family_members_count' => 'required|integer|min:1',
            'governorate_id' => 'required|exists:governorates,id',
            'address' => 'required|string|max:500',
            'vulnerability_level' => 'nullable|string',
            'nfc_uid' => 'nullable|string|max:100|unique:nfc_cards,card_uid',
        ]);

        $scoreMap = [
            'critical' => 95,
            'high' => 80,
            'medium' => 60,
            'low' => 30,
        ];
        $score = $scoreMap[$validated['vulnerability_level'] ?? 'high'] ?? 75;

        $nfcUid = !empty($validated['nfc_uid']) ? strtoupper($validated['nfc_uid']) : null;
        $qrToken = 'ATHAR-QR-' . strtoupper(bin2hex(random_bytes(8)));

        $beneficiary = Beneficiary::create([
            'full_name' => $validated['full_name'],
            'national_id' => $validated['national_id'],
            'phone' => $validated['phone'],
            'family_members_count' => $validated['family_members_count'],
            'governorate_id' => $validated['governorate_id'],
            'district' => 'المركز',
            'address_details' => $validated['address'],
            'vulnerability_score' => $score,
            'nfc_card_uid' => $nfcUid,
            'qr_token' => $qrToken,
            'status' => 'active',
        ]);

        if ($nfcUid) {
            NfcCard::create([
                'beneficiary_id' => $beneficiary->id,
                'card_uid' => $nfcUid,
                'is_active' => true,
                'issued_at' => now(),
            ]);
        }

        return redirect()->back()->with('success', "تم تسجيل الأسرة بنجاح برقم وطني: {$beneficiary->national_id}");
    }

    /**
     * Update beneficiary record
     */
    public function updateBeneficiary(Request $request, $id)
    {
        $ben = Beneficiary::findOrFail($id);

        $validated = $request->validate([
            'full_name' => 'required|string|max:255',
            'national_id' => 'required|string|unique:beneficiaries,national_id,' . $ben->id,
            'phone' => 'required|string|max:20',
            'family_members_count' => 'required|integer|min:1',
            'governorate_id' => 'required|exists:governorates,id',
            'address' => 'required|string|max:500',
            'vulnerability_level' => 'nullable|string',
            'nfc_uid' => 'nullable|string|max:100',
        ]);

        $scoreMap = [
            'critical' => 95,
            'high' => 80,
            'medium' => 60,
            'low' => 30,
        ];
        $score = $scoreMap[$validated['vulnerability_level'] ?? 'high'] ?? 75;
        $nfcUid = !empty($validated['nfc_uid']) ? strtoupper($validated['nfc_uid']) : null;

        $ben->update([
            'full_name' => $validated['full_name'],
            'national_id' => $validated['national_id'],
            'phone' => $validated['phone'],
            'family_members_count' => $validated['family_members_count'],
            'governorate_id' => $validated['governorate_id'],
            'address_details' => $validated['address'],
            'vulnerability_score' => $score,
            'nfc_card_uid' => $nfcUid,
        ]);

        if ($nfcUid) {
            NfcCard::updateOrCreate(
                ['beneficiary_id' => $ben->id],
                ['card_uid' => $nfcUid, 'is_active' => true, 'issued_at' => now()]
            );
        }

        return redirect()->back()->with('success', "تم تحديث بيانات الأسرة '{$ben->full_name}' بنجاح.");
    }

    /**
     * Delete beneficiary record
     */
    public function destroyBeneficiary($id)
    {
        $ben = Beneficiary::findOrFail($id);
        $name = $ben->full_name;
        $ben->delete();

        return redirect()->back()->with('success', "تم حذف سجل الأسرة '{$name}' بنجاح.");
    }

    /**
     * 5.5 Logistics & Aid Inventory System
     */
    public function storeInventoryItem(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:100|unique:inventory_items,code',
            'category_id' => 'required|exists:categories,id',
            'unit' => 'required|string|max:50',
            'total_stock' => 'required|integer|min:0',
            'minimum_threshold' => 'required|integer|min:0',
            'warehouse_location' => 'nullable|string|max:255',
        ]);

        $item = InventoryItem::create([
            'name' => $validated['name'],
            'code' => strtoupper($validated['code']),
            'category_id' => $validated['category_id'],
            'unit' => $validated['unit'],
            'total_stock' => $validated['total_stock'],
            'available_stock' => $validated['total_stock'],
            'reserved_stock' => 0,
            'minimum_threshold' => $validated['minimum_threshold'],
            'warehouse_location' => $validated['warehouse_location'] ?? 'مستودع الميدان المركزي',
        ]);

        if ($validated['total_stock'] > 0) {
            InventoryTransaction::create([
                'item_id' => $item->id,
                'type' => 'inbound',
                'quantity' => $validated['total_stock'],
                'notes' => 'رصيد افتتاحي للمادة الإغاثية',
                'performed_by' => auth()->id() ?? User::where('role', 'admin')->value('id') ?? 1,
            ]);
        }

        return redirect()->back()->with('success', "تمت إضافة المادة '{$item->name}' إلى المستودع بنجاح.");
    }

    public function updateInventoryItem(Request $request, $id)
    {
        $item = InventoryItem::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'unit' => 'required|string|max:50',
            'minimum_threshold' => 'required|integer|min:0',
            'warehouse_location' => 'nullable|string|max:255',
        ]);

        $item->update($validated);

        return redirect()->back()->with('success', "تم تحديث بيانات المادة '{$item->name}' بنجاح.");
    }

    public function destroyInventoryItem($id)
    {
        $item = InventoryItem::findOrFail($id);
        $name = $item->name;
        $item->delete();

        return redirect()->back()->with('success', "تم حذف المادة '{$name}' من المستودع بنجاح.");
    }

    public function inventory(Request $request)
    {
        $items = InventoryItem::with('category')->get();
        $transactions = InventoryTransaction::with(['item', 'performer'])
            ->latest()
            ->take(15)
            ->get();
        $warehouses = Warehouse::all();
        $governorates = Governorate::all();
        $categories = Category::all();

        $totalStockUnits = $items->sum('total_stock');
        $availableUnits = $items->sum('available_stock');
        $reservedUnits = $items->sum('reserved_stock');
        $lowStockCount = $items->filter(fn($i) => $i->available_stock <= $i->minimum_threshold)->count();

        return view('dashboard.inventory', compact(
            'items',
            'transactions',
            'warehouses',
            'governorates',
            'categories',
            'totalStockUnits',
            'availableUnits',
            'reservedUnits',
            'lowStockCount'
        ));
    }

    /**
     * 5.6 Executive Analytics
     */
    public function analytics(Request $request)
    {
        // 1. Distributions per governorate
        $governorateStats = DB::table('aid_distributions')
            ->join('beneficiaries', 'aid_distributions.beneficiary_id', '=', 'beneficiaries.id')
            ->join('governorates', 'beneficiaries.governorate_id', '=', 'governorates.id')
            ->select('governorates.name as gov_name', DB::raw('count(aid_distributions.id) as total_distributions'))
            ->groupBy('governorates.name')
            ->get();

        // 2. Aid by Category
        $categoryStats = DB::table('cases')
            ->join('categories', 'cases.category_id', '=', 'categories.id')
            ->select('categories.name as cat_name', DB::raw('count(cases.id) as case_count'))
            ->groupBy('categories.name')
            ->get();

        // 3. Top Volunteers
        $topVolunteers = User::where('role', 'volunteer')
            ->orderByDesc('volunteer_hours')
            ->take(8)
            ->get();

        // 4. Monthly Distribution Trend
        $monthlyTrend = DB::table('aid_distributions')
            ->select(DB::raw("to_char(distributed_at, 'YYYY-MM') as month_label"), DB::raw('count(id) as count'))
            ->groupBy('month_label')
            ->orderBy('month_label')
            ->take(6)
            ->get();

        return view('dashboard.analytics', compact(
            'governorateStats',
            'categoryStats',
            'topVolunteers',
            'monthlyTrend'
        ));
    }

    /**
     * 5.6 Official Humanitarian Impact Report (Printable & Exportable PDF)
     */
    public function impactReport(Request $request)
    {
        $year = $request->get('year', date('Y'));

        $totalFamilies = Beneficiary::count();
        $totalDistributions = AidDistribution::count();
        $totalVolunteers = User::where('role', 'volunteer')->count();
        $totalHours = (float) User::where('role', 'volunteer')->sum('volunteer_hours');
        $fundsDisbursed = (float) AidCase::where('status', 'approved')->sum('collected_amount');

        $topGovernorates = DB::table('beneficiaries')
            ->join('governorates', 'beneficiaries.governorate_id', '=', 'governorates.id')
            ->select('governorates.name', DB::raw('count(beneficiaries.id) as family_count'))
            ->groupBy('governorates.name')
            ->orderByDesc('family_count')
            ->take(5)
            ->get();

        return view('dashboard.impact_report', compact(
            'year',
            'totalFamilies',
            'totalDistributions',
            'totalVolunteers',
            'totalHours',
            'fundsDisbursed',
            'topGovernorates'
        ));
    }

    /**
     * Aid Campaigns Management
     */
    public function campaigns(Request $request)
    {
        $campaigns = AidCampaign::with(['category', 'distributions'])->latest()->paginate(15);
        $categories = Category::all();
        $totalCampaigns = AidCampaign::count();
        $activeCampaigns = AidCampaign::where('status', 'active')->count();
        $totalTarget = AidCampaign::sum('target_families_count');
        $totalDistributed = AidCampaign::sum('distributed_families_count');

        return view('dashboard.campaigns', compact(
            'campaigns', 
            'categories', 
            'totalCampaigns', 
            'activeCampaigns', 
            'totalTarget', 
            'totalDistributed'
        ));
    }

    public function storeCampaign(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'required|exists:categories,id',
            'start_date' => 'required|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'item_type' => 'required|string|max:255',
            'items_allocated_per_family' => 'required|integer|min:1',
            'target_families_count' => 'required|integer|min:1',
        ]);

        $validated['status'] = 'active';
        $validated['distributed_families_count'] = 0;

        AidCampaign::create($validated);

        return redirect()->back()->with('success', 'تم إنشاء الحملة الإغاثية بنجاح وتفعيلها لفرق التوزيع الميداني.');
    }

    public function updateCampaign(Request $request, $id)
    {
        $camp = AidCampaign::findOrFail($id);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'category_id' => 'required|exists:categories,id',
            'start_date' => 'required|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'item_type' => 'required|string|max:255',
            'items_allocated_per_family' => 'required|integer|min:1',
            'target_families_count' => 'required|integer|min:1',
            'status' => 'required|in:active,completed',
        ]);

        $camp->update($validated);

        return redirect()->back()->with('success', "تم تحديث بيانات الحملة '{$camp->title}' بنجاح.");
    }

    public function destroyCampaign($id)
    {
        $camp = AidCampaign::findOrFail($id);
        $title = $camp->title;
        $camp->delete();

        return redirect()->back()->with('success', "تم حذف الحملة '{$title}' بنجاح.");
    }

    public function toggleCampaignStatus(Request $request, $id)
    {
        $campaign = AidCampaign::findOrFail($id);
        $campaign->status = $campaign->status === 'active' ? 'completed' : 'active';
        $campaign->save();

        return redirect()->back()->with('success', "تم تحديث حالة الحملة ({$campaign->title}) إلى: {$campaign->status}.");
    }

    /**
     * Emergency Missions Dispatch
     */
    public function missions(Request $request)
    {
        $missions = EmergencyMission::with(['governorate', 'creator', 'volunteers'])->latest()->paginate(15);
        $governorates = Governorate::all();
        $openMissionsCount = EmergencyMission::where('status', 'open')->count();
        $criticalMissionsCount = EmergencyMission::where('urgency', 'critical')->count();

        return view('dashboard.missions', compact('missions', 'governorates', 'openMissionsCount', 'criticalMissionsCount'));
    }

    public function storeMission(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'urgency' => 'required|in:critical,high,medium',
            'governorate_id' => 'required|exists:governorates,id',
            'district' => 'nullable|string|max:255',
            'volunteers_needed' => 'required|integer|min:1',
            'required_skills' => 'nullable|string',
        ]);

        $skills = !empty($validated['required_skills']) 
            ? array_map('trim', explode(',', $validated['required_skills']))
            : ['إسعاف أولي', 'إغاثة ميدانية'];

        $adminUser = User::where('role', 'admin')->first() ?: User::first();

        EmergencyMission::create([
            'title' => $validated['title'],
            'description' => $validated['description'],
            'urgency' => $validated['urgency'],
            'required_skills' => $skills,
            'governorate_id' => $validated['governorate_id'],
            'district' => $validated['district'],
            'volunteers_needed' => $validated['volunteers_needed'],
            'volunteers_joined' => 0,
            'status' => 'open',
            'created_by' => $adminUser->id,
        ]);

        return redirect()->back()->with('success', 'تم إطلاق مهمة الاستجابة الطارئة بنجاح وتعميمها على المتطوعين.');
    }

    public function updateMission(Request $request, $id)
    {
        $m = EmergencyMission::findOrFail($id);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'urgency' => 'required|in:critical,high,medium',
            'governorate_id' => 'required|exists:governorates,id',
            'district' => 'nullable|string|max:255',
            'volunteers_needed' => 'required|integer|min:1',
            'required_skills' => 'nullable|string',
            'status' => 'required|in:open,in_progress,completed',
        ]);

        $skills = !empty($validated['required_skills']) 
            ? array_map('trim', explode(',', $validated['required_skills']))
            : ['إسعاف أولي', 'إغاثة ميدانية'];

        $validated['required_skills'] = $skills;
        $m->update($validated);

        return redirect()->back()->with('success', "تم تحديث بيانات المهمة الطارئة (#{$m->id}) بنجاح.");
    }

    public function destroyMission($id)
    {
        $m = EmergencyMission::findOrFail($id);
        $mId = $m->id;
        $m->delete();

        return redirect()->back()->with('success', "تم حذف المهمة الطارئة (#{$mId}) بنجاح.");
    }

    public function closeMission(Request $request, $id)
    {
        $mission = EmergencyMission::findOrFail($id);
        $mission->status = 'completed';
        $mission->save();

        return redirect()->back()->with('success', "تم إغلاق المهمة الطارئة (#{$mission->id}) وتوثيق اكتمالها.");
    }

    public function reopenMission(Request $request, $id)
    {
        $mission = EmergencyMission::findOrFail($id);
        $mission->status = 'open';
        $mission->save();

        return redirect()->back()->with('success', "تمت إعادة فتح المهمة الطارئة (#{$mission->id}) للاستجابة الميدانية.");
    }

    /**
     * Volunteers Roster & Hours Certification
     */
    public function volunteers(Request $request)
    {
        $query = User::where('role', 'volunteer');

        if ($request->filled('governorate')) {
            $query->where('governorate', $request->governorate);
        }

        $volunteers = $query->orderByDesc('volunteer_hours')->paginate(20);
        $governorates = Governorate::all();
        $totalVolunteers = User::where('role', 'volunteer')->count();
        $totalHours = (float) User::where('role', 'volunteer')->sum('volunteer_hours');
        $opportunities = VolunteerOpportunity::with('organization')->latest()->take(15)->get();
        $applications = VolunteerApplication::with(['user', 'opportunity'])->latest()->take(20)->get();
        $categories = Category::all();

        return view('dashboard.volunteers', compact('volunteers', 'governorates', 'totalVolunteers', 'totalHours', 'opportunities', 'applications', 'categories'));
    }

    public function logVolunteerHours(Request $request, $id)
    {
        $request->validate([
            'hours' => 'required|numeric|min:0.5',
            'mission_type' => 'required|string',
            'notes' => 'nullable|string',
        ]);

        $volunteer = User::findOrFail($id);
        $hours = (float) $request->hours;
        $points = (int) ($hours * 10);

        $volunteer->volunteer_hours = ($volunteer->volunteer_hours ?? 0) + $hours;
        $volunteer->volunteer_points = ($volunteer->volunteer_points ?? 0) + $points;
        $volunteer->save();

        VolunteerLog::create([
            'volunteer_id' => $volunteer->id,
            'mission_type' => $request->mission_type,
            'hours_logged' => $hours,
            'points_earned' => $points,
            'verified_by_admin' => true,
        ]);

        return redirect()->back()->with('success', "تم اعتماد {$hours} ساعة ميدانية للمتطوع ({$volunteer->name}) وتحديث رصيده بنجاح.");
    }

    public function awardVolunteerBadge(Request $request, $id)
    {
        $request->validate([
            'badge' => 'required|string|max:100',
        ]);

        $volunteer = User::findOrFail($id);

        VolunteerLog::create([
            'volunteer_id' => $volunteer->id,
            'mission_type' => 'emergency_mission',
            'hours_logged' => 0,
            'points_earned' => 50,
            'badge_awarded' => $request->badge,
            'verified_by_admin' => true,
        ]);

        return redirect()->back()->with('success', "تم منح وسام ({$request->badge}) للمتطوع ({$volunteer->name}) وتدوينه في جواز سفره الرقمي.");
    }

    /**
     * Field Living Condition Surveys & Inspection Review
     */
    public function fieldAssessments(Request $request)
    {
        $assessments = FieldAssessment::with(['case', 'volunteer', 'beneficiary'])->latest()->paginate(20);
        $totalAssessments = FieldAssessment::count();
        $criticalCount = FieldAssessment::where('urgency_rating', 'critical')->count();

        return view('dashboard.assessments', compact('assessments', 'totalAssessments', 'criticalCount'));
    }

    public function updateAssessmentStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:approved,rejected,submitted',
        ]);

        $assessment = FieldAssessment::findOrFail($id);
        $assessment->status = $request->status;
        $assessment->save();

        $statusLabels = [
            'approved' => 'معتمدة وموثقة',
            'rejected' => 'مرفوضة',
            'submitted' => 'قيد التدقيق والمراجعة',
        ];
        $label = $statusLabels[$request->status] ?? $request->status;

        return redirect()->back()->with('success', "تم تحديث حالة المعاينة الميدانية رقم #{$assessment->id} إلى: {$label}.");
    }

    /**
     * Inventory Stock Inflow (+IN)
     */
    public function addStock(Request $request)
    {
        $request->validate([
            'item_id' => 'required|exists:inventory_items,id',
            'quantity' => 'required|integer|min:1',
            'notes' => 'nullable|string',
        ]);

        $item = InventoryItem::findOrFail($request->item_id);
        $qty = (int) $request->quantity;

        $item->total_stock += $qty;
        $item->available_stock += $qty;
        $item->save();

        InventoryTransaction::create([
            'item_id' => $item->id,
            'type' => 'inbound',
            'quantity' => $qty,
            'notes' => $request->notes ?? 'توريد مستودعي جديد',
            'performed_by' => auth()->id() ?? User::where('role', 'admin')->value('id') ?? User::first()->id,
        ]);

        return redirect()->back()->with('success', "تم تسجيل شحنة التوريد بنجاح (+{$qty} {$item->unit} إلى {$item->name}).");
    }

    /**
     * Donations & Financial Transparency Ledger
     */
    public function donations(Request $request)
    {
        $donations = CaseDonation::with(['case', 'user'])->latest()->paginate(25);
        $totalCollected = (float) CaseDonation::sum('amount');
        $totalCount = CaseDonation::count();
        $shamCashCount = CaseDonation::where('payment_method', 'sham_cash')->count();
        $cases = AidCase::where('status', 'approved')->get();

        return view('dashboard.donations', compact('donations', 'totalCollected', 'totalCount', 'shamCashCount', 'cases'));
    }

    public function storeDonation(Request $request)
    {
        $validated = $request->validate([
            'donor_name' => 'required|string|max:255',
            'donor_phone' => 'nullable|string|max:50',
            'amount' => 'required|numeric|min:1',
            'payment_method' => 'required|string',
            'case_id' => 'nullable|exists:cases,id',
            'notes' => 'nullable|string',
        ]);

        $ref = 'REF-' . strtoupper(substr($validated['payment_method'], 0, 4)) . '-' . strtoupper(bin2hex(random_bytes(4)));

        $caseId = $validated['case_id'] ?? AidCase::where('status', 'approved')->value('id') ?? AidCase::value('id');

        CaseDonation::create([
            'donor_name' => $validated['donor_name'],
            'donor_phone' => $validated['donor_phone'],
            'amount' => $validated['amount'],
            'currency' => 'ل.س',
            'payment_method' => $validated['payment_method'],
            'transaction_ref' => $ref,
            'case_id' => $caseId,
            'status' => 'completed',
        ]);

        if ($caseId) {
            $case = AidCase::find($caseId);
            if ($case) {
                $case->increment('collected_amount', $validated['amount']);
            }
        }

        return redirect()->back()->with('success', "تم تسجيل التبرع المالي بنجاح بمبلغ " . number_format($validated['amount']) . " ل.س (رقم العملية: {$ref}).");
    }

    public function approveDonation(Request $request, $id)
    {
        $donation = CaseDonation::findOrFail($id);
        $donation->status = 'completed';
        $donation->save();

        if ($donation->case_id) {
            $case = AidCase::find($donation->case_id);
            if ($case) {
                $case->increment('collected_amount', $donation->amount);
            }
        }

        return redirect()->back()->with('success', "تم اعتماد وتأكيد إيداع التبرع المالي رقم ({$donation->transaction_ref}) بمبلغ " . number_format($donation->amount) . " ل.س.");
    }

    public function rejectDonation(Request $request, $id)
    {
        $donation = CaseDonation::findOrFail($id);
        $donation->status = 'failed';
        $donation->save();

        return redirect()->back()->with('warning', "تم إلغاء قيد التبرع المالي رقم ({$donation->transaction_ref}).");
    }

    /**
     * Volunteer Opportunities Management
     */
    public function storeOpportunity(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'category' => 'required|string',
            'governorate' => 'required|string',
            'priority' => 'required|in:urgent,high,medium,low',
            'volunteers_needed' => 'required|integer|min:1',
            'is_urgent' => 'nullable|boolean',
        ]);

        $adminUser = User::where('role', 'admin')->first() ?: User::first();

        VolunteerOpportunity::create([
            'title' => $validated['title'],
            'description' => $validated['description'],
            'category' => $validated['category'],
            'governorate' => $validated['governorate'],
            'priority' => $validated['priority'],
            'organization_id' => $adminUser->id,
            'volunteers_needed' => $validated['volunteers_needed'],
            'volunteers_applied' => 0,
            'is_urgent' => $request->boolean('is_urgent'),
            'status' => 'active',
        ]);

        return redirect()->back()->with('success', 'تم نشر الفرصة التطوعية بنجاح وتعميمها عبر التطبيق.');
    }

    public function updateOpportunity(Request $request, $id)
    {
        $op = VolunteerOpportunity::findOrFail($id);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'category' => 'required|string',
            'governorate' => 'required|string',
            'priority' => 'required|in:urgent,high,medium,low',
            'volunteers_needed' => 'required|integer|min:1',
            'status' => 'required|in:active,completed,closed',
            'is_urgent' => 'nullable|boolean',
        ]);

        $validated['is_urgent'] = $request->boolean('is_urgent');
        $op->update($validated);

        return redirect()->back()->with('success', "تم تحديث الفرصة التطوعية '{$op->title}' بنجاح.");
    }

    public function destroyOpportunity($id)
    {
        $op = VolunteerOpportunity::findOrFail($id);
        $title = $op->title;
        $op->delete();

        return redirect()->back()->with('success', "تم حذف الفرصة التطوعية '{$title}' بنجاح.");
    }

    public function toggleOpportunityStatus(Request $request, $id)
    {
        $op = VolunteerOpportunity::findOrFail($id);
        $op->status = $op->status === 'active' ? 'closed' : 'active';
        $op->save();

        $statusText = $op->status === 'active' ? 'متاحة للتقديم' : 'مغلقة ومكتملة';
        return redirect()->back()->with('success', "تم تحديث حالة الفرصة التطوعية '{$op->title}' إلى: {$statusText}.");
    }

    public function updateApplicationStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:accepted,approved,rejected,pending',
        ]);

        $app = VolunteerApplication::findOrFail($id);
        $oldStatus = $app->status;
        $newStatus = in_array($request->status, ['accepted', 'approved']) ? 'accepted' : $request->status;

        $app->status = $newStatus;
        $app->save();

        if ($newStatus === 'accepted' && $oldStatus !== 'accepted' && $app->opportunity) {
            $app->opportunity->increment('volunteers_applied');
        } elseif ($newStatus !== 'accepted' && $oldStatus === 'accepted' && $app->opportunity && $app->opportunity->volunteers_applied > 0) {
            $app->opportunity->decrement('volunteers_applied');
        }

        $statusLabel = $newStatus === 'accepted' ? 'قبول واعتماد في الكادر' : ($newStatus === 'rejected' ? 'رفض الطلب' : 'إعادة للتدقيق');

        return redirect()->back()->with('success', "تم تحديث حالة طلب التطوع للمتطوع ({$app->user?->name}) إلى: [{$statusLabel}].");
    }

    /**
     * NGO Partners & Accreditation Hub
     */
    public function organizations(Request $request)
    {
        $status = $request->query('status');
        $query = OrganizationRequest::query();

        if ($status && in_array($status, ['pending', 'approved', 'rejected'])) {
            $query->where('status', $status);
        }

        $requests = $query->latest()->paginate(15);
        $totalRequests = OrganizationRequest::count();
        $pendingCount = OrganizationRequest::where('status', 'pending')->count();
        $approvedCount = OrganizationRequest::where('status', 'approved')->count();
        $registeredNgos = User::where('role', 'organization')->latest()->take(10)->get();

        return view('dashboard.organizations', compact('requests', 'totalRequests', 'pendingCount', 'approvedCount', 'registeredNgos'));
    }

    public function approveOrganization(Request $request, $id)
    {
        $orgReq = OrganizationRequest::findOrFail($id);
        $orgReq->status = 'approved';
        $orgReq->save();

        // Create or activate organization user if not present
        $user = User::where('email', $orgReq->email)->first();
        if (!$user) {
            User::create([
                'name' => $orgReq->name,
                'email' => $orgReq->email,
                'phone' => $orgReq->phone,
                'address' => $orgReq->address,
                'bio' => $orgReq->description,
                'registration_number' => $orgReq->registration_number,
                'password' => bcrypt('AtharNGO@2026'),
                'role' => 'organization',
                'is_active' => true,
            ]);
        } else {
            $user->role = 'organization';
            $user->is_active = true;
            $user->registration_number = $orgReq->registration_number;
            $user->save();
        }

        return redirect()->back()->with('success', "تم اعتماد منظمة ({$orgReq->name}) بنجاح وتفعيل حساب الشراكة المؤسسية.");
    }

    public function rejectOrganization(Request $request, $id)
    {
        $request->validate([
            'rejection_reason' => 'nullable|string',
        ]);

        $orgReq = OrganizationRequest::findOrFail($id);
        $orgReq->status = 'rejected';
        $orgReq->rejection_reason = $request->rejection_reason ?? 'عدم استيفاء معايير الترخيص أو الأوراق الثبوتية';
        $orgReq->save();

        // If an associated user account exists, freeze it
        $user = User::where('email', $orgReq->email)->first();
        if ($user) {
            $user->is_active = false;
            $user->save();
        }

        return redirect()->back()->with('success', "تم رفض وتجميد اعتماد المنظمة ({$orgReq->name}).");
    }

    /**
     * Emergency Broadcast & Notifications Hub
     */
    public function notifications(Request $request)
    {
        $notifications = Notification::with('user')->latest()->paginate(25);
        $totalSent = Notification::count();
        $unreadCount = Notification::where('is_read', false)->count();

        return view('dashboard.notifications', compact('notifications', 'totalSent', 'unreadCount'));
    }

    public function broadcastNotification(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'body' => 'required|string',
            'target' => 'required|in:volunteers,all,organizations',
        ]);

        $query = User::query();
        if ($validated['target'] === 'volunteers') {
            $query->where('role', 'volunteer');
        } elseif ($validated['target'] === 'organizations') {
            $query->where('role', 'organization');
        }

        $users = $query->get();
        $count = 0;

        foreach ($users as $user) {
            Notification::create([
                'user_id' => $user->id,
                'title' => $validated['title'],
                'body' => $validated['body'],
                'type' => 'emergency_broadcast',
                'is_read' => false,
            ]);
            $count++;
        }

        return redirect()->back()->with('success', "تم بث التعميم الطارئ بنجاح إلى {$count} مستخدم/متطوع في الميدان.");
    }

    /**
     * NFC Distributions Audit Ledger
     */
    public function distributions(Request $request)
    {
        $query = AidDistribution::with(['beneficiary', 'volunteer', 'campaign']);

        if ($request->filled('campaign_id')) {
            $query->where('campaign_id', $request->campaign_id);
        }
        if ($request->filled('method')) {
            $query->where('verification_method', $request->method);
        }
        if ($request->has('offline') && $request->offline !== '') {
            $query->where('is_offline_synced', $request->boolean('offline'));
        }

        $distributions = $query->latest('distributed_at')->paginate(20);
        $campaigns = AidCampaign::all();
        $totalDeliveries = AidDistribution::count();
        $nfcCount = AidDistribution::where('verification_method', 'nfc_tap')->count();
        $offlineSyncedCount = AidDistribution::where('is_offline_synced', true)->count();
        $uniqueFamilies = AidDistribution::distinct('beneficiary_id')->count('beneficiary_id');

        return view('dashboard.distributions', compact(
            'distributions', 'campaigns', 'totalDeliveries', 'nfcCount', 'offlineSyncedCount', 'uniqueFamilies'
        ));
    }

    /**
     * AI Intelligence & Fraud Diagnostics Lab
     */
    public function aiIntelligence(Request $request)
    {
        $fingerprints = CaseImageFingerprint::with('case')->latest()->take(20)->get();
        $totalFingerprints = CaseImageFingerprint::count();
        $highRiskCases = AidCase::where('ai_urgency_index', '>=', 80)->count();
        $fraudSuspectsCount = AidCase::where('ai_fraud_status', '!=', 'clean')->orWhereNotNull('duplicate_case_id')->count();

        $simulationResult = session('simulation_result');
        $simulatedInput = session('simulated_input');

        return view('dashboard.ai', compact(
            'fingerprints', 'totalFingerprints', 'highRiskCases', 'fraudSuspectsCount', 'simulationResult', 'simulatedInput'
        ));
    }

    public function simulateAiTriage(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
        ]);

        $service = new ArabicTriageClassifierService();
        $result = $service->classifyCase($validated['title'], $validated['description']);

        return redirect()->route('dashboard.ai')->with([
            'simulation_result' => $result,
            'simulated_input' => $validated,
            'success' => 'تم فحص الحالة عبر محرك الفرز الذكي بنجاح.',
        ]);
    }

    /**
     * System Users & Roles Governance
     */
    public function users(Request $request)
    {
        $query = User::query();

        if ($request->filled('role')) {
            $query->where('role', $request->role);
        }
        if ($request->filled('search')) {
            $s = $request->search;
            $query->where(function($q) use ($s) {
                $q->where('name', 'like', "%{$s}%")
                  ->orWhere('phone', 'like', "%{$s}%")
                  ->orWhere('email', 'like', "%{$s}%");
            });
        }

        $users = $query->latest()->paginate(25);
        $totalUsers = User::count();
        $adminCount = User::where('role', 'admin')->count();
        $volunteerCount = User::where('role', 'volunteer')->count();
        $orgCount = User::where('role', 'organization')->count();

        return view('dashboard.users', compact(
            'users', 'totalUsers', 'adminCount', 'volunteerCount', 'orgCount'
        ));
    }

    public function storeUser(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email',
            'phone' => 'required|string|max:50',
            'role' => 'required|in:admin,volunteer,organization,donor,user',
            'password' => 'required|string|min:6',
            'address' => 'nullable|string|max:255',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'phone' => $validated['phone'],
            'role' => $validated['role'],
            'password' => bcrypt($validated['password']),
            'address' => $validated['address'] ?? 'دمشق',
            'is_active' => true,
        ]);

        return redirect()->back()->with('success', "تم إنشاء حساب ({$user->name}) بصلاحية ({$user->role}) بنجاح.");
    }

    public function updateUser(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            'phone' => 'required|string|max:50',
            'role' => 'required|in:admin,volunteer,organization,donor,user',
            'password' => 'nullable|string|min:6',
        ]);

        $user->name = $validated['name'];
        $user->email = $validated['email'];
        $user->phone = $validated['phone'];
        $user->role = $validated['role'];

        if (!empty($validated['password'])) {
            $user->password = bcrypt($validated['password']);
        }

        $user->save();

        return redirect()->back()->with('success', "تم تحديث بيانات الحساب ({$user->name}) بنجاح.");
    }

    public function destroyUser($id)
    {
        $user = User::findOrFail($id);

        if ($user->id === auth()->id()) {
            return redirect()->back()->with('error', 'لا يمكنك حذف حسابك الحالي الذي تستخدمه لتسجيل الدخول.');
        }

        $name = $user->name;
        $user->delete();

        return redirect()->back()->with('success', "تم حذف الحساب ({$name}) بنجاح من النظام.");
    }

    public function toggleUserStatus(Request $request, $id)
    {
        $user = User::findOrFail($id);
        $user->is_active = !$user->is_active;
        $user->save();

        $statusStr = $user->is_active ? 'مفعل' : 'معطل';
        return redirect()->back()->with('success', "تم تحديث حالة حساب ({$user->name}) إلى: {$statusStr}.");
    }

    public function updateUserRole(Request $request, $id)
    {
        $request->validate([
            'role' => 'required|in:admin,volunteer,organization,donor,user',
        ]);

        $user = User::findOrFail($id);
        $user->role = $request->role;
        $user->save();

        return redirect()->back()->with('success', "تم تحديث صلاحية الحساب ({$user->name}) إلى: {$request->role}.");
    }

    /**
     * Platform Settings & System Health
     */
    public function settings(Request $request)
    {
        $categories = Category::withCount('cases')->get();
        $governorates = Governorate::all();

        $dbConnected = true;
        try {
            DB::connection()->getPdo();
        } catch (\Throwable $e) {
            $dbConnected = false;
        }

        $diagnostics = [
            'php_version' => PHP_VERSION,
            'laravel_version' => app()->version(),
            'db_status' => $dbConnected ? 'متصل ومؤمن (PostgreSQL)' : 'خطأ اتصال',
            'nfc_protocol' => 'ISO/IEC 14443 Type A (NTAG213 / MIFARE)',
            'ai_engine' => 'Local 64-bit dHash + Arabic NLP Heuristic + Gemini 1.5 Vision',
            'sync_engine' => 'Encrypted Local SQLite -> Batch Sync REST Protocol',
            'payment_gateway' => 'Sham Cash & Direct Verification Hub',
        ];

        return view('dashboard.settings', compact('categories', 'governorates', 'diagnostics'));
    }

    public function storeCategory(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:categories,name',
        ]);

        Category::create($validated);

        return redirect()->back()->with('success', "تمت إضافة التصنيف الإغاثي الجديد ({$validated['name']}) بنجاح.");
    }

    public function updateCategory(Request $request, $id)
    {
        $cat = Category::findOrFail($id);
        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:categories,name,' . $cat->id,
        ]);

        $cat->update($validated);

        return redirect()->back()->with('success', "تم تحديث التصنيف إلى: ({$cat->name}).");
    }

    public function destroyCategory($id)
    {
        $cat = Category::findOrFail($id);
        $name = $cat->name;
        $cat->delete();

        return redirect()->back()->with('success', "تم حذف التصنيف ({$name}) بنجاح.");
    }

    public function storeGovernorate(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:governorates,name',
        ]);

        Governorate::create($validated);

        return redirect()->back()->with('success', "تمت إضافة المحافظة ({$validated['name']}) بنجاح إلى النظام.");
    }

    public function updateGovernorate(Request $request, $id)
    {
        $gov = Governorate::findOrFail($id);
        $validated = $request->validate([
            'name' => 'required|string|max:100|unique:governorates,name,' . $gov->id,
        ]);

        $gov->update($validated);

        return redirect()->back()->with('success', "تم تحديث المحافظة إلى: ({$gov->name}).");
    }

    public function destroyGovernorate($id)
    {
        $gov = Governorate::findOrFail($id);
        $name = $gov->name;
        $gov->delete();

        return redirect()->back()->with('success', "تم حذف المحافظة ({$name}) بنجاح.");
    }

    /**
     * 3D Interactive NFC Hardware Simulator Endpoints
     */
    public function nfcSimulatorData()
    {
        $beneficiaries = Beneficiary::with(['nfcCards', 'governorate'])
            ->whereNotNull('nfc_card_uid')
            ->orWhereHas('nfcCards')
            ->get()
            ->map(function ($b) {
                $uid = $b->nfc_card_uid ?: ($b->nfcCards->first()?->card_uid ?? '04:A2:3B:5C:8D:1E:80');
                return [
                    'id' => $b->id,
                    'name' => $b->full_name,
                    'national_id' => $b->national_id,
                    'phone' => $b->phone,
                    'family_members' => $b->family_members_count,
                    'district' => $b->district,
                    'governorate' => $b->governorate?->name ?? 'دمشق',
                    'vulnerability_score' => $b->vulnerability_score,
                    'nfc_uid' => $uid,
                    'qr_token' => $b->qr_token ?: 'ATHAR-FAM-' . str_pad($b->id, 4, '0', STR_PAD_LEFT),
                ];
            });

        $campaigns = AidCampaign::where('status', 'active')
            ->get(['id', 'title', 'item_type', 'target_families_count', 'distributed_families_count']);

        return response()->json([
            'success' => true,
            'beneficiaries' => $beneficiaries,
            'campaigns' => $campaigns,
        ]);
    }

    public function simulateNfcTap(Request $request)
    {
        $validated = $request->validate([
            'card_uid' => 'required|string',
            'campaign_id' => 'required|exists:aid_campaigns,id',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        $cardUid = trim($validated['card_uid']);
        $campaign = AidCampaign::findOrFail($validated['campaign_id']);

        // 1. Locate NFC Card or Beneficiary with this UID
        $nfcCard = NfcCard::where('card_uid', $cardUid)->with('beneficiary')->first();
        $beneficiary = $nfcCard?->beneficiary;

        if (!$beneficiary) {
            $beneficiary = Beneficiary::where('nfc_card_uid', $cardUid)->first();
        }

        if (!$beneficiary) {
            return response()->json([
                'success' => false,
                'status_code' => 'INVALID_CARD',
                'title' => 'بطاقة غير معروفة (Unknown RFID Chip)',
                'message' => "شريحة الـ NFC ذات المعرّف [{$cardUid}] غير مسجلة في قاعدة بيانات منظومة أثر! تم إحباط الاتصال لمنع الصرف غير المصرح به.",
            ], 404);
        }

        // 2. Anti-Fraud & Double-Dipping Check
        // Has this beneficiary already received this campaign item in the past?
        $existingDistribution = AidDistribution::where('beneficiary_id', $beneficiary->id)
            ->where('campaign_id', $campaign->id)
            ->latest('distributed_at')
            ->first();

        if ($existingDistribution) {
            return response()->json([
                'success' => false,
                'status_code' => 'DUPLICATE_BLOCKED',
                'title' => 'تم رصد محاولة ازدواجية وصرف مكرر! (Duplicate Fraud Prevented)',
                'message' => "المستفيد ({$beneficiary->full_name}) استلم مخصصاته من حملة ({$campaign->title}) سابقاً بتاريخ " . $existingDistribution->distributed_at->format('Y-m-d H:i') . ". تم إيقاف عملية الصرف فوراً لحماية أمانات المتبرعين.",
                'beneficiary' => [
                    'name' => $beneficiary->full_name,
                    'national_id' => $beneficiary->national_id,
                ],
                'previous_delivery' => [
                    'timestamp' => $existingDistribution->distributed_at->format('Y-m-d H:i:s'),
                    'method' => $existingDistribution->verification_method,
                    'gps' => "{$existingDistribution->latitude}, {$existingDistribution->longitude}",
                ]
            ], 422);
        }

        // 3. Process Aid Disbursement inside safe DB Transaction
        DB::beginTransaction();
        try {
            $volunteer = User::where('role', 'volunteer')->first() ?: User::first();
            $lat = $validated['latitude'] ?? ($beneficiary->latitude ?? 33.5138);
            $lng = $validated['longitude'] ?? ($beneficiary->longitude ?? 36.2765);

            // Deduct 1 item from warehouse if matched
            $inventoryItem = InventoryItem::where('available_stock', '>', 0)->first();
            if ($inventoryItem) {
                $inventoryItem->decrement('available_stock', 1);
                InventoryTransaction::create([
                    'item_id' => $inventoryItem->id,
                    'campaign_id' => $campaign->id,
                    'type' => 'outbound_distribution',
                    'quantity' => -1,
                    'performed_by' => $volunteer ? $volunteer->id : 1,
                    'notes' => "صرف لاتلامسي فوري عبر محاكي محطة NFC (المستفيد: {$beneficiary->full_name} - بطاقة: {$cardUid})",
                ]);
            }

            // Increment campaign distributed count
            $campaign->increment('distributed_families_count');

            // Create immutable distribution audit record
            $distribution = AidDistribution::create([
                'campaign_id' => $campaign->id,
                'beneficiary_id' => $beneficiary->id,
                'volunteer_id' => $volunteer ? $volunteer->id : 1,
                'verification_method' => 'nfc_tap',
                'latitude' => $lat,
                'longitude' => $lng,
                'distributed_at' => now(),
                'is_offline_synced' => false,
                'notes' => 'صرف لاتلامسي فيزيائي مباشر موثق بمحاكي محطة NFC الميدانية (3D Terminal Verified)',
            ]);

            DB::commit();

            $receiptHash = 'ATHAR-NFC-' . strtoupper(substr(hash('sha256', $cardUid . now()->timestamp . $beneficiary->national_id), 0, 12));

            return response()->json([
                'success' => true,
                'status_code' => 'VERIFIED_AND_DISBURSED',
                'title' => 'تم التحقق والصرف اللاتلامسي بنجاح (NFC Verified)',
                'message' => "تم توثيق استلام المخصصات الإغاثية للعائلة وحسم الكمية من المستودع وتوليد سند التدقيق الرقمي المشفر.",
                'receipt' => [
                    'token' => $receiptHash,
                    'timestamp' => now()->format('Y-m-d H:i:s'),
                    'terminal_id' => 'ATHAR-POS-DAMASCUS-01',
                    'gps' => "{$lat}° N, {$lng}° E",
                ],
                'beneficiary' => [
                    'id' => $beneficiary->id,
                    'name' => $beneficiary->full_name,
                    'national_id' => $beneficiary->national_id,
                    'family_members' => $beneficiary->family_members_count,
                    'district' => $beneficiary->district,
                    'governorate' => $beneficiary->governorate?->name ?? 'دمشق',
                    'vulnerability_score' => $beneficiary->vulnerability_score,
                ],
                'card' => [
                    'uid' => $cardUid,
                    'type' => 'ISO/IEC 14443-A (MIFARE Ultralight)',
                ],
                'campaign' => [
                    'title' => $campaign->title,
                    'item_type' => $campaign->item_type,
                ],
                'inventory' => [
                    'deducted_item' => $inventoryItem ? $inventoryItem->name : $campaign->item_type,
                    'remaining_stock' => $inventoryItem ? $inventoryItem->available_stock : null,
                ]
            ]);
        } catch (\Throwable $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'status_code' => 'SERVER_ERROR',
                'title' => 'خطأ في معالجة القيد المخزني',
                'message' => 'تعذر استكمال عملية الصرف اللاتلامسي: ' . $e->getMessage(),
            ], 500);
        }
    }
}
