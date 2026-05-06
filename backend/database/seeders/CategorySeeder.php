<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'إغاثة عاجلة', 'icon' => 'emergency'],
            ['name' => 'مساعدات غذائية', 'icon' => 'food'],
            ['name' => 'علاج طبي', 'icon' => 'medical'],
            ['name' => 'تعليم', 'icon' => 'education'],
            ['name' => 'سكن', 'icon' => 'housing'],
            ['name' => 'ملابس', 'icon' => 'clothes'],
            ['name' => 'مياه', 'icon' => 'water'],
            ['name' => 'دعم نفسي', 'icon' => 'support'],
            ['name' => 'بيئة', 'icon' => 'environment'],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }
    }
}
