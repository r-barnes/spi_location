from pathlib import Path

# Maximum distance (km) between shoreline points. Edges longer than this are
# interpolated.
INTERP_DIST = 0.5

# Maximum distance (km) between initial points for hillclimbing
SPACING = 50

# Shapefile SQL queries. These are the features used from each shapefile to
# identify the relevant coastlines for a calculation.
addv1_thru_5_inner_lines = ["WE JUST USE EVERYTHING, SO THIS IS IGNORED"]
addv1_thru_5_outer_lines = [
    "22010", # ice coastline (definite)
    "22011", # rock coastline (definite)
    "22020", # ice coastline (approximate)
    "22021", # rock coastline (approximate)
    "22050", # ice shelf front
]
addv7_2_thru_7_4_inner_lines = ["rock coastline", "rock against ice shelf", "ice coastline", "grounding line"]
addv7_2_thru_7_4_outer_lines = ["ice coastline", "ice shelf and front", "rock coastline"]
addv74_inner_lines = ["rock coastline", "rock against ice shelf", "ice coastline", "grounding line"]
addv74_outer_lines = ["ice coastline", "ice shelf and front", "rock coastline"]

# Query generation (do not edit)
addv1_thru_5_outer_lines = " OR ".join([f"CST00TYP='{x}'" for x in addv1_thru_5_outer_lines])
addv74_inner_lines = " OR ".join([f"surface='{x}'" for x in addv74_inner_lines])
addv74_outer_lines = " OR ".join([f"surface='{x}'" for x in addv74_outer_lines])
addv7_2_thru_7_4_inner_lines = " OR ".join([f"surface='{x}'" for x in addv7_2_thru_7_4_inner_lines])
addv7_2_thru_7_4_outer_lines = " OR ".join([f"surface='{x}'" for x in addv7_2_thru_7_4_outer_lines])



rule all:
    input:
        "out/SUMMARY"

rule unzip_addv1_4:
    input: "data/addv1-4.zip"
    output:
        "data/addv1-4/scale0_coast_line_addv1.shp",
        "data/addv1-4/scale0_coast_line_addv2.shp",
        "data/addv1-4/scale0_coast_line_addv3.shp",
        "data/addv1-4/scale0_coast_line_addv4.shp"
    shell:
        """
        cd data
        mkdir -p addv1-4/
        cd addv1-4
        unzip ../addv1-4.zip
        """

rule unzip_addv5:
    input: "data/addv5.zip"
    output: "data/addv5/add5_coastline.shp"
    shell:
        """
        cd data
        mkdir -p addv5/
        cd addv5
        unzip ../addv5.zip
        """

rule unzip_addv72:
    input: "data/addv72-lines.zip"
    output: "data/addv72-lines/add_coastline_high_res_line_v7.2.shp"
    shell:
        """
        cd data
        mkdir -p addv72-lines/
        cd addv72-lines
        unzip ../addv72-lines.zip
        """

rule unzip_addv74:
    input: "data/addv74-lines.zip"
    output: "data/addv74-lines/add_coastline_high_res_line_v7_4.shp"
    shell:
        """
        cd data
        mkdir -p addv74-lines/
        cd addv74-lines
        unzip ../addv74-lines.zip
        """

rule addv1_5_inner_wgs84:
    input:
        "data/addv1-4/scale0_coast_line_addv1.shp",
        "data/addv1-4/scale0_coast_line_addv2.shp",
        "data/addv1-4/scale0_coast_line_addv3.shp",
        "data/addv1-4/scale0_coast_line_addv4.shp",
        "data/addv5/add5_coastline.shp"
    output:
        "temp/addv1_inner_wgs84.shp",
        "temp/addv2_inner_wgs84.shp",
        "temp/addv3_inner_wgs84.shp",
        "temp/addv4_inner_wgs84.shp",
        "temp/addv5_inner_wgs84.shp"
    run:
        shell("mkdir -p temp/")
        for input_file, output_file in zip(input, output):
            shell("""ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -f "ESRI Shapefile" {output_file} {input_file}""")

rule addv1_5_outer_wgs84:
    input:
        "data/addv1-4/scale0_coast_line_addv1.shp",
        "data/addv1-4/scale0_coast_line_addv2.shp",
        "data/addv1-4/scale0_coast_line_addv3.shp",
        "data/addv1-4/scale0_coast_line_addv4.shp",
        "data/addv5/add5_coastline.shp"
    output:
        "temp/addv1_outer_wgs84.shp",
        "temp/addv2_outer_wgs84.shp",
        "temp/addv3_outer_wgs84.shp",
        "temp/addv4_outer_wgs84.shp",
        "temp/addv5_outer_wgs84.shp"
    run:
        shell("mkdir -p temp/")
        for input_file, output_file in zip(input, output):
            shell("""ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -where "{addv1_thru_5_outer_lines}" -f "ESRI Shapefile" {output_file} {input_file}""")

