String input =  "data/tests/milestone1/test1.json";
String output = "data/tests/milestone1/test1.png";
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
          only calculate relfections if scene calls for it
        */
        if (scene.reflections > 0){
          
          //send first hit and ray used to get that hit to the calculator
          color col = color(0,0,0);
          col = calculateReflections(scene, hit, ray, col, 0);
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
    
    color calculateReflections(Scene scene, RayHit h, Ray r, color a ,int i){
      
      
      RayHit hit = h;
      Ray ray = r;
      color accumulator = a;
      
      if(i < scene.reflections){
        
        color surfaceCol = scene.lighting.getColor(hit, scene, ray.origin);
        
        /*
          Non reflective surface, add surface color to accumulator and then break out of loop
        */
        if(hit.material.properties.reflectiveness == 0){
          
          accumulator = addColors(accumulator, surfaceCol);
          
          return accumulator;
          
        /*
          Perfect reflective surface, calculate reflection vector and then get reflection color 
          add that color to the accumulator
        */
        }else if(hit.material.properties.reflectiveness == 1){
          
          //calculate reflection vector
          PVector Rm = PVector.mult(hit.normal, 2).mult(PVector.dot(hit.normal, ray.origin)).sub(ray.origin).normalize();
          
          PVector impact = new PVector(hit.location.x + EPS, hit.location.y + EPS);
          
          //set ray to new shit
          ray = new Ray(impact, Rm);
          
          //calculate new hits
          ArrayList<RayHit> hits = scene.root.intersect(ray);
          
          //set new hit
          hit = hits.get(0);
          
          /*
            check if there are more hits if so reset hit for next loop
          */
          if(hits.size() > 0 && (i + 1) < scene.reflections){
            
            //get reflection color
            color reflectionCol = calculateReflections(scene, hit, ray, i++, accumulator); // calculate reflection color
            
            accumulator = addColors(accumulator, reflectionCol);
            return reflectionCol;
          
          /*
            if no more hits but reflection max hasn't been hit add background color to accumulator and break
          */
          }else if(hits.size() == 0 && (i + 1) < scene.reflections){
            
            accumulator = addColors(accumulator, scene.background);
            return accumulator;
            
          }else{
            
            //do nothing
            
          }
          
        /*
          Non perfect reflective surface, calculate relfection vector and reflection color, add the 
          lerp between surfaceCol and reflection color with some factor for internsity to the accumulator
        */
        }else{
          
          //calculate reflection vector
          PVector Rm = PVector.mult(hit.normal, 2).mult(PVector.dot(hit.normal, ray.origin)).sub(ray.origin).normalize();
          
          PVector impact = new PVector(hit.location.x + EPS, hit.location.y + EPS);
          
          //set ray to new shit
          ray = new Ray(impact, Rm);
          
          //calculate new hits
          ArrayList<RayHit> hits = scene.root.intersect(ray);
          
          //set new hit
          hit = hits.get(0);
          
          /*
            check if there are more hits if so reset hit for next loop
          */
          if(hits.size() > 0 && (i + 1) < scene.reflections){
            
            //get reflection color
            color reflectionCol = calculateReflections(scene, hit, ray, i++, accumulator); // calculate reflection color
            accumulator = addColors(accumulator, lerpColor(reflectionCol, surfaceCol, hit.material.properties.reflectiveness)); // wrong hit property we need to old one not the new one
            
            return accumulator;
          
          /*
            if no more hits but reflection max hasn't been hit add background color to accumulator and break
          */
          }else if(hits.size() == 0 && (i + 1) < scene.reflections){
            
            accumulator = addColors(accumulator, lerpColor(surfaceCol, scene.background, hit.material.properties.reflectiveness)); // wrong hit property we need to old one not the new one
            
            return accumulator;
            
          }else{
            
            //do nothing
            
          }
          
        }
        
      }
      
      return accumulator;//return that bitch
    
    }
}
