<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Student;
use App\Models\Registration;
use App\Models\Document;

class AdminPanelController extends Controller
{
    public function listRegistrations()
    {
        $list = Registration::with(['student','student.documents'])
            ->orderByDesc('created_at')->get();
        return response()->json($list);
    }

    public function showRegistration($id)
    {
        $registration = Registration::with(['student','student.documents'])
            ->findOrFail($id);
        return response()->json($registration);
    }

    public function updateRegistrationStatus(Request $request, $id)
    {
        $data = $request->validate([
            'status' => 'required|in:approved,rejected',
            'notes' => 'nullable|string'
        ]);
        $registration = Registration::findOrFail($id);
        $registration->status = $data['status'];
        if (isset($data['notes'])) $registration->notes = $data['notes'];
        $registration->save();
        return response()->json(['message'=>'Statut mis à jour','registration' => $registration]);
    }
}
