<template>
  <CardFilter>
    <template #CardHeader>
      <div @click="isEcoregionExpanded = !isEcoregionExpanded" style="cursor: pointer;">
        <i class="fa-solid fa-circle-nodes"></i> Ecoregiones
        <i :class="isEcoregionExpanded ? 'fa-solid fa-chevron-up' : 'fa-solid fa-chevron-down'" class="ms-2"></i>
      </div>
    </template>

    <template #CardBody>
      <div v-if="ecoregions.length > 0 && isEcoregionExpanded">
        <div v-for="ecoregion in ecoregions" :key="ecoregion.id" class="form-check form-switch">
          <input class="form-check-input" type="checkbox" :value="ecoregion" :id="ecoregion.slug" v-model="checkedEcoregions" :disabled="loading">
          <label class="form-check-label" :for="ecoregion.slug">
            <i class="fa-solid fa-circle fa-fw" :style="`color:${ecoregion.color}`"></i> {{ ecoregion.name }}
          </label>
        </div>
      </div>
      <div v-else></div>
    </template>
  </CardFilter>

  <CardFilter v-for="category in categories" :key="category.id">
    <template #CardHeader>
      <div @click="isCategoryExpanded[category.id] = !isCategoryExpanded[category.id]" style="cursor: pointer;">
        <i :class="['fa-solid', `fa-${category.icon.code}`, 'fa-fw me-1']"></i> {{ category.name }}
        <i :class="isCategoryExpanded[category.id] ? 'fa-solid fa-chevron-up' : 'fa-solid fa-chevron-down'" class="ms-2"></i>
      </div>
    </template>

    <template #CardBody>
        <div v-if="category.subcategories.length > 0 && isCategoryExpanded[category.id]">
          <div v-for="subcategory in category.subcategories" :key="subcategory.id" class="form-check form-switch">
            <input class="form-check-input" type="checkbox" :value="subcategory" :id="subcategory.slug" v-model="checkedSubcategories" :disabled="loading">
            <label class="form-check-label" :for="subcategory.slug">
              <i class="fa-solid fa-circle fa-fw" :style="`color:${subcategory.backgroundColor}`"></i> {{ subcategory.name }}
            </label>
          </div>
        </div>
        <div v-else></div>
    </template>
  </CardFilter>

  <CardFilter>
    <template #CardHeader>
      <i class="fa-solid fa-layer-group"></i> Capas Estáticas
    </template>

    <template #CardBody>
      <div v-if="staticLayers.length > 0">
        <div v-for="staticLayer in staticLayers" :key="staticLayer.id" class="form-check form-switch">
          <input class="form-check-input" type="checkbox" :value="staticLayer" :id="staticLayer.id" v-model="checkedStaticLayer" :disabled="loading">
          <label class="form-check-label" :for="staticLayer.id">
            <i class="fa-solid fa-draw-polygon fa-fw" :style="`color:${staticLayer.color}`"></i>
            {{ staticLayer.name }}
          </label>
        </div>
      </div>
      <div v-else></div>
    </template>
  </CardFilter>
</template>

<script setup>
import { ref } from 'vue'
import { useMapStore } from '@/Stores/Map'
import { storeToRefs } from 'pinia'
import CardFilter from '@/Components/Map/Filters/CardFilter'

const isEcoregionExpanded = ref(false)
const isCategoryExpanded = ref({})
const mapStore = useMapStore()

const {
  categories,
  ecoregions,
  staticLayers,
  checkedEcoregions,
  checkedSubcategories,
  checkedStaticLayer,
  loading,
} = storeToRefs(mapStore)

</script>
