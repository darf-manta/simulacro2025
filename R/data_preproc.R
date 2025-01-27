library(dplyr)
library(sf)

data_gpkg = "tmp/manta_evacuacion_tsunami_rev09.gpkg"

data_tsunami = read_sf(data_gpkg, "inocar2019_area_inundacion") |>
   st_zm() |> st_transform(4326) |>
   st_simplify(dTolerance = 5)

write_sf(data_tsunami, paste0("data/manta_pet_tsunami_", format(Sys.Date(), "%Y%m%d"), ".geojson"))

data_zonas = read_sf(data_gpkg, "gadm2024_zonas_seguras") |>
   select(id_zona, nom_zona, parroquia, maps_url) |>
   st_transform(4326)

write_sf(data_zonas, paste0("data/manta_pet_zonas_", format(Sys.Date(), "%Y%m%d"), ".geojson"))

data_puntos = read_sf(data_gpkg, "gadm2024_puntos_encuentro") |>
   left_join(st_drop_geometry(data_zonas) |> select(id_zona, nom_zona), by = "id_zona") |>
   select(id_punto, nom_punto, nom_zona, parroquia) |>
   mutate(nom_zona = if_else(is.na(nom_zona), "sin zona segura", nom_zona)) |>
   st_transform(4326)

write_sf(data_puntos, paste0("data/manta_pet_puntos_", format(Sys.Date(), "%Y%m%d"), ".geojson"))

data_rutas = read_sf(data_gpkg, "gadm2024_rutas_evacuacion") |>
   left_join(st_drop_geometry(data_zonas), by = "id_zona") |>
   left_join(st_drop_geometry(data_puntos) |>
                select(id_punto, nom_punto, parroquia2 = parroquia), by = "id_punto") |>
   mutate(nom_zona = if_else(is.na(nom_zona), "sin zona segura", nom_zona),
          nom_punto = if_else(is.na(nom_punto), "sin punto de encuentro", nom_punto),
          parroquia = if_else(is.na(parroquia), parroquia2, parroquia)) |>
   select(nom_punto, nom_zona, parroquia) |>
   st_transform(4326)

write_sf(data_rutas, paste0("data/manta_pet_rutas_", format(Sys.Date(), "%Y%m%d"), ".geojson"))
