require 'cairo'

settings = require('settings')
assert(os.setlocale(settings.system.locale))

------------------------------------------------------------------------------------------

function get_weather_data(json_field)
	return conky_parse(
		"${exec curl -s '" .. settings.weather.api_url ..
			"?q=" .. settings.weather.city .. "," .. settings.weather.language_code .. 
			"&lang=" .. settings.weather.lang .. 
			"&units=" .. settings.weather.units .. 
			"&appid=" .. settings.weather.api_key .. 
		"' | jq -r " .. json_field .. "}"
	)
end

function image(cr, pos_x, pos_y, transparency, image_path)
	cairo_set_operator(cr, CAIRO_OPERATOR_OVER)
	local image = cairo_image_surface_create_from_png (image_path)
	local w_img = cairo_image_surface_get_width (image)
	local h_img = cairo_image_surface_get_height (image)

	cairo_save(cr)
	cairo_set_source_surface (cr, image, pos_x-w_img/2, pos_y-h_img/2)
	cairo_paint_with_alpha (cr, transparency)
	cairo_surface_destroy (image)
	cairo_restore(cr)
end

function text(cr, pos_x, pos_y, transparency, text, font_face, font_size, font_weight)
	cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE)
	cairo_set_source_rgba(cr, r_text, g_text, b_text, transparency)
	ct = cairo_text_extents_t:create()
	cairo_select_font_face(cr, font_face, CAIRO_FONT_SLANT_NORMAL, font_weight)
	cairo_set_font_size(cr, font_size)
	cairo_text_extents(cr,text,ct)
	cairo_move_to(cr,pos_x,pos_y)
	cairo_show_text(cr,text)
	cairo_close_path(cr)
end

function draw_elements(cr)
	------------------------------------------------------------------------------------------
	-- CLOCK section
	------------------------------------------------------------------------------------------

	-- Date / year
	year = conky_parse("${exec date '+%Y.'}")
	text(cr, 20, 30, settings.appearance.transparency_full, year, settings.appearance.default_font_face, 20, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Date / month text + day number
	date = conky_parse("${exec date '+| %B %d. | %A'}")
	--date = "| Wednesday | December 31."
	text(cr, 70, 30, settings.appearance.transparency_half, date, settings.appearance.default_font_face, 20, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Hour
	hour = conky_parse("${exec date '+%H'}")
	text(cr, 10, 155, settings.appearance.transparency_full, hour, settings.appearance.default_font_face, 145, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Minutes
	minutes = conky_parse("${exec date '+:%M'}")
	text(cr, 170, 155, settings.appearance.transparency_half, minutes, settings.appearance.default_font_face, 145, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Seconds
	seconds = ": " .. conky_parse("${exec date '+%S'}")
	text(cr, 370, 155, settings.appearance.transparency_full, seconds, settings.appearance.default_font_face, 20, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- HDD
	hdd = "HDD"
	text(cr, 20, 180, settings.appearance.transparency_full, hdd, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	hdd = conky_parse("${fs_free} / ${fs_size}")
	text(cr, 60, 180, settings.appearance.transparency_half, hdd, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	------------------------------------------------------------------------------------------

	-- RAM
	ram = "RAM"
	text(cr, 200, 180, settings.appearance.transparency_full, ram, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	ram = conky_parse("${mem} / ${memmax}")
	text(cr, 240, 180, settings.appearance.transparency_half, ram, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	------------------------------------------------------------------------------------------

	-- CPU
	cpu = "CPU"
	text(cr, 200, 200, settings.appearance.transparency_full, cpu, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	cpu = conky_parse("${cpu cpu0}%")
	text(cr, 240, 200, settings.appearance.transparency_half, cpu, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL) 

	------------------------------------------------------------------------------------------

	-- Vertical line
	image(cr, 415, 130, settings.appearance.transparency_full, "./images/line.png")

	------------------------------------------------------------------------------------------
	-- WEATHER section
	------------------------------------------------------------------------------------------

	-- Weather icon
	image_path = "./images/" .. get_weather_data(".weather[].icon") .. ".png"
	image(cr, 470, 45, settings.appearance.transparency_weather_icon, image_path)

	------------------------------------------------------------------------------------------

	-- City
	image(cr, 440, 100, settings.appearance.transparency_half, "./images/map-marker.png")
	text(cr, 455, 110, settings.appearance.transparency_half, settings.weather.city, "Noto Sans", 30, CAIRO_FONT_WEIGHT_THIN)

	------------------------------------------------------------------------------------------

	-- Temperature -> Current
	image(cr, 440, 140, settings.appearance.transparency_half, "./images/temperature.png")

	temperature = get_weather_data(".main.temp")
	temperature = string.format("%.0f", temperature) .. "˚C"

	text(cr, 460, 155, settings.appearance.transparency_full, temperature, settings.appearance.default_font_face, 40, CAIRO_FONT_WEIGHT_BOLD) 

	------------------------------------------------------------------------------------------

	-- Temperature -> Details
	image(cr, 435, 175, settings.appearance.transparency_half, "./images/arrow-right.png")

	details = get_weather_data(".weather[].description")
	text(cr, 445, 180, settings.appearance.transparency_half, details, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Temperature -> MIN
	image(cr, 435, 195, settings.appearance.transparency_half, "./images/arrow-down.png")

	temp_min = get_weather_data(".main.temp_min")
	temp_min = string.format("%.0f", temp_min) .. "˚C"

	text(cr, 445, 200, settings.appearance.transparency_full, temp_min, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Temperature -> MAX
	image(cr, 495, 195, settings.appearance.transparency_half, "./images/arrow-up.png")

	temp_max = get_weather_data(".main.temp_max")
	temp_max = string.format("%.0f", temp_max) .. "˚C"

	text(cr, 505, 200, settings.appearance.transparency_full, temp_max, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL)

	------------------------------------------------------------------------------------------

	-- Temperature -> Feels like
	image(cr, 555, 195, settings.appearance.transparency_half, "./images/white-man.png")

	feels_like = get_weather_data(".main.feels_like")
	feels_like = string.format("%.0f", feels_like) .. "˚C"

	text(cr, 565, 200, settings.appearance.transparency_full, feels_like, settings.appearance.default_font_face, 15, CAIRO_FONT_WEIGHT_NORMAL)
end

function hex2rgb(hex)
	hex = hex:gsub("#","")
	return (tonumber("0x"..hex:sub(1,2))/255), 
		(tonumber("0x"..hex:sub(3,4))/255), 
		tonumber(("0x"..hex:sub(5,6))/255)
end

function conky_start_widgets()
	if settings.weather.api_key == nil then
		print("[ ERROR ] The 'OPENWEATHER_API_KEY' environment variable must be exported!")
		os.exit(1)
	end

	if conky_window == nil then return end

	r_text, g_text, b_text = hex2rgb(settings.appearance.html_text_color)

	local cs = cairo_xlib_surface_create(
		conky_window.display,
		conky_window.drawable,
		conky_window.visual, 
		conky_window.width,
		conky_window.height
	)

	local cr = cairo_create(cs)

	draw_elements(cr)

	cairo_surface_destroy(cs)
	cairo_destroy(cr)
end