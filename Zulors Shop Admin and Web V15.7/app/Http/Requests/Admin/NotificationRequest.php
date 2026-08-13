<?php

namespace App\Http\Requests\Admin;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class NotificationRequest extends FormRequest
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
     * @return array<string, ValidationRule|array|string>
     */
    public function rules(): array
    {
        return [
            'title' => 'required',
            'description' => 'required',
            'image' => 'nullable|image|mimes:jpg,jpeg,png,gif|max:2048',
        ];
    }

    /**
     * @return array[title.required: string]
     */
    public function messages(): array
    {
        return [
            'title.required' => translate('title_is_required'),
            'description.required' => translate('description_is_required'),
            'image.mimes' => translate('only_jpg_jpeg_png_gif_allowed'),
            'image.max' => translate('The_image_may_not_be_greater_than_2_MB_.'),
        ];
    }
}
