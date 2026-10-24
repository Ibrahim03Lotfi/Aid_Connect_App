<?php

namespace App\Services\Ai;

use App\Models\CaseImageFingerprint;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Log;

class ImageFingerprintService
{
    /**
     * Compute 64-bit difference hash (dHash) for an image.
     *
     * @param UploadedFile|string $imageFile
     * @return string 16-char hex string (64 bits)
     */
    public function computeFingerprint($imageFile): string
    {
        $path = $imageFile instanceof UploadedFile ? $imageFile->getRealPath() : (string)$imageFile;

        if (!file_exists($path) || !is_readable($path)) {
            // Fallback content-based deterministic 64-bit fingerprint
            return substr(hash('sha256', (string)$path), 0, 16);
        }

        try {
            $info = @getimagesize($path);
            if (!$info) {
                return substr(hash('sha256', file_get_contents($path)), 0, 16);
            }

            $src = null;
            switch ($info[2]) {
                case IMAGETYPE_JPEG:
                    $src = @imagecreatefromjpeg($path);
                    break;
                case IMAGETYPE_PNG:
                    $src = @imagecreatefrompng($path);
                    break;
                case IMAGETYPE_WEBP:
                    $src = @imagecreatefromwebp($path);
                    break;
            }

            if (!$src) {
                return substr(hash('sha256', file_get_contents($path)), 0, 16);
            }

            // 1. Resize to 9x8 pixels (72 pixels)
            $width = 9;
            $height = 8;
            $resized = imagecreatetruecolor($width, $height);
            imagecopyresampled($resized, $src, 0, 0, 0, 0, $width, $height, $info[0], $info[1]);
            imagedestroy($src);

            // 2. Grayscale & Compute horizontal differences
            $binaryString = '';
            for ($y = 0; $y < $height; $y++) {
                $rowGrays = [];
                for ($x = 0; $x < $width; $x++) {
                    $rgb = imagecolorat($resized, $x, $y);
                    $r = ($rgb >> 16) & 0xFF;
                    $g = ($rgb >> 8) & 0xFF;
                    $b = $rgb & 0xFF;
                    $rowGrays[] = (int)(0.299 * $r + 0.587 * $g + 0.114 * $b);
                }
                for ($x = 0; $x < $width - 1; $x++) {
                    $binaryString .= ($rowGrays[$x] > $rowGrays[$x + 1]) ? '1' : '0';
                }
            }
            imagedestroy($resized);

            // 3. Convert 64 bits binary string to 16 hex characters
            $hex = '';
            for ($i = 0; $i < 64; $i += 4) {
                $nibble = substr($binaryString, $i, 4);
                $hex .= dechex(bindec($nibble));
            }

            return str_pad($hex, 16, '0', STR_PAD_LEFT);
        } catch (\Throwable $e) {
            Log::warning('dHash generation failed: ' . $e->getMessage());
            return substr(hash('sha256', file_get_contents($path)), 0, 16);
        }
    }

    /**
     * Compute Hamming distance between two 64-bit hex fingerprints.
     */
    public function hammingDistance(string $hash1, string $hash2): int
    {
        $hash1 = str_pad(strtolower($hash1), 16, '0', STR_PAD_LEFT);
        $hash2 = str_pad(strtolower($hash2), 16, '0', STR_PAD_LEFT);

        $dist = 0;
        for ($i = 0; $i < 16; $i++) {
            $n1 = hexdec($hash1[$i]);
            $n2 = hexdec($hash2[$i]);
            $xor = $n1 ^ $n2;
            $dist += substr_count(decbin($xor), '1');
        }
        return $dist;
    }

    /**
     * Check if an uploaded image has been previously used in another case (Fraud Detection).
     *
     * @param UploadedFile|string $imageFile
     * @param int|null $excludeCaseId
     * @return array
     */
    public function checkFraud($imageFile, ?int $excludeCaseId = null): array
    {
        $fingerprint = $this->computeFingerprint($imageFile);

        $query = CaseImageFingerprint::with('case:id,title,status,created_at');
        if ($excludeCaseId) {
            $query->where('case_id', '!=', $excludeCaseId);
        }

        $existing = $query->latest()->take(200)->get();

        $minDistance = 64;
        $matchedRecord = null;

        foreach ($existing as $record) {
            $dist = $this->hammingDistance($fingerprint, $record->phash);
            if ($dist < $minDistance) {
                $minDistance = $dist;
                $matchedRecord = $record;
            }
        }

        // Hamming distance <= 5 implies >92% visual similarity
        $isDuplicate = ($minDistance <= 5);
        $similarity = round(max(0, (1 - ($minDistance / 64))) * 100, 1);

        if ($isDuplicate && $matchedRecord) {
            return [
                'is_duplicate' => true,
                'phash' => $fingerprint,
                'hamming_distance' => $minDistance,
                'similarity_percentage' => $similarity,
                'duplicate_case_id' => $matchedRecord->case_id,
                'duplicate_case_title' => $matchedRecord->case?->title ?? 'حالة سابقة',
                'duplicate_image_url' => $matchedRecord->image_path,
                'flag' => 'suspicious_duplicate_image',
                'message' => "تحذير أمني: الصورة متطابقة بنسبة {$similarity}% مع صورة مرفوعة سابقاً للحالة رقم #{$matchedRecord->case_id}.",
            ];
        }

        return [
            'is_duplicate' => false,
            'phash' => $fingerprint,
            'hamming_distance' => $minDistance,
            'similarity_percentage' => $similarity,
            'duplicate_case_id' => null,
            'flag' => 'clean',
            'message' => 'الصورة فريدة وجديدة ولم يتم تسجيل تكرارها مسبقاً.',
        ];
    }

    /**
     * Store fingerprint for an image linked to a case.
     */
    public function storeFingerprint(int $caseId, string $imagePath, ?string $hash = null): CaseImageFingerprint
    {
        $phash = $hash ?: $this->computeFingerprint($imagePath);

        return CaseImageFingerprint::create([
            'case_id' => $caseId,
            'image_path' => $imagePath,
            'phash' => $phash,
        ]);
    }
}
