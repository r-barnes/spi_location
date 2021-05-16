from typing import Tuple

import numpy as np
from numpy.core.numeric import isclose
import pandas as pd

def is_close(x: float, y: float) -> bool:
  close_func = lambda x, y: np.isclose(x, y, atol=0, rtol=1e-2)
  # Account for wrap-around
  close = False
  close |= close_func(x,     y)
  close |= close_func(x+180, y)
  close |= close_func(x,     y+180)
  return close



def pair_close(a: Tuple[float, float], b: Tuple[float, float]) -> bool:
  return is_close(a[0], b[0]) and is_close(a[1], b[1])



def format_coast_name(df: pd.DataFrame) -> None:
  """addv2_outer_wgs84 -> ADDv2 Outer"""
  df["Coastline"] = df["Coastline"].str.replace("_wgs84", "")
  df["Coastline"] = df["Coastline"].str.replace("_", " ")
  df["Coastline"] = df["Coastline"].str.replace("add", "ADD")
  df["Coastline"] = df["Coastline"].str.replace("outer", "Outer")
  df["Coastline"] = df["Coastline"].str.replace("Inner", "Inner")



results = []
for input_file in snakemake.input:
  poles_file = input_file
  circles_file = input_file.replace("-poles_of_inaccessibility.csv", "-circles_of_inaccessibility.csv")
  poles = pd.read_csv(poles_file)
  circles = pd.read_csv(circles_file)
  # We know the pole is closer to the coast than this, so we use it to filter
  # antipodes
  poles = poles[poles["Distance"]<2000]
  poles = poles.sort_values(by="Distance", ascending=False)
  best_pole = poles.iloc[0]
  # Get circles of inaccessibility for the best pole
  circles = circles[circles["poi_num"]==best_pole["poi_num"]]
  circles = circles.sort_values(by="distance", ascending=True)
  circle_pts = []
  for _, row in circles.iterrows():
    for circle_pt in circle_pts:
      if pair_close((row["X"], row["Y"]), (circle_pt["X"], circle_pt["Y"])):
        break
    else:
      circle_pts.append(row)
      # print("BOB", circle_pts)

  results.append((best_pole, circle_pts))

best_poles = pd.DataFrame(data={
  "Coastline": [x[0]["data"] for x in results],
  "Longitude": [x[0]["PoleX"] for x in results],
  "Latitude": [x[0]["PoleY"] for x in results],
  "Distance": [x[0]["Distance"] for x in results]
})

best_circles = pd.DataFrame(data={
  "Coastline": [x["data"] for r in results for x in r[1]],
  "Longitude": [x["X"] for r in results for x in r[1]],
  "Latitude": [x["Y"] for r in results for x in r[1]],
  "Distance": [x["distance"] for r in results for x in r[1]]
})

format_coast_name(best_poles)
format_coast_name(best_circles)

fout = open("out/SUMMARY", "w")
fout.write("Poles of Inaccessibility\n")
fout.write("========================\n")
fout.write(best_poles.to_string(index=False))
fout.write("\n\n\n")
fout.write("Circles of Inaccessibility\n")
fout.write("==========================\n")
fout.write(best_circles.to_string(index=False))
fout.write("\n")
