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
      //get surface color
      color hitcolor = hit.material.getColor(hit.u, hit.v);
      
      //scale surface color with ambient
      color am = scaleColor(hitcolor, ambient);
      
      //multiply ambient with material property ka
      am = multColor(am, hit.material.properties.ka);
      
      color diffuse = color(0,0,0);
      color specular = color(0,0,0);
      
      for(int i = 0; i < lights.size(); i++){
        //calculate to light vector
        PVector tolight = PVector.sub(lights.get(i).position, hit.location).normalize();// vector that points to the light
        
        //calculate Rm vector
        PVector Rm = PVector.mult(hit.normal, 2).mult(hit.normal.dot(tolight)).sub(tolight).normalize();
        
        //get impact location
        PVector impact = new PVector(hit.location.x + EPS, hit.location.y + EPS);
        
        //shoot ray to check for object blocking light
        Ray shadowCast = new Ray(impact, tolight);
        ArrayList<RayHit> hits = sc.root.intersect(shadowCast);
        
        /*
          if no objects are blocking the light we calculate the color otherwise we ignore the light
        */
        if(hits.size() == 0){
          color id = lights.get(i).shine(hitcolor);
          id = multColor(id, hit.material.properties.kd * tolight.dot(hit.normal));
          diffuse = addColors(diffuse, id);
      
          color is = lights.get(i).spec(hitcolor);
          is = multColor(is, hit.material.properties.ks * pow(Rm.dot(viewer), hit.material.properties.alpha));
          specular = addColors(specular, is); 
        }
      }
      
      //add the final values together return that color
      color i = addColors(addColors(am, diffuse), specular);
      
      return i;
    }
  
}
