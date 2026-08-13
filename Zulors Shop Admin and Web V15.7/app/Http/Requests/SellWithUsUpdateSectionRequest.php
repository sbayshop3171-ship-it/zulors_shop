<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SellWithUsUpdateSectionRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'title' => 'required|string|max:50',
            'sub_title' => 'required|string|max:50',
            'image' => 'sometimes|'. getFileUploadFormats(skip: '.svg,.gif,.webp', asRule: 'true') .'|max:'. (getFileUploadMaxSize() * 1024),
        ];
    }
    public function messages(): array{
        return [
            'title.required' => translate('title_is_required'),
            'sub_title.required' => translate('sub_title_is_required'),
            'image.required' => translate('image_is_required'),
            'image.mimes' => translate('image_type_must_be'). ' ' . getFileUploadFormats(skip: '.svg,.gif,.webp'),
            'image.max' => translate('image_max_size_is'). ' ' . getFileUploadMaxSize() . ' MB',
        ];
    }
}
