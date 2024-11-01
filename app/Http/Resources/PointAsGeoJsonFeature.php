<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Auth;
use MatanYadaev\EloquentSpatial\Objects\Point;

class PointAsGeoJsonFeature extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {
        $longitude = null;
        $latitude = null;
        // Si es un objeto Point, obtenemos directamente las coordenadas
        if ($this->location instanceof Point) {
            $longitude = $this->location->longitude;
            $latitude = $this->location->latitude;
        // Si es una cadena, verifica si es WKT o WKB y convierte en coordenadas
        } elseif (is_string($this->location)) {
            if (preg_match('/^POINT\(([-\d.]+) ([-\d.]+)\)$/', $this->location, $matches)) {
                $longitude = (float) $matches[1];
                $latitude = (float) $matches[2];
            } else {
                // Si es WKB (Well-Known Binary en hexadecimal), intenta convertirlo
                $coord = $this->convertWKBToPoint($this->location);
                $longitude = $coord['longitude'];
                $latitude = $$coord['latitude'];
            }
        }

        return [
            'type' => 'Feature',
            'geometry' => [
                'type' => 'Point',
                'coordinates' => [
                    $longitude,
                    $latitude
                ],
            ],
            'properties' => [
                'id' => $this->resource_id,
                'title' => $this->title,
                'description' => $this->description,
                'institution' => $this->institution,
                'ecoregion_id' => $this->ecoregion_id,
                'ecoregion' => new EcoregionResource($this->whenLoaded('ecoregion')),
                'source' => $this->source,
                'altitude' => $this->altitude,
                'url' => $this->url,
                'marker_code' => $this->marker->code(),
                'category_id' => $this->category_id,
                'subcategory_id' => $this->subcategory_id,
                'category' => new CategoryResource($this->whenLoaded('category')),
                'subcategory' => new SubcategoryResource($this->whenLoaded('subcategory')),
                'readonly' => Auth::check(),
            ],
        ];
    }


    /**
     * Convierte un valor WKB en hexadecimal a coordenadas de longitud y latitud.
     *
     * @param string $wkb
     * @return array
     */
    private function convertWKBToPoint($wkb)
    {
        // Convierte de hexadecimal a binario
        $wkb = hex2bin($wkb);

        // Extrae los valores binarios de longitud y latitud (punto flotante de 64 bits)
        $longitude = unpack('d', substr($wkb, 9, 8))[1];
        $latitude = unpack('d', substr($wkb, 17, 8))[1];

        return [
            'longitude' => $longitude,
            'latitude' => $latitude,
        ];
    }
}
