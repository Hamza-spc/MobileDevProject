<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Document extends Model
{
    protected $fillable = [
        'student_id',
        'type',
        'file_path',
        'upload_date',
        'status',
        'verified_by',
        'verified_at',
    ];
}
