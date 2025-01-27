library(dplyr)
library(htmlwidgets)
library(leaflet)
library(sf)

data_version = "20250126"

tsunami = read_sf(paste0("data/manta_pet_tsunami_", data_version, ".geojson"))

rutas = read_sf(paste0("data/manta_pet_rutas_", data_version, ".geojson"))

zonas = read_sf(paste0("data/manta_pet_zonas_", data_version, ".geojson")) |> st_centroid()

zonas_icon = list(iconUrl = "data/zs.png", iconSize = c(80, 80))

puntos = read_sf(paste0("data/manta_pet_puntos_", data_version, ".geojson"))

puntos_icon = list(iconUrl = "data/pe.png", iconSize = c(50, 50))

participantes = read_sf(paste0("data/manta_sim_participantes_", data_version, ".geojson"))

# my_icons = function(type) {
#    if(type == "Comité Comunitario de GdR") return(
#       list(iconSize = c(40, 40), iconUrl = "data/people-roof-solid.svg")
#    )
#    if(type == "Departamento Municipal") return(
#       list(iconSize = c(40, 40), iconUrl = "data/landmark-flag-solid.svg")
#    )
#    if(type == "Empresa Privada") return(
#       list(iconSize = c(40, 40), iconUrl = "data/building-solid.svg")
#    )
#    if(type == "Empresa Pública") return(
#       list(iconSize = c(40, 40), iconUrl = "data/building-flag-solid.svg")
#    )
#    if(type == "Institución Educativa") return(
#       list(iconSize = c(40, 40), iconUrl = "data/school-flag-solid.svg")
#    )
#    return(
#       list(iconSize = c(40, 40), iconUrl = "data/people-group-solid.svg")
#    )
# }

icon_cg = list(iconSize = c(25, 25), iconUrl = "data/people-roof-solid.svg")
icon_cb = list(iconSize = c(25, 25), iconUrl = "data/people-group-solid.svg")
icon_dp = list(iconSize = c(25, 25), iconUrl = "data/landmark-flag-solid.svg")
icon_er = list(iconSize = c(25, 25), iconUrl = "data/building-solid.svg")
icon_ep = list(iconSize = c(25, 25), iconUrl = "data/building-flag-solid.svg")
icon_ie = list(iconSize = c(25, 25), iconUrl = "data/school-flag-solid.svg")

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

for(target_parroquia in parroquias) {

   target_html = paste0("parroquia-", sub(" ", "-", tolower(target_parroquia)), ".html")

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
}
