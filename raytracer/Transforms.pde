class MoveRotation implements SceneObject
{
  SceneObject child;
  PVector movement;
  PVector rotation;
  
  MoveRotation(SceneObject child, PVector movement, PVector rotation)
  {
    this.child = child;
    this.movement = movement;
    this.rotation = rotation;
    
    // remove this line when you implement Movement+Rotation
    throw new NotImplementedException("Movement+Rotation not implemented yet");
  }
  
  
  
  ArrayList<RayHit> intersect(Ray r)
  {
     return child.intersect(r);
  }
}

class Scaling implements SceneObject
{
  SceneObject child;
  PVector scaling;
  
  Scaling(SceneObject child, PVector scaling)
  {
    this.child = child;
    this.scaling = scaling;
    
    // remove this line when you implement Scaling
    throw new NotImplementedException("Scaling not implemented yet");
  }
  
  
  ArrayList<RayHit> intersect(Ray r)
  {
     return child.intersect(r);
  }
}