rule addv7_inner_wgs84:
    input:
        "data/addv72-lines/add_coastline_high_res_line_v7.2.shp",
        "data/addv74-lines/add_coastline_high_res_line_v7_4.shp"
    output:
        "temp/addv7.2_inner_wgs84.shp",
        "temp/addv7.4_inner_wgs84.shp"
    run:
        shell("mkdir -p temp/")
        for input_file, output_file in zip(input, output):
            shell("""ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -where "{addv7_2_thru_7_4_inner_lines}" -f "ESRI Shapefile" {output_file} {input_file}""")

rule addv7_outer_wgs84:
    input:
        "data/addv72-lines/add_coastline_high_res_line_v7.2.shp",
        "data/addv74-lines/add_coastline_high_res_line_v7_4.shp"
    output:
        "temp/addv7.2_outer_wgs84.shp",
        "temp/addv7.4_outer_wgs84.shp"
    run:
        shell("mkdir -p temp/")
        for input_file, output_file in zip(input, output):
            shell("""ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -where "{addv7_2_thru_7_4_outer_lines}" -f "ESRI Shapefile" {output_file} {input_file}""")

rule find_spi:
    input: "temp/{coastline}.shp"
    output: "out/poi-{coastline}-ellipsoidal-circles_of_inaccessibility.csv"
    threads: workflow.cores
    run:
        shell("mkdir -p out/")
        shell("./build/poi.exe --previous_poles data/previous_poles.csv --coastname {wildcards.coastline} --shapefile {input} --layer {wildcards.coastline} --projection ellipsoidal --spacing {SPACING} --interp_dist {INTERP_DIST} --south_of -66.5 --distance_filter 500 --likely_frac 0.1 -o out/poi-{wildcards.coastline}-ellipsoidal")

rule find_best:
    input:
        "out/poi-addv1_inner_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv2_inner_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv3_inner_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv4_inner_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv5_inner_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv7.2_inner_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv7.4_inner_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv1_outer_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv2_outer_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv3_outer_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv4_outer_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv5_outer_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv7.2_outer_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
        "out/poi-addv7.4_outer_wgs84-ellipsoidal-poles_of_inaccessibility.csv",
    output:
        "out/SUMMARY"
    script:
        "scripts/find_best_poles.py"










# rule find_spi_for_addv74_outer_wgs84:
#     input: ["temp/addv74_outer_wgs84.shp", "build/poi.exe", "data/previous_poles.csv"]
#     output: "out/poi-addv74_outer_wgs84-ellipsoidal-circles_of_inaccessibility.csv"
#     threads: workflow.cores
#     shell:
#         """
#         mkdir -p out/
#         ./build/poi.exe --previous_poles data/previous_poles.csv --coastname addv74_outer_wgs84 --shapefile temp/addv74_outer_wgs84.shp --layer addv74_outer_wgs84 --projection ellipsoidal --spacing {SPACING} --interp_dist {INTERP_DIST} --south_of -66.5 --distance_filter 500 --likely_frac 0.1 -o out/poi-addv74_outer_wgs84-ellipsoidal
#         """

# rule find_spi_for_addv74_inner_wgs84:
#     input: ["temp/addv74_inner_wgs84.shp", "build/poi.exe", "data/previous_poles.csv"]
#     output: "out/poi-addv74_inner_wgs84-ellipsoidal-circles_of_inaccessibility.csv"
#     threads: workflow.cores
#     shell:
#         """
#         mkdir -p out/
#         ./build/poi.exe --previous_poles data/previous_poles.csv --coastname addv74_inner_wgs84 --shapefile temp/addv74_inner_wgs84.shp --layer addv74_inner_wgs84 --projection ellipsoidal --spacing {SPACING} --interp_dist {INTERP_DIST} --south_of -66.5 --distance_filter 500 --likely_frac 0.1 -o out/poi-addv74_inner_wgs84-ellipsoidal
#         """

# rule find_spi_for_addv72_outer_wgs84:
#     input: ["temp/addv72_outer_wgs84.shp", "build/poi.exe", "data/previous_poles.csv"]
#     output: "out/poi-addv72_outer_wgs84-ellipsoidal-circles_of_inaccessibility.csv"
#     threads: workflow.cores
#     shell:
#         """
#         mkdir -p out/
#         ./build/poi.exe --previous_poles data/previous_poles.csv --coastname addv72_outer_wgs84 --shapefile temp/addv72_outer_wgs84.shp --layer addv72_outer_wgs84 --projection ellipsoidal --spacing {SPACING} --interp_dist {INTERP_DIST} --south_of -66.5 --distance_filter 500 --likely_frac 0.1 -o out/poi-addv72_outer_wgs84-ellipsoidal
#         """

