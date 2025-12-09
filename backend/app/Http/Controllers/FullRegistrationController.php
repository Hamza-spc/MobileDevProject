<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Student;
use App\Models\Registration;
use App\Models\Document;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class FullRegistrationController extends Controller
{
    public function registerFull(Request $request)
    {
        // Validation des infos principales
        $fields = $request->validate([
            'first_name'       => 'required|string',
            'last_name'        => 'required|string',
            'email'            => 'required|string|email|unique:users,email',
            'phone_number'     => 'required|string',
            'date_of_birth'    => 'required|date',
            'birth_place'      => 'required|string',
            'address'          => 'required|string',
            'gender'           => 'nullable|string',
            'bac_year'         => 'required|integer',
            'bac_series'       => 'required|string',
            'bac_average'      => 'required|numeric',
            'bac_school'       => 'required|string',
            'parent_info'      => 'nullable|json',
            'tutor_contact'    => 'nullable|string',
            'cin_number'       => 'required|string|unique:students,cin_number',
            'password'         => 'required|string|confirmed',
            'program'          => 'required|string',
            'level'            => 'required|string',
            'school_year'      => 'required|string',

            // Fichiers requis
            'photo_bac'        => 'required|file',
            'cin_recto'        => 'required|file',
            'cin_verso'        => 'required|file',
            'photo_perso'      => 'nullable|file',
        ]);

        // Création de l'utilisateur
        $user = User::create([
            'name' => $fields['first_name'].' '.$fields['last_name'],
            'email' => $fields['email'],
            'password' => bcrypt($fields['password'])
        ]);

        // Création du profil étudiant
        $student = Student::create([
            'user_id'           => $user->id,
            'first_name'        => $fields['first_name'],
            'last_name'         => $fields['last_name'],
            'email'             => $fields['email'],
            'phone_number'      => $fields['phone_number'],
            'date_of_birth'     => $fields['date_of_birth'],
            'birth_place'       => $fields['birth_place'],
            'address'           => $fields['address'],
            'gender'            => $fields['gender'] ?? null,
            'bac_year'          => $fields['bac_year'],
            'bac_series'        => $fields['bac_series'],
            'bac_average'       => $fields['bac_average'],
            'bac_school'        => $fields['bac_school'],
            'parent_info'       => $fields['parent_info'] ?? null,
            'tutor_contact'     => $fields['tutor_contact'] ?? null,
            'cin_number'        => $fields['cin_number'],
        ]);

        // Création de la demande d'inscription
        $registration = Registration::create([
            'student_id'    => $student->id,
            'program'       => $fields['program'],
            'level'         => $fields['level'],
            'school_year'   => $fields['school_year'],
            'submission_date' => now(),
            'status'        => 'pending',
        ]);

        // Upload des fichiers et création des documents associés
        $documents = [];
        $docFields = [
            'photo_bac' => 'photo_bac',
            'cin_recto' => 'cin_recto',
            'cin_verso' => 'cin_verso',
            'photo_perso' => 'photo_perso',
        ];
        foreach ($docFields as $key => $type) {
            if ($request->hasFile($key)) {
                $file = $request->file($key);
                $path = $file->storeAs('public/uploads', Str::random(10).'_'.$file->getClientOriginalName());
                $document = Document::create([
                    'student_id' => $student->id,
                    'type' => $type,
                    'file_path' => Storage::url($path),
                    'upload_date' => now(),
                    'status' => 'pending',
                ]);
                $documents[] = $document;
            }
        }

        // On génère le token d'accès
        $token = $user->createToken('mobileapp')->plainTextToken;

        return response()->json([
            'user' => $user,
            'student' => $student,
            'registration' => $registration,
            'documents' => $documents,
            'token' => $token,
        ]);
    }
}
