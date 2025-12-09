<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        $email = 'admin@etudes.com';
        if (!User::where('email', $email)->first()) {
            User::create([
                'name' => 'Admin',
                'email' => $email,
                'password' => Hash::make('123456'),
            ]);
        }
    }
}
