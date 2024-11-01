<?php

namespace App\Casts;

use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Query\Expression;

class GeometryCast implements CastsAttributes
{
    public function get($model, string $key, $value, array $attributes)
    {
        return $value; // Deja tal cual para obtener el valor almacenado
    }

    public function set($model, string $key, $value, array $attributes)
    {
        if ($value instanceof Expression) {
            return $value; // Si es un DB::raw o similar, lo deja pasar
        }
        return new Expression("ST_GeomFromText('POINT({$value->longitude} {$value->latitude})', 4326)");
    }
}
