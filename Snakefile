# Maximum distance (km) between shoreline points. Edges longer than this are
# interpolated.
INTERP_DIST = 0.5

# Maximum distance (km) between initial points for hillclimbing
SPACING = 50

# Shapefile SQL queries. These are the features used from each shapefile to
# identify the relevant coastlines for a calculation.
addv72_inner_lines = ["rock coastline", "rock against ice shelf", "ice coastline", "grounding line"]
addv72_outer_lines = ["ice coastline", "ice shelf and front", "rock coastline"]
addv5_inner_lines = ["WE JUST USE EVERYTHING, SO THIS IS IGNORED"]
addv5_outer_lines = [
    "22010", # ice coastline (definite)
    "22011", # rock coastline (definite)
    "22020", # ice coastline (approximate)
    "22021", # rock coastline (approximate)
    "22050", # ice shelf front
]



# Query generation (do not edit)
addv72_inner_lines = " OR ".join([f"surface='{x}'" for x in addv72_inner_lines])
addv72_outer_lines = " OR ".join([f"surface='{x}'" for x in addv72_outer_lines])
addv5_outer_lines = " OR ".join([f"CST00TYP='{x}'" for x in addv5_outer_lines])



rule all:
    input: ["out/poi-addv72_inner_wgs84-ellipsoidal-circles_of_inaccessibility.csv", "out/poi-addv72_outer_wgs84-ellipsoidal-circles_of_inaccessibility.csv", "out/poi-addv5_inner_wgs84-ellipsoidal-circles_of_inaccessibility.csv", "out/poi-addv5_outer_wgs84-ellipsoidal-circles_of_inaccessibility.csv"]

rule unzip_addv5:
    input: "data/addv5.zip"
    output: "data/addv5/add5_coastline.shp"
    shell:
        """
        cd data
        unzip addv5.zip
        """

rule unzip_addv72:
    input: "data/addv72-lines.zip"
    output: "data/addv72-lines/add_coastline_high_res_line_v7.2.shp"
    shell:
        """
        cd data
        unzip addv72-lines.zip
        """

rule addv5_inner_wgs84:
    input: "data/addv5/add5_coastline.shp"
    output: "temp/addv5_inner_wgs84.shp"
    shell:
        """
        mkdir -p temp/
        ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -f "ESRI Shapefile" temp/addv5_inner_wgs84.shp data/addv5/add5_coastline.shp
        """

rule addv5_outer_wgs84:
    input: "data/addv5/add5_coastline.shp"
    output: "temp/addv5_outer_wgs84.shp"
    shell:
        """
        mkdir -p temp/
        ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -where "{addv5_outer_lines}" -f "ESRI Shapefile" temp/addv5_outer_wgs84.shp data/addv5/add5_coastline.shp
        """

rule addv72_inner_wgs84:
    input: "data/addv72-lines/add_coastline_high_res_line_v7.2.shp"
    output: "temp/addv72_inner_wgs84.shp"
    shell:
        """
        mkdir -p temp/
        ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -where "{addv72_inner_lines}" -f "ESRI Shapefile" temp/addv72_inner_wgs84.shp data/addv72-lines/add_coastline_high_res_line_v7.2.shp
        """

rule addv72_outer_wgs84:
    input: "data/addv72-lines/add_coastline_high_res_line_v7.2.shp"
    output: "temp/addv72_outer_wgs84.shp"
    shell:
        """
        mkdir -p temp/
        ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -where "{addv72_outer_lines}" -f "ESRI Shapefile" temp/addv72_outer_wgs84.shp data/addv72-lines/add_coastline_high_res_line_v7.2.shp
        """

rule find_spi_for_addv72_outer_wgs84:
    input: ["temp/addv72_outer_wgs84.shp", "build/poi.exe", "data/previous_poles.csv"]
    output: "out/poi-addv72_outer_wgs84-ellipsoidal-circles_of_inaccessibility.csv"
    threads: workflow.cores
    shell:
        """
        mkdir -p out/
        ./build/poi.exe --previous_poles data/previous_poles.csv --coastname addv72_outer_wgs84 --shapefile temp/addv72_outer_wgs84.shp --layer addv72_outer_wgs84 --projection ellipsoidal --spacing {SPACING} --interp_dist {INTERP_DIST} --south_of -66.5 --distance_filter 500 --likely_frac 0.1 -o out/poi-addv72_outer_wgs84-ellipsoidal
        """

rule find_spi_for_addv72_inner_wgs84:
    input: ["temp/addv72_inner_wgs84.shp", "build/poi.exe", "data/previous_poles.csv"]
    output: "out/poi-addv72_inner_wgs84-ellipsoidal-circles_of_inaccessibility.csv"
    threads: workflow.cores
    shell:
        """
        mkdir -p out/
        ./build/poi.exe --previous_poles data/previous_poles.csv --coastname addv72_inner_wgs84 --shapefile temp/addv72_inner_wgs84.shp --layer addv72_inner_wgs84 --projection ellipsoidal --spacing {SPACING} --interp_dist {INTERP_DIST} --south_of -66.5 --distance_filter 500 --likely_frac 0.1 -o out/poi-addv72_inner_wgs84-ellipsoidal
        """

rule find_spi_for_addv5_inner_wgs84:
    input: ["temp/addv5_inner_wgs84.shp", "build/poi.exe", "data/previous_poles.csv"]
    output: "out/poi-addv5_inner_wgs84-ellipsoidal-circles_of_inaccessibility.csv"
    threads: workflow.cores
    shell:
        """
        mkdir -p out/
        ./build/poi.exe --previous_poles data/previous_poles.csv --coastname addv5_inner_wgs84 --shapefile temp/addv5_inner_wgs84.shp --layer addv5_inner_wgs84 --projection ellipsoidal --spacing {SPACING} --interp_dist {INTERP_DIST} --south_of -66.5 --distance_filter 500 --likely_frac 0.1 -o out/poi-addv5_inner_wgs84-ellipsoidal
        """

rule find_spi_for_addv5_outer_wgs84:
    input: ["temp/addv5_outer_wgs84.shp", "build/poi.exe", "data/previous_poles.csv"]
    output: "out/poi-addv5_outer_wgs84-ellipsoidal-circles_of_inaccessibility.csv"
    threads: workflow.cores
    shell:
        """
        mkdir -p out/
        ./build/poi.exe --previous_poles data/previous_poles.csv --coastname addv5_outer_wgs84 --shapefile temp/addv5_outer_wgs84.shp --layer addv5_outer_wgs84 --projection ellipsoidal --spacing {SPACING} --interp_dist {INTERP_DIST} --south_of -66.5 --distance_filter 500 --likely_frac 0.1 -o out/poi-addv5_outer_wgs84-ellipsoidal
        """
