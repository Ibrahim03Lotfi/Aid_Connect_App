<?php

namespace Database\Seeders;

use App\Models\Governorate;
use Illuminate\Database\Seeder;

class GovernorateSeeder extends Seeder
{
    public function run(): void
    {
        // Reset to Syrian governorates (dev/demo seed)
        Governorate::query()->delete();

        $governorates = [
            ['name' => 'دمشق', 'code' => 'Damascus'],
            ['name' => 'ريف دمشق', 'code' => 'RifDimashq'],
            ['name' => 'حلب', 'code' => 'Aleppo'],
            ['name' => 'حمص', 'code' => 'Homs'],
            ['name' => 'حماة', 'code' => 'Hama'],
            ['name' => 'اللاذقية', 'code' => 'Latakia'],
            ['name' => 'طرطوس', 'code' => 'Tartus'],
            ['name' => 'إدلب', 'code' => 'Idlib'],
            ['name' => 'الرقة', 'code' => 'Raqqa'],
            ['name' => 'دير الزور', 'code' => 'DeirEzZor'],
            ['name' => 'الحسكة', 'code' => 'AlHasakah'],
            ['name' => 'درعا', 'code' => 'Daraa'],
            ['name' => 'السويداء', 'code' => 'AsSuwayda'],
            ['name' => 'القنيطرة', 'code' => 'Quneitra'],
        ];

        foreach ($governorates as $governorate) {
            Governorate::create($governorate);
        }
    }
}
