<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

class EnablePostgisExtension extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (env('DB_CONNECTION') === 'pgsql') {
            // Habilitar la extensión PostGIS
            DB::statement('CREATE EXTENSION IF NOT EXISTS postgis');
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        if (env('DB_CONNECTION') === 'pgsql') {
            // Eliminar la extensión PostGIS si es necesario
            DB::statement('DROP EXTENSION IF EXISTS postgis');
        }
    }
}