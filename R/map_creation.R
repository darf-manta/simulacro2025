rutas_filter = filter(rutas, parroquia == target_parroquia)

zonas_filter = filter(zonas, parroquia == target_parroquia)

puntos_filter = filter(puntos, parroquia == target_parroquia)

participantes_filter = filter(participantes, parroquia == target_parroquia)

#https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}

target_map = leaflet(options = leafletOptions(minZoom = 14, maxZoom = 19)) |>
   setView(parroquias_center[1,target_parroquia],
           parroquias_center[2,target_parroquia], 17) |>
   setMaxBounds(-80.93, -1.14, -80.66, -0.92) |>
   addLayersControl(options = layersControlOptions(collapsed = FALSE),
                    baseGroups = c("Imagen satelital", "Mapa base"),
                    overlayGroups = c("Área de Inundación por Tsunami", "Rutas de Evacuación",
                    "Puntos de Encuentro", "Zonas Seguras", "Instituciones y Comunidades Participantes")) |>
   onRender("function(el, x){ L.control.locate().addTo(this); }") |>
   addTiles('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
            options = tileOptions(maxZoom = 19), group = "Mapa base",
            attribution = paste('&copy; <a href="https://www.openstreetmap.org">OpenStreetMap</a>',
                                'data &amp &copy; <a href="https://carto.com">CARTO</a> tiles')) |>
   addTiles('https://mt{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}&hl=es',
            options = tileOptions(maxZoom = 19, subdomains = "0123"), group = "Image satelital",
            attribution = paste('&copy; <a href="https://www.google.com/maps">Google Maps</a> tiles')) |>
   addPolygons(data = tsunami, fillColor = "red", weight = 0, options = paths,
               group = "Área de Inundación por Tsunami") |>
   addPolylines(data = rutas_filter, color = "red", weight = 9, opacity = 0.9, options = paths,
                group = "Rutas de Evacuación") |>
   addPolylines(data = rutas_filter, color = "yellow", weight = 7, opacity = 0.9, popupOptions = popups,
                group = "Rutas de Evacuación",
                highlightOptions = highlightOptions(opacity = 1),
                popup = ~if_else(nom_punto != "sin punto de encuentro",
                                 paste("dirigirse al Punto de Encuentro:<b>", nom_punto, "</b"),
                                 paste("dirigirse a la Zona Segura:<b>", nom_zona, "</b"))) |>
   addMarkers(data = zonas_filter, icon = zonas_icon, popupOptions = popups,
              group = "Zonas Seguras",
              popup = ~paste("Zona Segura<b>:", nom_zona, "</b><br>AQUÍ FINALIZA LA EVACUACIÓN")) |>
   addMarkers(data = puntos_filter, icon = puntos_icon, popupOptions = popups,
              group = "Puntos de Encuentro",
              popup = ~paste("Punto de Encuentro:<b>", nom_punto, "</b><br>",
                             if_else(nom_zona == "sin zona segura", "AQUÍ FINALIZA LA EVACUACIÓN",
                                     paste("dirigirse a la Zona Segura<b>:", nom_zona, "</b>")))) |>
   addCircleMarkers(data = participantes_filter, fillColor = "skyblue", fillOpacity = 1, radius = 20,
                    stroke = FALSE, options = markerOptions(interactive = FALSE),
                    group = "Instituciones y Comunidades Participantes") |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Comité Comunitario de GdR"),
              popupOptions = popups, icon = icon_cg, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b><br>",
                             if_else(is.na(nom_zona), " ",
                                     paste("dirigirse a la Zona Segura<b>:", nom_zona, "</b>")))) |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Comunidad"),
              popupOptions = popups, icon = icon_cb, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b><br>",
                             if_else(is.na(nom_zona), " ",
                                     paste("dirigirse a la Zona Segura<b>:", nom_zona, "</b>")))) |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Departamento Municipal"),
              popupOptions = popups, icon = icon_dp, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b><br>",
                             if_else(is.na(nom_zona), " ",
                                     paste("dirigirse a la Zona Segura<b>:", nom_zona, "</b>")))) |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Empresa Privada"),
              popupOptions = popups, icon = icon_er, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b><br>",
                             if_else(is.na(nom_zona), " ",
                                     paste("dirigirse a la Zona Segura<b>:", nom_zona, "</b>")))) |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Empresa Pública"),
              popupOptions = popups, icon = icon_ep, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b><br>",
                             if_else(is.na(nom_zona), " ",
                                     paste("dirigirse a la Zona Segura<b>:", nom_zona, "</b>")))) |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Institución Educativa"),
              popupOptions = popups, icon = icon_ie, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b><br>",
                             if_else(is.na(nom_zona), " ",
                                     paste("dirigirse a la Zona Segura<b>:", nom_zona, "</b>"))))

saveWidget(target_map, file.path("tmp", target_html), selfcontained = FALSE, libdir = "libs",
           title = paste("Mapa de rutas de evacuación ante Tsnami – Parroquia", target_parroquia))
