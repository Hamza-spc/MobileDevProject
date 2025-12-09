<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Registration extends Model
{
    protected $fillable = [
        'student_id',
        'program',
        'level',
        'school_year',
        'submission_date',
        'status',
        'notes',
    ];

    public function student() {
        return $this->belongsTo(Student::class);
    }
}
