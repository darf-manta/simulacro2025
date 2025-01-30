rutas_filter = if(target_canton) rutas else filter(rutas, parroquia == target_parroquia)

zonas_filter = if(target_canton) zonas else filter(zonas, parroquia == target_parroquia)

puntos_filter = if(target_canton) puntos else filter(puntos, parroquia == target_parroquia)

participantes_filter = if(target_canton) participantes else filter(participantes, parroquia==target_parroquia)

target_map = leaflet(options = leafletOptions(minZoom = 14, maxZoom = 19)) |>
   setView(parroquias_center[1,target_parroquia],
           parroquias_center[2,target_parroquia], if_else(target_canton, 16, 17)) |>
   setMaxBounds(-80.93, -1.14, -80.66, -0.92) |>
   addLayersControl(options = layersControlOptions(collapsed = FALSE),
                    baseGroups = c("Imagen satelital", "Mapa base"),
                    overlayGroups = c("Área de Inundación por Tsunami", "Rutas de Evacuación",
                    "Puntos de Encuentro y Zonas Seguras", "Instituciones y Comunidades Participantes")) |>
   onRender(if_else(! target_canton, "function(el, x){ L.control.locate().addTo(this); }",
                    "function(el, x){ var lcl = L.control.locate().addTo(this); lcl.start(); }")) |>
   addTiles('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', group = "Mapa base",
            options = tileOptions(maxZoom = 19),
            attribution = paste('&copy; <a href="https://www.openstreetmap.org">OpenStreetMap</a>',
                                'data &amp &copy; <a href="https://carto.com">CARTO</a> tiles')) |>
   addTiles('https://mt{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}&hl=es', group = "Image satelital",
            options = tileOptions(maxZoom = 19, subdomains = "0123", opacity = 0.75),
            attribution = paste('&copy; <a href="https://www.google.com/maps">Google Maps</a> tiles')) |>
   addPolygons(data = tsunami, fillColor = "red", weight = 0, options = paths,
               group = "Área de Inundación por Tsunami") |>
   addPolylines(data = rutas_filter, color = "red", weight = 9, opacity = 0.9, options = paths,
                group = "Rutas de Evacuación") |>
   addPolylines(data = rutas_filter, color = "yellow", weight = 7, opacity = 0.9, popupOptions = popups,
                group = "Rutas de Evacuación",
                highlightOptions = highlightOptions(opacity = 1),
                popup = ~if_else(nom_punto != "sin punto de encuentro",
                                 paste("Dirigirse al Punto de Encuentro:<br><b>", nom_punto, "</b"),
                                 paste("Dirigirse a la Zona Segura:<br><b>", nom_zona, "</b"))) |>
   addMarkers(data = zonas_filter, icon = zonas_icon, popupOptions = popups,
              # label = ~lapply(nom_zona, break_label), labelOptions = labelOptions(
              #    textsize = "14px", direction = "bottom", permanent = TRUE, offset = c(0, 40),
              #    style = list("font-weight"="bold", "inline-size"="100px", "word-break"="break-all")),
              group = "Puntos de Encuentro y Zonas Seguras",
              popup = ~paste("Zona Segura:<br><b>", nom_zona,
                             "</b><br>Número de personas que evacuarán aquí:", n_participantes)) |>
   addMarkers(data = puntos_filter, icon = puntos_icon, popupOptions = popups,
              group = "Puntos de Encuentro y Zonas Seguras",
              popup = ~paste("Punto de Encuentro:<br><b>", nom_punto, "</b>",
                             if_else(nom_zona == "sin zona segura", " ",
                                     paste("<br>Dirigirse a la Zona Segura:<br><b>", nom_zona, "</b>")))) |>
   addCircleMarkers(data = participantes_filter, fillColor = "skyblue", fillOpacity = 1, radius = 20,
                    stroke = FALSE, options = markerOptions(interactive = FALSE),
                    group = "Instituciones y Comunidades Participantes") |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Comunidad"),
              popupOptions = popups, icon = icon_cb, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b>", if_else(is.na(n_participantes), " ", if_else(
                 n_participantes == 0,
                 "<br>Solo evacuación interna",
                 paste("<br>Evacuación externa:<br><b>", n_participantes, "personas</b><br>Dirigirse",
                       if_else(grepl("P.E.", nom_zona), "al Punto de Encuentro:", "a la Zona Segura:"),
                       "<br><b>", nom_zona, "</b>")
              )))) |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Comité Comunitario de GdR"),
              popupOptions = popups, icon = icon_cg, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b>", if_else(is.na(n_participantes), " ", if_else(
                 n_participantes == 0,
                 "<br>Solo evacuación interna",
                 paste("<br>Evacuación externa:<br><b>", n_participantes, "personas</b><br>Dirigirse",
                       if_else(grepl("P.E.", nom_zona), "al Punto de Encuentro:", "a la Zona Segura:"),
                       "<br><b>", nom_zona, "</b>")
              )))) |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Departamento Municipal"),
              popupOptions = popups, icon = icon_dp, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b>", if_else(is.na(n_participantes), " ", if_else(
                 n_participantes == 0,
                 "<br>Solo evacuación interna",
                 paste("<br>Evacuación externa:<br><b>", n_participantes, "personas</b><br>Dirigirse",
                       if_else(grepl("P.E.", nom_zona), "al Punto de Encuentro:", "a la Zona Segura:"),
                       "<br><b>", nom_zona, "</b>")
              )))) |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Empresa Privada"),
              popupOptions = popups, icon = icon_er, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b>", if_else(is.na(n_participantes), " ", if_else(
                 n_participantes == 0,
                 "<br>Solo evacuación interna",
                 paste("<br>Evacuación externa:<br><b>", n_participantes, "personas</b><br>Dirigirse",
                       if_else(grepl("P.E.", nom_zona), "al Punto de Encuentro:", "a la Zona Segura:"),
                       "<br><b>", nom_zona, "</b>")
              )))) |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Empresa Pública"),
              popupOptions = popups, icon = icon_ep, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b>", if_else(is.na(n_participantes), " ", if_else(
                 n_participantes == 0,
                 "<br>Solo evacuación interna",
                 paste("<br>Evacuación externa:<br><b>", n_participantes, "personas</b><br>Dirigirse",
                       if_else(grepl("P.E.", nom_zona), "al Punto de Encuentro:", "a la Zona Segura:"),
                       "<br><b>", nom_zona, "</b>")
              )))) |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Institución Educativa"),
              popupOptions = popups, icon = icon_ie, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b>", if_else(is.na(n_participantes), " ", if_else(
                 n_participantes == 0,
                 "<br>Solo evacuación interna",
                 paste("<br>Evacuación externa:<br><b>", n_participantes, "personas</b><br>Dirigirse",
                       if_else(grepl("P.E.", nom_zona), "al Punto de Encuentro:", "a la Zona Segura:"),
                       "<br><b>", nom_zona, "</b>")
              )))) |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Hotel"),
              popupOptions = popups, icon = icon_ho, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b>", if_else(is.na(n_participantes), " ", if_else(
                 nom_zona == "evacuación interna",
                 "<br>Solo evacuación interna",
                 paste("<br>Dirigirse",
                       if_else(grepl("P.E.", nom_zona), "al Punto de Encuentro:", "a la Zona Segura:"),
                       "<br><b>", nom_zona, "</b>")
              )))) |>
   addMarkers(data = filter(participantes_filter, tipo_part == "Comité de Operaciones de Emergencia"),
              popupOptions = popups, icon = icon_oe, group = "Instituciones y Comunidades Participantes",
              popup = ~paste("<b>", nom_part, "</b>"))

saveWidget(
   target_map, file.path("tmp", target_html), selfcontained = FALSE, libdir = "libs",
   title = if_else(target_canton, "Mapa de rutas de evacuación – Simulacro 2025 – Cantón Manta",
                   paste("Mapa de rutas de evacuación – Simulacro 2025 – Parroquia", target_parroquia))
)
