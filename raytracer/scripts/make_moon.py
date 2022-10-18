import random
import math

header = """
{
   "scene": { "type": "difference",
              "a": {"type": "sphere",
                "center": {"x": 0, "y": 200, "z": 0},
                "radius": 125,
                "material": {"ka": 0.4, "kd": 0.7, "ks": 0, "reflectiveness": 0, "color": {"color": 255}}},
              "b": {"type": "union",
                    "children": [
"""
# "reflectiveness": $refl, 
sphere = """{"type": "sphere",
 "radius": $radius,
 "center": {"x": $x, "y": $y, "z": $z},
 "material": {"ka": $ka, "kd": $kd, "ks": $ks, "alpha": $alpha, "color": {"r": $r, "g": $g, "b": $b}}}
"""

footer = """]
            }},
   "reflections": 0,
   "lighting": {"type": "phong", "ambient": {"color": 128}, "shadows": true,
                "lights": [{"position": {"x": 400, "y": -400, "z": 300}, "color": {"color": 196}},
                          ]}
}"""

spheres = []
for i in range(25):
    phi = random.random()*1.4 - 0.7 #random.random()*4 - 2
    theta = random.random()*1.2 - 0.6 -3.14/2
    rad = random.randint(3,12)
    x = "%.2f"%(125*math.cos(phi)*math.cos(theta) + (random.random()-0.5)*0.25*rad)
    y = "%.2f"%(200 + 125*math.cos(phi)*math.sin(theta) + random.random()*0.25*rad)
    z = "%.2f"%(-125*math.sin(phi) - random.random()*0.25*rad)
    ka = (random.random()*0.3)
    kd = "%.2f"%(random.random()*0.5*(0.5-ka)+0.2)
    ka = "%.2f"%ka
    ks = "%.2f"%(random.random()*0.5)
    alpha = random.random()*15
    if alpha > 1: alpha = round(alpha)
    else: alpha = "%.2f"%(alpha)
    r = random.randint(0,255)
    g = random.randint(0,255)
    b = random.randint(0,255)
    if r+g+b < 100:
       r += 100
       g += random.randint(0,100)
       b += random.randint(0,100)
    refl = "0"
    if random.randint(0,5) < 3:
       refl = "%.1f"%(random.random()*0.8)
    result = sphere 
    for k,v in [("radius", rad), ("x", x), ("y", y), ("z", z), ("ka", ka), ("kd", kd), ("ks", ks), ("alpha", alpha), ("refl", refl), ("r", r), ("g", g), ("b", b)]:
        result = result.replace("$"+k, str(v))
    spheres.append(result)
    
print(header + ",\n".join(spheres) + footer)