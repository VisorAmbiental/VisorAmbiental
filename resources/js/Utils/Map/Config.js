/**
 * Config for map
 */

const Config = {
  apiKey: () => process.env.MIX_MAP_ACCESS_TOKEN || '',
  defaultStyle: () => process.env.MIX_MAP_DEFAULT_STYLE ||
    'mapbox://styles/mapbox/streets-v9',
  center: () => [-65.764424, -23.319975] || [0, 0],
  zoom: () => 7 || 7,
}

export default Config
