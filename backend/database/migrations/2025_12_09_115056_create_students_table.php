<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->unique();
            $table->string('first_name');
            $table->string('last_name');
            $table->string('email')->nullable();
            $table->string('phone_number')->nullable();
            $table->date('date_of_birth');
            $table->string('birth_place')->nullable();
            $table->string('address')->nullable();
            $table->string('gender', 10)->nullable();
            $table->integer('bac_year')->nullable();
            $table->string('bac_series')->nullable();
            $table->float('bac_average')->nullable();
            $table->string('bac_school')->nullable();
            $table->json('parent_info')->nullable();
            $table->string('tutor_contact')->nullable();
            $table->string('cin_number')->unique();
            $table->enum('registration_status', ['pending','verified','rejected'])->default('pending');
            $table->timestamps();
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('students');
    }
};
