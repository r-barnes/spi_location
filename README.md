Finding the Southern Pole of Inaccessibility
============================================

This repository contains the source code needed to reproducibly locate
the Southern Pole of Inaccessibility (SPI).

The **data** directory contains the
[Antarctic Digital Database (ADD)](https://www.add.scar.org/)
v5 and v7.2 data files as well as a list of previously identified locations
for the SPI.

Our goal is to use this data to identify the "true" location of the SPI.



Installation
------------

To proceed we need some software.

[GDAL](https://gdal.org/) must be installed for reprojecting and reading
shapefiles.

Snakemake is used to enable reproducable and scalable workflows. Install it
with:
```
pip3 install snakemake
```

Next, compile the code with
```
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo ../submodules/Barnes2019-DggBestOrientations/
make -j 6 poi.exe
cd ..
```



User Settings
-----------------------

The **Snakefile** is already configured to provide turn-key identification of
the SPI. The settings can be adjusted by referring to the documentation in
**Snakefile** and to the command-line interface of **build/poi.exe**.



Running It
-----------------------

To find the poles, type
```
snakemake -j MAX_NUMBER_OF_CORES_TO_USE
```



Data Sources
-----------------------

The ADDv7.2 data is available at:

 * https://data.bas.ac.uk/metadata.php?id=GB/NERC/BAS/PDC/01398
 * https://ramadda.data.bas.ac.uk/repository/entry/show?entryid=b046fd0d-11ce-48a0-8e49-44694a4b889d

The ADDv5 data was provided by [Laura Gerrish](lauger@bas.ac.uk).

Feature categories in ADDv7.2 are largely self-explanatory. Feature categories
for ADDv5 were inferred from http://apdrc.soest.hawaii.edu/doc/gebco_manual.pdf
and are as follows:

 * 22010 for ice coastline (definite)
 * 22011 for rock coastline (definite)
 * 22012 for grounding line (definite)
 * 22013 for rock against ice shelf (definite)
 * 22020 for ice coastline (approximate)
 * 22021 for rock coastline (approximate)
 * 22022 for grounding line (approximate)
 * 22023 for rock against ice shelf (approximate)
 * 22030 for iceberg tongue
 * 22040 for floating glacier tongue
 * 22050 for ice shelf front
 * 22090 for ice rumples (distinct)
 * 22100 for ice rumples (indistinct)



Methodology
---------------------------

The methodology used was previously described in detail in @Barnes2019. Some
slight modifications were made for this work so we review the algorithm.

1. Coastline features are read from a shapefile.
2. The coastline features are interpolated so that no two coastline vertices
   are more than 500m from each other. Note that this preserves
   the exact geometry of the coastline, the interpolated points do not affect
   the shape of the coast and are a convenience used later.
3. The vertices comprising the coastline and projected into a 3D space based on
   a very accurate WGS84 projection and indexed with a k-d tree to accelerate
   distance queries.
4. A series of initial points is generated by wrapping a spiral around a
   spherical model of the globe. The interpoint spacing is ~50km.
5. Points north of -66.5 degrees are rejected.
6. Points within 500km of the Antarctic coast are rejected; this value is based
   on SPI distances found in previous studies with a ~200km margin of safety
   added.
7. The distances of the remaining points to the coast are calculated. The 10%
   of points farthest from the coast are retained for further consideration.
8. All the previously reported positions of the SPI are added to the list of
   points. This ensures that the algorithm can do no worse than a previously
   reported position.
9. Each of the remaining points is used as the seed location for a random
   restart hillclimbing algorithm which moves the point farther and farther
   from the coast until it fails to find an improvement a certain number of
   times.
10. The points now represent an estimate of the SPI. The point farthest from the
    coast is the best estimate.
11. The circle of inaccessibility is calculated by asking for the nearest
    coastal point to each SPI and then returning all points within a 30km
    annulus whose inner boundary is at that distance. The three innermost
    points represent the circle of inaccessibility.
12. All the points are sorted by distance and written to CSV.



Remarks
---------------------------------------

Note that the algorithm above has several useful properties.

1. It uses the full high-resolution data available to it. No simplifications
   are made.
2. Random restart hillclimbing from many initial points avoids the problem of
   identifying only local maxima and therefore provides a robust approach to
   finding the true location of the SPI.
3. Calculations are performed using ellipsoidal models, unlike some previous
   studies.

The SPI locations are as follows:
```
Coastline     Longitude      Latitude        Distance from Coast
ADDv5 Inner   55.0877304200  -82.9557084809  1242.7569109758
ADDv5 Outer   65.6671478591  -83.9340046532  1588.5717760481
ADDv72 Inner  53.7204104397  -83.6098203200  1179.4002101212
ADDv72 Outer  64.8899669821  -83.9040073174  1590.3640236480
```



Why previous values are incorrect
----------------------------------------

@Barnes2019 uses a variant of the above algorithm to calculate the location of
the SPI, but obtains a value significantly different from ours. This is because
the @Barnes2019 calculation relies on the GSHHG dataset which divides Antarctica
in half into two polygons. This line of division is then interpolated (per the
algorithm) resulting in an inaccurate SPI location. Because the data we use here
does not have this anomaly the algorithm returns correct results in our case.



Bibliography
---------------------------

@Barnes2019:
Richard Barnes.
Optimal orientations of discrete global grids and the Poles of Inaccessibility.
10.1080/17538947.2019.1576786