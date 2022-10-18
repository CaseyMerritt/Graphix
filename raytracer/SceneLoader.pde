/// You do not have to modify this file at all (unless you really want to add new primitive types or operators)

Scene loadScene(String path)
{
  Scene result = new Scene();
  JSONObject obj = loadJSONObject(path);
  
  result.root = makeSceneObject(obj.getJSONObject("scene"));
  result.lighting = makeLightingModel(obj.getJSONObject("lighting")); 
  result.reflections = obj.getInt("reflections", 0);
  result.background = makeColor(obj.getJSONObject("background"), color(128));
  result.camera = makeVector(obj.getJSONObject("camera"), new PVector(0,0,0));
  result.view = makeVector(obj.getJSONObject("view"), new PVector(0,1,0)).normalize();
  result.fov = radians(obj.getFloat("fov", 90));
  return result;
}

LightingModel makeLightingModel(JSONObject obj)
{
  ArrayList<Light> lights = new ArrayList<Light>();
  if (obj == null)
  {
    lights.add(new Light(new PVector(-3, -2, -5), color(128)));
    return new LightingModel(lights);
  }
  String type = obj.getString("type", "basic");
  JSONArray jsonlights = obj.getJSONArray("lights");
  
  if (jsonlights == null)
  {
    lights.add(new Light(new PVector(-3, -2, -5), color(128)));
  }
  else
  {
    for(int i = 0; i < jsonlights.size(); ++i)
    {
      lights.add(makeLight(jsonlights.getJSONObject(i)));
    }
  }
  if (type.equals("basic"))
  {
     if (lights.size() > 1)
     {
        print("WARNING: Basic lighting model will ignore any lights beyond the first!\n");
     }
     return new LightingModel(lights);
  }
  else
  {
     color ambient = makeColor(obj.getJSONObject("ambient"), color(128));
     return new PhongLightingModel(lights, obj.getBoolean("shadows", false), ambient);
  }
}

Light makeLight(JSONObject obj)
{
  JSONObject specular = obj.getJSONObject("specular");
  JSONObject diffuse = obj.getJSONObject("diffuse");
  if (diffuse == null)
  {
      diffuse = obj.getJSONObject("color");
  }
  if (specular == null)
  {
      return new Light(makeVector(obj.getJSONObject("position"), new PVector(-3, -2, -5)), makeColor(diffuse, color(128)));
  }
  else
  {
      return new Light(makeVector(obj.getJSONObject("position"), new PVector(-3, -2, -5)), makeColor(diffuse, color(128)), makeColor(specular));
  }
}

SceneObject makeSceneObject(JSONObject obj)
{
   if (obj == null)
   {
       return new Sphere(new PVector(0,5,0), 1, makeMaterial(null));
   }
   String type = obj.getString("type", "sphere").toLowerCase();
   if (type.equals("sphere"))
   {
     return new Sphere(makeVector(obj.getJSONObject("center"), new PVector(0,0,0)), obj.getFloat("radius", 1), makeMaterial(obj.getJSONObject("material")));
   }
   else if (type.equals("plane"))
   {
     return new Plane(makeVector(obj.getJSONObject("center"), new PVector(0,0,0)), makeVector(obj.getJSONObject("normal"), new PVector(0,0,1)), makeMaterial(obj.getJSONObject("material")), obj.getFloat("scale", 1));
   }
   else if (type.equals("triangle"))
   {
     return new Triangle(makeVector(obj.getJSONObject("v1"), new PVector(0,0,0)), makeVector(obj.getJSONObject("v2"), new PVector(100,0,0)), makeVector(obj.getJSONObject("v3"), new PVector(100,100,0)), 
                         makeVector2(obj.getJSONObject("tex1"), new PVector(1,0)), makeVector2(obj.getJSONObject("tex2"), new PVector(0,1)), makeVector2(obj.getJSONObject("tex3"), new PVector(0,0)),
                         makeMaterial(obj.getJSONObject("material")));
   }
   else if (type.equals("cylinder"))
   {
     return new Cylinder(obj.getFloat("radius", 1), obj.getFloat("height", -1), makeMaterial(obj.getJSONObject("material")), obj.getFloat("scale", 1));
   }
   else if (type.equals("cone"))
   {
     return new Cone(makeMaterial(obj.getJSONObject("material")), obj.getFloat("scale", 1));
   }
   else if (type.equals("paraboloid"))
   {
     return new Paraboloid(makeMaterial(obj.getJSONObject("material")), obj.getFloat("scale", 1));
   }
   else if (type.equals("hyperboloidone"))
   {
     return new HyperboloidOneSheet(makeMaterial(obj.getJSONObject("material")), obj.getFloat("scale", 1));
   }
   else if (type.equals("hyperboloidtwo"))
   {
     return new HyperboloidTwoSheet(makeMaterial(obj.getJSONObject("material")), obj.getFloat("scale", 1));
   }
   else if (type.equals("moverotation"))
   {
     return new MoveRotation(makeSceneObject(obj.getJSONObject("child")), makeVector(obj.getJSONObject("movement"), new PVector(0,0,0)), toRadians(makeVector(obj.getJSONObject("rotation"), new PVector(0,0,0))));
   }
   else if (type.equals("scaling"))
   {
     return new Scaling(makeSceneObject(obj.getJSONObject("child")), makeVector1(obj.getJSONObject("scaling"), new PVector(1,1,1)));
   }
   else if (type.equals("difference"))
   {
     return new Difference(makeSceneObject(obj.getJSONObject("a")), makeSceneObject(obj.getJSONObject("b")));
   }
   else 
   {
     JSONArray childobjs = obj.getJSONArray("children");
     SceneObject[] children = new SceneObject[childobjs.size()];
     for (int i = 0; i < childobjs.size(); ++i)
     {
       children[i] = makeSceneObject(childobjs.getJSONObject(i));
     }
     if (type.equals("union"))
     {
         return new Union(children);
     }
     else
     {
         return new Intersection(children);
     }
   }
   
}

