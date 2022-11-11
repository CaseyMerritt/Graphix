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
      
      //multiply ambient with material property ka
      color am = multColor(ambient, hit.material.properties.ka);
      
      color diffuse = color(0,0,0);
      color specular = color(0,0,0);
      
      for(int i = 0; i < lights.size(); i++){
        //calculate to light vectors
        PVector tolight = PVector.sub(lights.get(i).position, hit.location).normalize();// vector that points to the light from hit
        PVector fromlight = PVector.sub(hit.location, lights.get(i).position).normalize();// vector that points from light to hit
        
        //calculate viewer
        PVector toCamera = PVector.sub(hit.location, viewer).normalize();
        
        //calculate Rm vector
        PVector Rm = PVector.mult(hit.normal, 2).mult(hit.normal.dot(fromlight)).sub(fromlight).normalize();
        
        //get impact location
        PVector impact = new PVector(hit.location.x + EPS, hit.location.y + EPS, hit.location.z + EPS);
        
        //shoot ray to check for object blocking light
        Ray shadowCast = new Ray(impact, tolight);
        ArrayList<RayHit> hits = sc.root.intersect(shadowCast);
        
        /*
          if no objects are blocking the light we calculate the color otherwise we ignore the light
        */
        if(hits.size() == 0){
          //color id = lights.get(i).shine(hitcolor);
          color id = lights.get(i).diffuse;
          id = multColor(id, hit.material.properties.kd * hit.normal.dot(tolight));
          diffuse = addColors(diffuse, id);
      
          //color is = lights.get(i).spec(hitcolor);
          color is = lights.get(i).specular;
          is = multColor(is, hit.material.properties.ks * pow(Rm.dot(toCamera), hit.material.properties.alpha));
          specular = addColors(specular, is); 
        }
      }
      
      //add the final values together return that color and scale with surface col
      color i = scaleColor(addColors(addColors(am, diffuse), specular), hitcolor);
      
      return i;//return that bitch
    }
  
}
