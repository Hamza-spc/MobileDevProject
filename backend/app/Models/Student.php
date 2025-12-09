<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    protected $fillable = [
        'user_id',
        'first_name',
        'last_name',
        'email',
        'phone_number',
        'date_of_birth',
        'birth_place',
        'address',
        'gender',
        'bac_year',
        'bac_series',
        'bac_average',
        'bac_school',
        'parent_info',
        'tutor_contact',
        'cin_number',
        'registration_status',
    ];

    public function documents() {
        return $this->hasMany(Document::class);
    }

    public function registrations() {
        return $this->hasMany(Registration::class);
    }
}
