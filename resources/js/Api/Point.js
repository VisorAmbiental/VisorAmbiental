const Point = {
  get: () => axios.get(route('api.points.geojson')),

  storeImport: async (payload) => {
    // Solicitar token CSRF antes de la importación
    await axios.get(route('sanctum.csrf-cookie'), { withCredentials: true })

    // Enviar la solicitud de importación
    return axios.post(
      route('api.points.import'),
      payload,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
          'X-XSRF-TOKEN': getCookie('XSRF-TOKEN')
        },
        withCredentials: true, // Enviar cookies para autenticación
      }
    )
  },
}

export default Point
