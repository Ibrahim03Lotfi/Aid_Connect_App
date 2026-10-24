<?php

namespace App\Http\Controllers\Api;

use App\Models\InventoryItem;
use App\Models\InventoryTransaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class InventoryController extends ApiController
{
    public function index(Request $request)
    {
        $query = InventoryItem::with('category');

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        $items = $query->latest()->get();

        return $this->successResponse($items);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'code' => 'required|string|max:50|unique:inventory_items,code',
            'category_id' => 'required|exists:categories,id',
            'unit' => 'required|string|max:50',
            'initial_stock' => 'required|integer|min:0',
            'minimum_threshold' => 'nullable|integer|min:1',
            'warehouse_location' => 'nullable|string|max:255',
        ]);

        $item = InventoryItem::create([
            'name' => $validated['name'],
            'code' => $validated['code'],
            'category_id' => $validated['category_id'],
            'unit' => $validated['unit'],
            'total_stock' => $validated['initial_stock'],
            'available_stock' => $validated['initial_stock'],
            'reserved_stock' => 0,
            'minimum_threshold' => $validated['minimum_threshold'] ?? 10,
            'warehouse_location' => $validated['warehouse_location'] ?? 'المستودع المركزي - دمشق',
        ]);

        if ($validated['initial_stock'] > 0) {
            InventoryTransaction::create([
                'item_id' => $item->id,
                'type' => 'inbound',
                'quantity' => $validated['initial_stock'],
                'performed_by' => $request->user()->id,
                'notes' => 'رصيد افتتاحي أولي',
            ]);
        }

        return $this->successResponse($item->load('category'), 'تمت إضافة المادة إلى المستودع بنجاح');
    }

    public function addStock(Request $request, $id)
    {
        $validated = $request->validate([
            'quantity' => 'required|integer|min:1',
            'notes' => 'nullable|string',
        ]);

        $item = InventoryItem::find($id);
        if (!$item) {
            return $this->errorResponse('المادة غير موجودة', 404);
        }

        return DB::transaction(function () use ($item, $validated, $request) {
            $item->increment('total_stock', $validated['quantity']);
            $item->increment('available_stock', $validated['quantity']);

            InventoryTransaction::create([
                'item_id' => $item->id,
                'type' => 'inbound',
                'quantity' => $validated['quantity'],
                'performed_by' => $request->user()->id,
                'notes' => $validated['notes'] ?? 'توريد كمية جديدة للمستودع',
            ]);

            return $this->successResponse($item->fresh(), 'تم توريد الكمية بنجاح إلى المستودع');
        });
    }

    public function transactions(Request $request, $id)
    {
        $transactions = InventoryTransaction::with('performer:id,name')
            ->where('item_id', $id)
            ->latest()
            ->paginate($request->per_page ?? 15);

        return $this->paginatedResponse($transactions->items(), $transactions);
    }
}
