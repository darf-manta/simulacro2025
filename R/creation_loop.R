library(dplyr)
library(htmlwidgets)
library(leaflet)
library(sf)

break_label = function(label) {
   broken_label = c()
   split_label = strsplit(label, " ")[[1]]
   if(length(split_label) < 4) return(label)
   total_parts = ceiling(length(split_label) / 3)
   for(i in 1:total_parts) {
      if(i != total_parts) label_part = split_label[1:3 + 3*i - 3] else {
         label_part = split_label[setdiff(1:length(split_label), 1:(3*total_parts - 3))] }
      broken_label = c(broken_label, paste(label_part, collapse = " ")) }
   paste(broken_label, collapse = "\n")
}

data_version = "20250126"

tsunami = read_sf(paste0("data/manta_pet_tsunami_", data_version, ".geojson"))

rutas = read_sf(paste0("data/manta_pet_rutas_", data_version, ".geojson"))

zonas = read_sf(paste0("data/manta_pet_zonas_", data_version, ".geojson")) |> st_centroid()

zonas_icon = list(iconUrl = "data/zs.png", iconSize = c(80, 80))

puntos = read_sf(paste0("data/manta_pet_puntos_", data_version, ".geojson"))

puntos_icon = list(iconUrl = "data/pe.png", iconSize = c(50, 50))

participantes = read_sf(paste0("data/manta_sim_participantes_", data_version, ".geojson"))

icon_cg = list(iconSize = c(25, 25), iconUrl = "data/people-roof-solid.svg")
icon_cb = list(iconSize = c(25, 25), iconUrl = "data/people-group-solid.svg")
icon_dp = list(iconSize = c(25, 25), iconUrl = "data/landmark-flag-solid.svg")
icon_er = list(iconSize = c(25, 25), iconUrl = "data/building-solid.svg")
icon_ep = list(iconSize = c(25, 25), iconUrl = "data/building-flag-solid.svg")
icon_ie = list(iconSize = c(25, 25), iconUrl = "data/school-flag-solid.svg")
icon_oe = list(iconSize = c(25, 25), iconUrl = "data/people-line-solid.svg")

paths = pathOptions(interactive = FALSE)

popups = popupOptions(autoPan = TRUE, closeButton = FALSE)

parroquias = c("Manta", "Tarqui", "Los Esteros", "San Mateo", "Santa Marianita", "San Lorenzo")

parroquias_center = c(
   c(-80.725, -0.951),
   c(-80.715, -0.955),
   c(-80.700, -0.953),
   c(-80.810, -0.958),
   c(-80.848, -0.990),
   c(-80.908, -1.066)
) |> matrix(dimnames = list(1:2, parroquias), nrow = 2)

target_dir = "docs"

target_canton = FALSE

for(target_parroquia in parroquias) {

   target_html = if_else(
      target_canton,
      "canton-manta.html",
      paste0("parroquia-", sub(" ", "-", tolower(target_parroquia)), ".html")
   )

   source("R/map_creation.R")

   # file.path("tmp", target_html) |>
   #    prettifyAddins::prettify_V8(tabSize = 2) |>
   #    cat(file = file.path("tmp", target_html))

   target_html_content = readLines(file.path("tmp", target_html))

   i = which(target_html_content == "</head>")

   target_html_content = c(
      target_html_content[ 1 : (i-1) ],
      readLines("HTML/add_locatecontrol.html"),
      readLines("HTML/enhance_zoom.html"),
      target_html_content[ i : length(target_html_content) ]
   )

   writeLines(target_html_content, file.path(target_dir, target_html))

   paste0(
      "qrencode -l M -s 15 --foreground=ab0004 -o QR/",
      sub("html", "png", target_html),
      " https://darf-manta.github.io/simulacro2025/",
      target_html
   ) |> system()

   if(target_canton) break
}
