rutas_filter = filter(rutas, parroquia == target_parroquia)

zonas_filter = filter(zonas, parroquia == target_parroquia)

puntos_filter = filter(puntos, parroquia == target_parroquia)

target_map = leaflet(options = leafletOptions(minZoom = 14, maxZoom = 19)) |>
   setView(parroquias_center[1,target_parroquia],
           parroquias_center[2,target_parroquia], 17) |>
   setMaxBounds(-80.93, -1.14, -80.66, -0.92) |>
   addLayersControl(options = layersControlOptions(collapsed = FALSE),
                    overlayGroups = c("Área de Inundación por Tsunami", "Rutas de Evacuación",
                                      "Puntos de Encuentro", "Zonas Seguras")) |>
   onRender("function(el, x){ L.control.locate().addTo(this); }") |>
   addTiles('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
            options = tileOptions(maxZoom = 19),
            attribution = paste('&copy; <a href="https://www.openstreetmap.org">OpenStreetMap</a>',
                                'data &amp &copy; <a href="https://carto.com">CARTO</a> tiles')) |>
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
                                     paste("dirigirse a la Zona Segura<b>:", nom_zona, "</b>"))))

saveWidget(target_map, file.path("tmp", target_html), selfcontained = FALSE, libdir = "libs",
           title = paste("Mapa de rutas de evacuación ante Tsnami – Parroquia", target_parroquia))
