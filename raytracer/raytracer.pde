String input =  "data/tests/milestone4/test14.json";
String output = "data/tests/milestone4/test14.png";
int repeat = 0;

int iteration = 0;

// If there is a procedural material in the scene,
// loop will automatically be turned on if this variable is set
boolean doAutoloop = true;

/*// Animation demo:
String input = "data/tests/milestone3/animation1/scene%03d.json";
String output = "data/tests/milestone3/animation1/frame%03d.png";
int repeat = 100;
*/


RayTracer rt;

void setup() {
  size(640, 640);
  noLoop();
  if (repeat == 0)
      rt = new RayTracer(loadScene(input));  
  
}

void draw () {
  background(255);
  if (repeat == 0)
  {
    PImage out = null;
    if (!output.equals(""))
    {
       out = createImage(width, height, RGB);
       out.loadPixels();
    }
    for (int i=0; i < width; i++)
    {
      for(int j=0; j< height; ++j)
      {
        color c = rt.getColor(i,j);
        set(i,j,c);
        if (out != null)
           out.pixels[j*width + i] = c;
      }
    }
    
    // This may be useful for debugging:
    // only draw a 3x3 grid of pixels, starting at (315,315)
    // comment out the full loop above, and use this
    // to find issues in a particular region of an image, if necessary
    /*for (int i = 0; i< 3; ++i)
    {
      for (int j = 0; j< 3; ++j)
         set(315+i,315+j, rt.getColor(315+i,315+j));
    }*/
    
    if (out != null)
    {
       out.updatePixels();
       out.save(output);
    }
    
  }
  else
  {
     // With this you can create an animation!
     // For a demo, try:
     //    input = "data/tests/milestone3/animation1/scene%03d.json"
     //    output = "data/tests/milestone3/animation1/frame%03d.png"
     //    repeat = 100
     // This will insert 0, 1, 2, ... into the input and output file names
     // You can then turn the frames into an actual video file with e.g. ffmpeg:
     //    ffmpeg -i frame%03d.png -vcodec libx264 -pix_fmt yuv420p animation.mp4
     String inputi;
     String outputi;
     for (; iteration < repeat; ++iteration)
     {
        inputi = String.format(input, iteration);
        outputi = String.format(output, iteration);
        if (rt == null)
        {
            rt = new RayTracer(loadScene(inputi));
        }
        else
        {
            rt.setScene(loadScene(inputi));
        }
        PImage out = createImage(width, height, RGB);
        out.loadPixels();
        for (int i=0; i < width; i++)
        {
          for(int j=0; j< height; ++j)
          {
            color c = rt.getColor(i,j);
            out.pixels[j*width + i] = c;
            if (iteration == repeat - 1)
               set(i,j,c);
          }
        }
        out.updatePixels();
        out.save(outputi);
     }
  }
  updatePixels();


}

class Ray
{
     Ray(PVector origin, PVector direction)
     {
        this.origin = origin;
        this.direction = direction;
     }
     PVector origin;
     PVector direction;
}

// TODO: Start in this class!
class RayTracer
{
    Scene scene;  
    
    RayTracer(Scene scene)
    {
      setScene(scene);
    }
    
    void setScene(Scene scene)
    {
       this.scene = scene;
    }
    
    color getColor(int x, int y)
    {
      PVector origin = scene.camera;
      PVector direction;
      
      float w = width;
      float h = height;
      
      
      float u = x*1.0/w - 0.5;
      float v = -(y*1.0/h - 0.5);
      direction = new PVector(u*w,w/2,v*h).normalize();
      
      Ray ray = new Ray(origin, direction);
      ArrayList<RayHit> hits = scene.root.intersect(ray);
      
      if(hits.size()>0){
        
        RayHit hit = hits.get(0);
        
        /*
          Only calculate relfections if scene calls for it
        */
        if (scene.reflections > 0){
          
          //send first hit and ray used to get that hit to the calculator
          color col = color(0,0,0);
          col = calculateReflections(scene, hit, ray, ray.origin, col, 0);
          return col;
          
        /*
          Only use lighting model if no reflections are set
        */
        }else{
          
          return scene.lighting.getColor(hit, scene, ray.origin);
          
        }
      }
      
      return this.scene.background;
    }
    
    color calculateReflections(Scene scene, RayHit h, Ray r, PVector viewer, color a ,int i){
      
      RayHit hit = h;
      Ray ray = r;
      color accumulator = a;
      
      if(i < scene.reflections){
        
        color surfaceCol = scene.lighting.getColor(hit, scene, ray.origin);
        
        /*
          Non reflective surface, add surface color to accumulator and then return accumulator
        */
        if(hit.material.properties.reflectiveness == 0){
          
          return surfaceCol;
          
        /*
          Perfect reflective surface, calculate reflection vector and then get reflection color 
          add that color
        */
        }else if(hit.material.properties.reflectiveness == 1){
          
          //calculate reflection vector
          PVector V = PVector.sub(ray.direction, hit.location).normalize();//
          PVector Rm = PVector.mult(hit.normal, 2).mult(PVector.dot(hit.normal, V)).add(ray.direction).normalize();
          
          //get impact location
          PVector impact = hit.location;
          impact = PVector.add(impact, PVector.mult(Rm, EPS));
          
          //create new ray with impact location and reflection vector
          ray = new Ray(impact, Rm);
          
          //calculate new hits
          ArrayList<RayHit> hits = scene.root.intersect(ray);
          
          /*
            check if there are hits, if so calculate the reflection color
          */
          if(hits.size() > 0){
            //set new hit
            hit = hits.get(0);
            
            //get reflection color
            i++;
            color reflectionCol = calculateReflections(scene, hit, ray, viewer, accumulator, i); // calculate reflection color
            
            return reflectionCol;
          
          /*
            if no more hits but reflection max hasn't been hit add background color
            i.e: reflected off surface into the sky
          */
          }else if(hits.size() == 0){
            
            return scene.background;
            
          }
          
        /*
          Non perfect reflective surface, calculate relfection vector and reflection color, add the 
          lerp between surface color and reflection color (with some factor for internsity)
        */
        }else{
          
          //calculate reflection vector
          PVector V = PVector.sub(ray.direction, hit.location).normalize();//
          PVector Rm = PVector.mult(hit.normal, 2).mult(PVector.dot(hit.normal, V)).add(ray.direction).normalize();
          
          //get impact location
          //PVector impact = new PVector(hit.location.x + EPS, hit.location.y + EPS, hit.location.z + EPS);
          PVector impact = hit.location;
          impact = PVector.add(impact, PVector.mult(Rm, EPS));
          
          //create new ray with impact location and reflection vector
          ray = new Ray(impact, Rm);
          
          //calculate new hits
          ArrayList<RayHit> hits = scene.root.intersect(ray);
          
          //save old hit reflectiveness for later calculation
          float reflectiveness = hit.material.properties.reflectiveness;
          
          /*
            check if there are hits, if so calculate the reflection color
          */
          if(hits.size() > 0){
            //set new hit
            hit = hits.get(0);
            
            //get reflection color
            i++;
            color reflectionCol = calculateReflections(scene, hit, ray, viewer, accumulator, i); // calculate reflection color

            return lerpColor(surfaceCol, reflectionCol, reflectiveness);
          
          /*
            if there are no more hits but reflection max hasn't been hit add the lerp between background color and surface col
            and then return
          */
          }else if(hits.size() == 0){
            
            return lerpColor(surfaceCol, scene.background, reflectiveness);
            
          }
        }
      }
      
      return scene.background;
    }
}
