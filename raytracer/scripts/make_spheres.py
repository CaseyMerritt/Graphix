import random

header = """
{
   "scene": { "type": "union",
              "children": [
              {"type": "plane",
                "center": {"x": 0, "y": 200, "z": 0},
                "normal": {"y": -1, "z": 2},
                "material": {"ka": 0.3, "kd": 0.6, "ks": 0, "reflectiveness": 0.5, "color": {"color": 255}}},
"""

sphere = """{"type": "sphere",
 "radius": $radius,
 "center": {"x": $x, "y": $y, "z": $z},
 "material": {"ka": $ka, "kd": $kd, "ks": $ks, "alpha": $alpha, "reflectiveness": $refl, "color": {"r": $r, "g": $g, "b": $b}}}
"""

footer = """]
            },
   "reflections": 3,
   "lighting": {"type": "phong", "ambient": {"color": 128}, "shadows": true,
                "lights": [{"position": {"x": -50, "y": 400, "z": 1000}, "color": {"r": 255, "g": 0, "b": 0}},
                           {"position": {"x": 80, "y": -100, "z": 30}, "color": {"r": 0, "g": 255, "b": 255}}
                          ]}
}"""

spheres = []
for i in range(25):
    
    rad = random.randint(5,25)
    y = random.randint(rad+35, 600)
    x = random.randint(-y, y)
    z = y/2 + rad - 100
    ka = (random.random()*0.5)
    kd = "%.2f"%(random.random()*0.5*(0.5-ka))
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