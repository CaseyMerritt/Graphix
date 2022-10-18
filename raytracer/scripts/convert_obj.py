# requires pywavefront
# pip install pywavefront
import pywavefront 
import json

texture = "chair02.png"
fname = "chair02.obj"
outfile = "chair.json"

xoffset = 0
yoffset = 300
zoffset = -70


header = """
{
   "scene": {"type": "union",
               "children": [
"""

footer = """
  ]}
}
"""

scene = pywavefront.Wavefront(fname)
verts = scene.materials["default0"].vertices

# verts contains *all* triangle vertex information consecutively:
# 8 entries per vertex:
# [u v normal.x normal.y normal.z x y z]
# 3 vertices per triangle * 8 entries = 24 floats per triangle

triangles = []
for i in range(len(verts)//24):
    tex = []
    coord = []
    for vert in range(3):
        base = i*24 + vert*8    
        u = verts[base]
        v = verts[base+1]
        x = verts[base + 5]
        y = verts[base + 6]
        z = verts[base + 7]
        tex.append((u,v))
        coord.append((x+xoffset,y+yoffset,z+zoffset))
    result = """{"type": "triangle",
                 $coords,
                 $tex,
                 "material": {"type": "textured", "texture": "%s"}
                }"""%(texture)
    coordstrings = []
    for i,c in enumerate(coord):
        coordstrings.append('"v%d":'%(i+1) + ' {"x": %f, "y": %f, "z": %f}'%c)
    texstrings = []
    for i,t in enumerate(tex):
        texstrings.append('"tex%d":'%(i+1) + ' {"u": %f, "v": %f}'%t)
    result = result.replace("$coords", ",\n".join(coordstrings))
    result = result.replace("$tex", ",\n".join(texstrings))
    triangles.append(result)

content = json.loads(header + ",\n".join(triangles) + footer)

f = open(outfile, "w")
json.dump(content, f, indent=4)
f.close()

    