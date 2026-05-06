<?php

namespace App\Http\Controllers\Api;

use App\Models\Category;

class CategoryController extends ApiController
{
    public function index()
    {
        $categories = Category::withCount('cases')->get()->map(function ($category) {
            return [
                'id' => $category->id,
                'name' => $category->name,
                'icon' => $category->icon,
                'cases_count' => $category->cases_count,
            ];
        });

        return $this->successResponse($categories);
    }
}