Material makeMaterial(JSONObject obj)
{
    if (obj == null) return new Material(new MaterialProperties(0.5, 0.3, 0.2, 3, 0, 0, 1), color(255,0,0));
    String type = obj.getString("type", "default");
    MaterialProperties props = new MaterialProperties(obj.getFloat("ka", 0.5),
                                                     obj.getFloat("ks", 0.3),
                                                     obj.getFloat("kd", 0.2),
                                                     obj.getFloat("alpha", 3),
                                                     obj.getFloat("reflectiveness", 0),
                                                     obj.getFloat("transparency", 0),
                                                     obj.getFloat("refractionIndex", 1));
    if (type.equals("default"))
    {
       return new Material(props,
                           makeColor(obj.getJSONObject("color"), color(255,0,0)));
    }
    else if (type.equals("textured"))
    {
       return new TexturedMaterial(props,
                           loadImage(obj.getString("texture", "default.png")));
    }
    else
    {
       if (doAutoloop)
          loop();
       return ProceduralMaterialRegistry.getMaterial(obj.getString("name", "lava"), props);
    }
}

color makeColor(JSONObject obj, color def)
{
  if (obj == null) return def;
  return makeColor(obj);
}

color makeColor(JSONObject obj)
{
    if (obj.getString("gray", "default").equals("default") && obj.getString("color", "default").equals("default"))
    {
       return color(obj.getInt("red", obj.getInt("r", 0)), obj.getInt("green", obj.getInt("g", 0)), obj.getInt("blue", obj.getInt("b", 0)));
    }
    return color(obj.getInt("gray", obj.getInt("color", 128)));
}

PVector makeVector(JSONObject obj, PVector def)
{
  if (obj == null) return def;
  return makeVector(obj);
}

PVector makeVector(JSONObject obj)
{
    return new PVector(obj.getFloat("x", 0), obj.getFloat("y", 0), obj.getFloat("z", 0));
}

PVector makeVector1(JSONObject obj, PVector def)
{
  if (obj == null) return def;
  return makeVector1(obj);
}

PVector makeVector1(JSONObject obj)
{
    return new PVector(obj.getFloat("x", 1), obj.getFloat("y", 1), obj.getFloat("z", 1));
}

PVector makeVector2(JSONObject obj, PVector def)
{
  if (obj == null) return def;
  return makeVector2(obj);
}

PVector makeVector2(JSONObject obj)
{
    return new PVector(obj.getFloat("u", 0), obj.getFloat("v", 0));
}

PVector toRadians(PVector angles)
{
  return new PVector(radians(angles.x), radians(angles.y), radians(angles.z));
}
