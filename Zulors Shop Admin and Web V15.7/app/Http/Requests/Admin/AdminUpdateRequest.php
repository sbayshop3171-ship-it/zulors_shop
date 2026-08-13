<?php

namespace App\Http\Requests\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AdminUpdateRequest extends FormRequest
{
    protected $stopOnFirstFailure = false;

    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $rules = [
            'name' => 'required',
            'role_id' => 'required',
            'email' => [
                'required',
                'email',
                Rule::unique('admins', 'email')->ignore($this->route('id')),
            ],
            'image' => 'nullable|mimes:jpg,jpeg,png|max:2048',
        ];
        if ($this['password']) {
            $rules['password'] = 'required|regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*\W)(?!.*\s).{8,}$/|same:confirm_password';
        }
        return $rules;
    }

    public function messages(): array
    {
        return [
            'name.required' => translate('name_is_required'),
            'role_id.required' => translate('role_id_is_required'),
            'email.required' => translate('email_is_required'),
            'email.email' => translate('email_must_be_valid'),
            'email.unique' => translate('email_already_taken'),
            'image.mimes' => translate('The_image_type_must_be').'.jpg, .png, .jpeg',
            'image.max' => translate('The_image_may_not_be_greater_than_2_MB'),
            'password.regex' => translate('The_password_must_be_at_least_8_characters_long_and_contain_at_least_one_uppercase_letter').','.translate('_one_lowercase_letter').','.translate('_one_digit_').','.translate('_one_special_character').','.translate('_and_no_spaces').'.',
        ];
    }

}
