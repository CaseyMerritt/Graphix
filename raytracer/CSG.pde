import java.util.Comparator;

class HitCompare implements Comparator<RayHit>
{
  int compare(RayHit a, RayHit b)
  {
     if (a.t < b.t) return -1;
     if (a.t > b.t) return 1;
     if (a.entry) return -1;
     if (b.entry) return 1;
     return 0;
  }
}

class Union implements SceneObject
{
  SceneObject[] children;
  Union(SceneObject[] children)
  {
    this.children = children;
    // remove this line when you implement true unions
    //println("WARNING: Using 'fake' union");
  }

  ArrayList<RayHit> intersect(Ray r)
  {
     
     ArrayList<RayHit> hits = new ArrayList<RayHit>();
     
     // Reminder: this is *not* a true union
     // For a true union, you need to ensure that enter-
     // and exit-hits alternate
     for (SceneObject sc : children)
     {
       hits.addAll(sc.intersect(r));
     }
     hits.sort(new HitCompare());
     
     ArrayList<RayHit> toReturn = new ArrayList<RayHit>(); 
     int count = 0;
     for(int i = 0; i<hits.size();i++ )
       if(count == 0 && hits.get(i).entry){
         toReturn.add(hits.get(i));
         count++;
       } else if (count == 1 && !hits.get(i).entry){
         toReturn.add(hits.get(i));
         count--;
       } else if(hits.get(i).entry){
         count++;
       } else if(!hits.get(i).entry){
         count--;
       }   
     return toReturn;
  }
}

class Intersection implements SceneObject
{
  SceneObject[] elements;
  Intersection(SceneObject[] elements)
  {
    this.elements = elements;

    // remove this line when you implement intersection
    //throw new NotImplementedException("CSG Operation: Intersection not implemented yet");
  }
  ArrayList<RayHit> intersect(Ray r)
  {
     
     ArrayList<RayHit> hits = new ArrayList<RayHit>();
     
     // Reminder: this is *not* a true union
     // For a true union, you need to ensure that enter-
     // and exit-hits alternate
     for (SceneObject sc : elements)
     {
       hits.addAll(sc.intersect(r));
     }
     hits.sort(new HitCompare());
     
     ArrayList<RayHit> toReturn = new ArrayList<RayHit>(); 
     int count = 0;
     for(int i = 0; i<hits.size();i++ )
       if(count == 1 && hits.get(i).entry){
         toReturn.add(hits.get(i));
         count++;
       } else if (count == 0 && !hits.get(i).entry){
         toReturn.add(hits.get(i));
         count--;
       } else if(hits.get(i).entry){
         count++;
       } else if(!hits.get(i).entry){
         count--;
       }   
     return toReturn;
  }
  
}

class Difference implements SceneObject
{
  SceneObject a;
  SceneObject b;
  Difference(SceneObject a, SceneObject b)
  {
    this.a = a;
    this.b = b;
    
    // remove this line when you implement difference
    //throw new NotImplementedException("CSG Operation: Difference not implemented yet");
  }
  
  ArrayList<RayHit> intersect(Ray r)
  {
     ArrayList<RayHit> hits = new ArrayList<RayHit>();
     ArrayList<RayHit> hitsa = new ArrayList<RayHit>();
     ArrayList<RayHit> hitsb = new ArrayList<RayHit>();
     
     hitsa.addAll(a.intersect(r));
     hitsb.addAll(b.intersect(r));
     hits.addAll(hitsa);
     hits.addAll(hitsb);
     hits.sort(new HitCompare());
     
     ArrayList<RayHit> toReturn = new ArrayList<RayHit>(); 
     //We only have b return nothing
     if(hitsa.size() == 0)
       return toReturn;
     //We only have a return a
     if(hitsb.size() == 0)
       return hitsa;
     
     if(hits.get(0) == hitsa.get(0)){
       toReturn.add(hits.get(0));
       if(hits.get(1) == hitsa.get(1))
         toReturn.add(hits.get(1));
       else{
         hitsb.get(0).entry = false;
         hitsb.get(0).normal = PVector.mult(hitsb.get(0).normal,-1);
         toReturn.add(hitsb.get(0));
       }
     }
     // we enter b first
     else{
       // we exit b return hitsa
       if(hits.get(1)==hitsb.get(1))
         return hitsa;
       // we entered a
       else {
         if(hits.get(2) == hitsa.get(1))
           return toReturn;
         else if(hits.get(2) == hitsb.get(1))
           hitsb.get(1).normal = PVector.mult(hitsb.get(1).normal,-1);
           hitsb.get(1).entry = true;
           toReturn.add(hitsb.get(1));
           toReturn.add(hitsa.get(1));
        
       }
     }
     
     
      
     return toReturn;
  }
  
}
