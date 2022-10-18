import math

scene = """{
   "scene": {   
             "type": "union",
             "children": [
               {"type": "sphere",
                "radius": 130,
                "center": {"x": 30, "y": 350, "z": 0},
                "material": {"ka": 0.2, "kd": 0.4, "ks": 0.7, "alpha": 100, "reflectiveness": 0.1, "color": {"r": 255}}},
                {"type": "sphere",
                "radius": 110,
                "center": {"x": -195, "y": 425, "z": 30},
                "material": {"ka": 0.2, "kd": 0.4, "ks": 0.7, "alpha": 100, "reflectiveness": 0.1, "color": {"b": 255}}},
               { "type": "intersection",
               
                 "children": [{"type": "sphere",
                               "radius": 100,
                               "center": {"x": -35, "y": 160, "z": 15},
                               "material": {"ka": 0.2, "kd": 0.8, "ks": 0, "alpha": 100, "color": {"color": 255}, "transparency": 0.8, "refractionIndex": 1.33}},
                              {"type": "sphere",
                               "radius": 100,
                               "center": {"x": -30, "y": 5, "z": 10},
                               "material": {"ka": 0.2, "kd": 0.8, "ks": 0, "alpha": 100, "color": {"color": 255}, "transparency": 0.8, "refractionIndex": 1.33}}]} 
                ]},
   "reflections": 1,
   "camera": {"x": $x, "y": $y},
   "view": {"x": $vx, "y": $vy},
   "lighting": {"type": "phong", "ambient": {"color": 128},
                "lights": [{"position": {"x": 500, "y": -700, "z": -60}, "color": {"color": 255}}]}
}
"""

for i in range(250):
    f = open("scene%03d.json"%(i), "w")
    angle = i*1.8/250 + 3.9
    dx = 450*math.cos(angle)
    dy = 450*math.sin(angle)
    x = dx 
    y = 300 + dy 
    vx = -dx 
    vy = -dy 
    text = scene 
    for (k,v) in [("x", x), ("y", y), ("vx", vx), ("vy", vy)]:
        text = text.replace("$" + k, "%d"%(int(round(v))))
    f.write(text)
    f.close()
    