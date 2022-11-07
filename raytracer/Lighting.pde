class Light
{
   PVector position;
   color diffuse;
   color specular;
   Light(PVector position, color col)
   {
     this.position = position;
     this.diffuse = col;
     this.specular = col;
   }
   
   Light(PVector position, color diffuse, color specular)
   {
     this.position = position;
     this.diffuse = diffuse;
     this.specular = specular;
   }
   
   color shine(color col)
   {
       return scaleColor(col, this.diffuse);
   }
   
   color spec(color col)
   {
       return scaleColor(col, this.specular);
   }
}

class LightingModel
{
    ArrayList<Light> lights;
    LightingModel(ArrayList<Light> lights)
    {
      this.lights = lights;
    }
    color getColor(RayHit hit, Scene sc, PVector viewer)
    {
      color hitcolor = hit.material.getColor(hit.u, hit.v);
      color surfacecol = lights.get(0).shine(hitcolor);
      PVector tolight = PVector.sub(lights.get(0).position, hit.location).normalize();
      float intensity = PVector.dot(tolight, hit.normal);
      return lerpColor(color(0), surfacecol, intensity);
    }
  
}

class PhongLightingModel extends LightingModel
{
    color ambient;
    boolean withshadow;
    PhongLightingModel(ArrayList<Light> lights, boolean withshadow, color ambient)
    {
      super(lights);
      this.withshadow = withshadow;
      this.ambient = ambient;
      
      // remove this line when you implement phong lighting
      //throw new NotImplementedException("Phong Lighting Model not implemented yet");
    }
    color getColor(RayHit hit, Scene sc, PVector viewer)
    {
      color hitcolor = hit.material.getColor(hit.u, hit.v);
      color am = scaleColor(hitcolor, ambient);
      am = multColor(am, hit.material.properties.ka);
      
      color diffuse = color(0,0,0);
      color specular = color(0,0,0);
      
      for(int i = 0; i < lights.size(); i++){
        PVector tolight = PVector.sub(lights.get(0).position, hit.location).normalize();// vector that points to the light
        //PVector Rm = hit.normal.mult(2).mult(hit.normal.dot(tolight)).sub(tolight).normalize();
        PVector Rm = PVector.mult(hit.normal, 2).mult(PVector.dot(hit.normal, tolight)).sub(tolight).normalize();
      
        color id = lights.get(i).shine(hitcolor);
        id = multColor(id, hit.material.properties.kd * tolight.dot(hit.normal));
        diffuse = addColors(id, diffuse);
      
        color is = lights.get(i).spec(hitcolor);
        is = multColor(is, hit.material.properties.ks * pow(Rm.dot(viewer), hit.material.properties.alpha));
        specular = addColors(is, specular);
      }
      
      color i = addColors(addColors(am, diffuse), specular);
      
      return i;
    }
  
}
