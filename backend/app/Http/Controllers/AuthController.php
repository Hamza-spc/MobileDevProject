<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Student;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $fields = $request->validate([
            'first_name' => 'required|string',
            'last_name' => 'required|string',
            'date_of_birth' => 'required|date',
            'cin_number' => 'required|string|unique:students,cin_number',
            'email' => 'required|string|email|unique:users,email',
            'password' => 'required|string|confirmed'
        ]);

        $user = User::create([
            'name' => $fields['first_name'].' '.$fields['last_name'],
            'email' => $fields['email'],
            'password' => bcrypt($fields['password'])
        ]);

        $student = Student::create([
            'user_id' => $user->id,
            'first_name' => $fields['first_name'],
            'last_name' => $fields['last_name'],
            'date_of_birth' => $fields['date_of_birth'],
            'cin_number' => $fields['cin_number'],
            'email' => $fields['email'],
        ]);

        $token = $user->createToken('mobileapp')->plainTextToken;

        return response()->json(['user' => $user, 'student'=>$student, 'token' => $token]);
    }

    public function login(Request $request)
    {
        $fields = $request->validate([
            'email' => 'required|string|email',
            'password' => 'required|string'
        ]);

        $user = User::where('email', $fields['email'])->first();

        if (!$user || !Hash::check($fields['password'], $user->password)) {
            return response(['message' => 'Bad credentials'], 401);
        }

        $token = $user->createToken('mobileapp')->plainTextToken;

        return response()->json(['user' => $user, 'token' => $token]);
    }

    public function user(Request $request)
    {
        return response()->json($request->user());
    }
}
