<?php

namespace Database\Seeders;

use App\Models\Governorate;
use Illuminate\Database\Seeder;

class GovernorateSeeder extends Seeder
{
    public function run(): void
    {
        $governorates = [
            ['name' => 'القاهرة', 'code' => 'Cairo'],
            ['name' => 'الإسكندرية', 'code' => 'Alexandria'],
            ['name' => 'الجيزة', 'code' => 'Giza'],
            ['name' => 'المنصورة', 'code' => 'Mansoura'],
            ['name' => 'أسوان', 'code' => 'Aswan'],
            ['name' => 'الأقصر', 'code' => 'Luxor'],
            ['name' => 'بورسعيد', 'code' => 'PortSaid'],
            ['name' => 'الإسماعيلية', 'code' => 'Ismailia'],
            ['name' => 'السويس', 'code' => 'Suez'],
            ['name' => 'الفيوم', 'code' => 'Fayoum'],
            ['name' => 'بني سويف', 'code' => 'BeniSuef'],
            ['name' => 'المنيا', 'code' => 'Minya'],
            ['name' => 'أسيوط', 'code' => 'Assiut'],
            ['name' => 'سوهاج', 'code' => 'Sohag'],
            ['name' => 'قنا', 'code' => 'Qena'],
            ['name' => 'الغردقة', 'code' => 'Hurghada'],
            ['name' => 'شمال سيناء', 'code' => 'NorthSinai'],
            ['name' => 'جنوب سيناء', 'code' => 'SouthSinai'],
            ['name' => 'الدقهلية', 'code' => 'Dakahlia'],
            ['name' => 'الشرقية', 'code' => 'Sharqia'],
            ['name' => 'الغربية', 'code' => 'Gharbia'],
            ['name' => 'كفر الشيخ', 'code' => 'KafrElSheikh'],
            ['name' => 'دمياط', 'code' => 'Damietta'],
            ['name' => 'البحيرة', 'code' => 'Beheira'],
            ['name' => 'القليوبية', 'code' => 'Qalyubia'],
            ['name' => 'المنوفية', 'code' => 'Monufia'],
            ['name' => 'مطروح', 'code' => 'Matrouh'],
        ];

        foreach ($governorates as $governorate) {
            Governorate::create($governorate);
        }
    }
}
