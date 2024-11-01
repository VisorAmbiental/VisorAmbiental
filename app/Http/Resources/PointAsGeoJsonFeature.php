<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Auth;

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

        if ($this->location instanceof \MatanYadaev\EloquentSpatial\Objects\Point) {
            $longitude = $this->location->longitude;
            $latitude = $this->location->latitude;
        } elseif (is_string($this->location)) {
            // En caso de que sea un string, intenta extraer los valores de longitud y latitud
            preg_match('/POINT\(([-\d.]+) ([-\d.]+)\)/', $this->location, $matches);
            $longitude = $matches[1] ?? null;
            $latitude = $matches[2] ?? null;
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
}
