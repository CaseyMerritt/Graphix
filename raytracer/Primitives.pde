class Sphere implements SceneObject
{
    PVector center;
    float radius;
    Material material;
    Sphere(PVector center, float radius, Material material)
    {
       this.center = center;
       this.radius = radius;
       this.material = material;
       
       // remove this line when you implement spheres
       //throw new NotImplementedException("Spheres not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
        float tp = PVector.sub(center, r.origin).dot(r.direction);
        PVector p = PVector.mult(r.direction, tp).add(r.origin).sub(center);
        double x = p.mag();
        
        if(x <= radius){
          double impactPoint1 = tp + Math.sqrt((radius * radius) - (x * x));
          double impactPoint2 = tp - Math.sqrt((radius * radius) - (x * x));
          
          RayHit rh1 = new RayHit();
          rh1.t = (float) impactPoint1;
          rh1.location = PVector.add(r.direction, r.origin).mult(rh1.t);
          rh1.normal = PVector.sub(rh1.location, center).normalize();
          
          RayHit rh2 = new RayHit();
          rh2.t = (float) impactPoint2;
          rh2.location = PVector.add(r.direction, r.origin).mult(rh2.t);
          rh2.normal = PVector.sub(rh2.location, center).normalize(); 
          
          rh2.material = material;
          rh1.material = material;
          
          //calulate UV coords, supposed to be normalized idk tho
          rh2.u = 0.5 + (atan2(rh2.normal.y, rh2.normal.x) / (2 * PI));
          rh2.v = 0.5 - (asin(rh2.normal.z) / PI);
          
          //calulate UV coords, supposed to be normalized idk tho
          rh1.u = 0.5 + (atan2(rh1.normal.x, rh1.normal.y) / (2 * PI));
          rh1.v = 0.5 - (asin(rh1.normal.z) / PI);
          
          if(rh1.t > 0 && rh2.t > 0){
            rh2.entry = true;
            rh1.entry = false;
            result.add(rh2);
            result.add(rh1);
          }
        }
        return result;
    }
}

class Plane implements SceneObject
{
    PVector center;
    PVector normal;
    float scale;
    Material material;
    PVector left;
    PVector up;
    
    Plane(PVector center, PVector normal, Material material, float scale)
    {
       this.center = center;
       this.normal = normal.normalize();
       this.material = material;
       this.scale = scale;
       
       // remove this line when you implement planes
       //throw new NotImplementedException("Planes not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
        float t = ((PVector.sub(center,r.origin)).dot(normal))/(PVector.dot(r.direction,normal));
        if(t > 0){
          RayHit rh1 = new RayHit();
          rh1.t = t;
          rh1.location = PVector.mult(r.direction,rh1.t).add(r.origin);
          rh1.normal = normal;
          
          PVector rvec = new PVector(0,0,1).cross(rh1.normal).normalize();
          PVector uvec = rh1.normal.cross(rvec).normalize();
          
          PVector impact = rh1.location;
          PVector d = PVector.sub(impact, center);
          
          float x = d.dot(rvec);
          float y = d.dot(uvec);
          
          x = x / scale;
          y = y / scale;
          
          rh1.u = x - floor(x);
          rh1.v = (-y) - floor(-y);
          
          
          rh1.material = material;
          rh1.entry = true;
          result.add(rh1);
        }
        return result;
    }
}

class Cylinder implements SceneObject
{
    float radius;
    float height;
    Material material;
    float scale;
    
    Cylinder(float radius, Material mat, float scale)
    {
       this.radius = radius;
       this.height = -1;
       this.material = mat;
       this.scale = scale;
       
       // remove this line when you implement cylinders
       throw new NotImplementedException("Cylinders not implemented yet");
    }
    
    Cylinder(float radius, float height, Material mat, float scale)
    {
       this.radius = radius;
       this.height = height;
       this.material = mat;
       this.scale = scale;
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
}

class Triangle implements SceneObject
{
    PVector v1;
    PVector v2;
    PVector v3;
    PVector normal;
    PVector tex1;
    PVector tex2;
    PVector tex3;
    Material material;
    
    Triangle(PVector v1, PVector v2, PVector v3, PVector tex1, PVector tex2, PVector tex3, Material material)
    {
       this.v1 = v1;
       this.v2 = v2;
       this.v3 = v3;
       this.tex1 = tex1;
       this.tex2 = tex2;
       this.tex3 = tex3;
       this.normal = PVector.sub(v2, v1).cross(PVector.sub(v3, v1)).normalize();
       this.material = material;
       
       // remove this line when you implement triangles
       //throw new NotImplementedException("Triangles not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
        
        float t = ((PVector.sub(v1,r.origin)).dot(normal))/(PVector.dot(r.direction,normal));
        PVector point = PVector.mult(r.direction,t).add(r.origin);
        if(t > 0){
          if(PointInTriangle(v1,v2,v3,point)){
            //float[] uv = computeUV(v1,v2,v3,r.direction);
            RayHit rh1 = new RayHit();
            rh1.t = t;
            rh1.location = PVector.mult(r.direction,rh1.t).add(r.origin);
            rh1.normal = normal;
            rh1.material = material;
            rh1.entry = true;
            result.add(rh1);
            
            float[] uv = computeUV(v2,v3,v1,point);
            float c = 1 - (uv[0] + uv[1]);
            rh1.u = (tex1.x * uv[0]) + (tex2.x * uv[1]) + (tex3.x * c);
            rh1.v = (tex1.y * uv[0]) + (tex2.y * uv[1]) + (tex3.y * c);
            
          } else {
            //print(u + " " + v + "***");
          }
        }
       
       
        return result;
       
    }
    float[] computeUV(PVector a,PVector b,PVector c,PVector p){
      PVector e = PVector.sub(c,b);
      PVector g = PVector.sub(a,b);
      PVector d = PVector.sub(p,b);
      float denom = (PVector.dot(e,e) * PVector.dot(g,g)) - (PVector.dot(e,g) * PVector.dot(g,e));
       
      float[] uv = new float[2];
      uv[0] = ((PVector.dot(g,g) * PVector.dot(d,e)) - (PVector.dot(e,g) * PVector.dot(d,g)))/denom;
      uv[1] = ((PVector.dot(e,e) * PVector.dot(d,g)) - (PVector.dot(e,g) * PVector.dot(d,e)))/denom;
      return uv;
    }
    boolean PointInTriangle(PVector a,PVector b,PVector c,PVector p){
      float[] uv = computeUV(a,b,c,p);
      return ((uv[0] >= 0) && (uv[1] >= 0) && uv[0]+ uv[1] <= 1);
    }
}


class Cone implements SceneObject
{
    Material material;
    float scale;
    
    Cone(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement cones
       throw new NotImplementedException("Cones not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
   
}

class Paraboloid implements SceneObject
{
    Material material;
    float scale;
    
    Paraboloid(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement paraboloids
       throw new NotImplementedException("Paraboloid not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
   
}

class HyperboloidOneSheet implements SceneObject
{
    Material material;
    float scale;
    
    HyperboloidOneSheet(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement one-sheet hyperboloids
        throw new NotImplementedException("Hyperboloids of one sheet not implemented yet");
    }
  
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
}

class HyperboloidTwoSheet implements SceneObject
{
    Material material;
    float scale;
    
    HyperboloidTwoSheet(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement two-sheet hyperboloids
        throw new NotImplementedException("Hyperboloids of two sheets not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
}
