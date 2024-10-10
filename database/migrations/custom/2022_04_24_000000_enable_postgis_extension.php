<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

class EnablePostgisExtension extends Migration
{
    public function up()
    {
        if (env('DB_CONNECTION') === 'pgsql') {
            DB::statement('CREATE EXTENSION IF NOT EXISTS postgis');
            info('PostGIS extension enabled successfully');
        }
    }

    public function down()
    {
        if (env('DB_CONNECTION') === 'pgsql') {
            DB::statement('DROP EXTENSION IF EXISTS postgis');
            info('PostGIS extension dropped successfully');
        }
    }
}