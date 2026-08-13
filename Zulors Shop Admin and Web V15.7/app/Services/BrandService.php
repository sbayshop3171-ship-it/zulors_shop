<?php

namespace App\Services;

use App\Traits\FileManagerTrait;
use App\Traits\GeneratesUniqueSlug;

class BrandService
{
    use FileManagerTrait, GeneratesUniqueSlug;

    public function getAddData(object $request): array
    {
        $storage = config('filesystems.disks.default') ?? 'public';
        $name = $request['name'][array_search('en', $request['lang'])];
        return [
            'name' => $name,
            'slug' => $this->generateModelUniqueSlug(name: $name, type: 'brand'),
            'image' => $this->upload('brand/', 'webp', $request->file('image')),
            'image_storage_type' => $request->has('image') ? $storage : null,
            'image_alt_text' => $request['image_alt_text'] ?? null,
            'status' => 1,
        ];
    }

    public function getUpdateData(object $request, object $data): array
    {
        $storage = config('filesystems.disks.default') ?? 'public';
        $image = $request->file('image') ? $this->update('brand/', $data['image'],'webp', $request->file('image')) : $data['image'];
        $name = $request->name[array_search('en', $request['lang'])];
        return [
            'name' => $name,
            'slug' => $this->generateModelUniqueSlug(name: $name, type: 'brand', id: $data['id']),
            'image' => $image,
            'image_storage_type' => $request->file('image') ? $storage : $data['image_storage_type'],
            'image_alt_text' => $request['image_alt_text']??null,
        ];
    }

    public function deleteImage(object $data): bool
    {
        if ($data['image']) {$this->delete('profile/'.$data['image']);}
        return true;
    }

}