# rule find_spi_for_addv72_inner_wgs84:
#     input: ["temp/addv72_inner_wgs84.shp", "build/poi.exe", "data/previous_poles.csv"]
#     output: "out/poi-addv72_inner_wgs84-ellipsoidal-circles_of_inaccessibility.csv"
#     threads: workflow.cores
#     shell:
#         """
#         mkdir -p out/
#         ./build/poi.exe --previous_poles data/previous_poles.csv --coastname addv72_inner_wgs84 --shapefile temp/addv72_inner_wgs84.shp --layer addv72_inner_wgs84 --projection ellipsoidal --spacing {SPACING} --interp_dist {INTERP_DIST} --south_of -66.5 --distance_filter 500 --likely_frac 0.1 -o out/poi-addv72_inner_wgs84-ellipsoidal
#         """

# rule find_spi_for_addv5_inner_wgs84:
#     input: ["temp/addv5_inner_wgs84.shp", "build/poi.exe", "data/previous_poles.csv"]
#     output: "out/poi-addv5_inner_wgs84-ellipsoidal-circles_of_inaccessibility.csv"
#     threads: workflow.cores
#     shell:
#         """
#         mkdir -p out/
#         ./build/poi.exe --previous_poles data/previous_poles.csv --coastname addv5_inner_wgs84 --shapefile temp/addv5_inner_wgs84.shp --layer addv5_inner_wgs84 --projection ellipsoidal --spacing {SPACING} --interp_dist {INTERP_DIST} --south_of -66.5 --distance_filter 500 --likely_frac 0.1 -o out/poi-addv5_inner_wgs84-ellipsoidal
#         """

# rule find_spi_for_addv5_outer_wgs84:
#     input: ["temp/addv5_outer_wgs84.shp", "build/poi.exe", "data/previous_poles.csv"]
#     output: "out/poi-addv5_outer_wgs84-ellipsoidal-circles_of_inaccessibility.csv"
#     threads: workflow.cores
#     shell:
#         """
#         mkdir -p out/
#         ./build/poi.exe --previous_poles data/previous_poles.csv --coastname addv5_outer_wgs84 --shapefile temp/addv5_outer_wgs84.shp --layer addv5_outer_wgs84 --projection ellipsoidal --spacing {SPACING} --interp_dist {INTERP_DIST} --south_of -66.5 --distance_filter 500 --likely_frac 0.1 -o out/poi-addv5_outer_wgs84-ellipsoidal
#         """

















# rule addv5_inner_wgs84:
#     input: "data/addv5/add5_coastline.shp"
#     output: "temp/addv5_inner_wgs84.shp"
#     shell:
#         """
#         mkdir -p temp/
#         ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -f "ESRI Shapefile" temp/addv5_inner_wgs84.shp data/addv5/add5_coastline.shp
#         """

# rule addv5_outer_wgs84:
#     input: "data/addv5/add5_coastline.shp"
#     output: "temp/addv5_outer_wgs84.shp"
#     shell:
#         """
#         mkdir -p temp/
#         ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -where "{addv1_thru_5_outer_lines}" -f "ESRI Shapefile" temp/addv5_outer_wgs84.shp data/addv5/add5_coastline.shp
#         """





# rule addv72_inner_wgs84:
#     input: "data/addv72-lines/add_coastline_high_res_line_v7.2.shp"
#     output: "temp/addv72_inner_wgs84.shp"
#     shell:
#         """
#         mkdir -p temp/
#         ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -where "{addv7_2_thru_7_4_inner_lines}" -f "ESRI Shapefile" temp/addv72_inner_wgs84.shp data/addv72-lines/add_coastline_high_res_line_v7.2.shp
#         """

# rule addv72_outer_wgs84:
#     input: "data/addv72-lines/add_coastline_high_res_line_v7.2.shp"
#     output: "temp/addv72_outer_wgs84.shp"
#     shell:
#         """
#         mkdir -p temp/
#         ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -where "{addv7_2_thru_7_4_outer_lines}" -f "ESRI Shapefile" temp/addv72_outer_wgs84.shp data/addv72-lines/add_coastline_high_res_line_v7.2.shp
#         """

# rule addv74_inner_wgs84:
#     input: "data/addv74-lines/add_coastline_high_res_line_v7_4.shp"
#     output: "temp/addv74_inner_wgs84.shp"
#     shell:
#         """
#         mkdir -p temp/
#         ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -where "{addv74_inner_lines}" -f "ESRI Shapefile" temp/addv74_inner_wgs84.shp data/addv74-lines/add_coastline_high_res_line_v7_4.shp
#         """

# rule addv74_outer_wgs84:
#     input: "data/addv74-lines/add_coastline_high_res_line_v7_4.shp"
#     output: "temp/addv74_outer_wgs84.shp"
#     shell:
#         """
#         mkdir -p temp/
#         ogr2ogr -progress -t_srs '+proj=longlat +datum=WGS84 +no_defs' -where "{addv74_outer_lines}" -f "ESRI Shapefile" temp/addv74_outer_wgs84.shp data/addv74-lines/add_coastline_high_res_line_v7_4.shp
#         """
