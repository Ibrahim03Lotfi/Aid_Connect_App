<?php

namespace App\Http\Controllers\Api;

use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends ApiController
{
    public function index(Request $request)
    {
        $notifications = Notification::where('user_id', $request->user()->id)
            ->latest()
            ->paginate($request->per_page ?? 20);

        $data = $notifications->map(function ($notification) {
            return [
                'id' => $notification->id,
                'title' => $notification->title,
                'body' => $notification->body,
                'type' => $notification->type,
                'is_read' => $notification->is_read,
                'related_case_id' => $notification->related_case_id,
                'related_entity_name' => $notification->related_entity_name,
                'rejection_reason' => $notification->rejection_reason,
                'created_at' => $notification->created_at->toIso8601String(),
            ];
        });

        return $this->paginatedResponse($data, $notifications);
    }

    public function stats(Request $request)
    {
        $userId = $request->user()->id;
        $total = Notification::where('user_id', $userId)->count();
        $unread = Notification::where('user_id', $userId)->where('is_read', false)->count();

        return $this->successResponse([
            'total' => $total,
            'unread' => $unread,
        ]);
    }

    public function markAsRead(Request $request, $id)
    {
        Notification::where('user_id', $request->user()->id)
            ->where('id', $id)
            ->update(['is_read' => true]);

        return $this->successResponse(null, 'Notification marked as read');
    }

    public function markAllAsRead(Request $request)
    {
        Notification::where('user_id', $request->user()->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return $this->successResponse(null, 'All notifications marked as read');
    }

    public function destroy(Request $request, $id)
    {
        Notification::where('user_id', $request->user()->id)
            ->where('id', $id)
            ->delete();

        return $this->successResponse(null, 'Notification deleted');
    }
}
