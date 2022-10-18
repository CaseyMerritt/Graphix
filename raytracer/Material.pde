class MaterialProperties
{
    float ks;
    float ka;
    float kd;
    float alpha;
    float reflectiveness;
    float refractionIndex;
    float transparency;
    
    MaterialProperties(float ka, float ks, float kd, float alpha, float reflectiveness, float transparency, float refractionIndex)
    {
       this.ks = ks;
       this.ka = ka;
       this.kd = kd;
       this.alpha = alpha;
       this.reflectiveness = reflectiveness;
       this.transparency = transparency;
       this.refractionIndex = refractionIndex;
    }
}

class Material
{
    MaterialProperties properties;
    color col;
    color getColor(float u, float v)
    {
      return col;
    }
    Material(MaterialProperties props, color col)
    {
       this.properties = props;
       this.col = col;
    }
}

class TexturedMaterial extends Material
{
    PImage texture;
    TexturedMaterial(MaterialProperties props, PImage texture)
    {
      super(props, color(0));
      this.texture = texture;
      this.texture.loadPixels();
    }
    
    color getColor(float u, float v)
    {
      int x = clamp(int(this.texture.width * u), 0, this.texture.width-1);
      int y = clamp(int(this.texture.height*v), 0, this.texture.height-1);
      
      return this.texture.get(x,y);
    }
    
}

static class ProceduralMaterialRegistry
{
   static HashMap<String,ProceduralMaterialBuilder> registry;
   
   static void register(String name, ProceduralMaterialBuilder mat)
   {
       if (registry == null)
       {
           registry = new HashMap<String,ProceduralMaterialBuilder>();
       }
       registry.put(name, mat);
   }
   
   static ProceduralMaterial getMaterial(String name, MaterialProperties props)
   {
       if (registry.containsKey(name))
           return registry.get(name).make(props);
       println("WARNING: Unknown material " + name + "; using default instead.");
       return registry.get("Lava").make(props);
   }
}

class ProceduralMaterial extends Material
{
    ProceduralMaterial(MaterialProperties props)
    {
       super(props, color(0));
    }
    
    color getColor(float u, float v)
    {
       return color(0);
    }
}

class ProceduralMaterialBuilder
{
    ProceduralMaterialBuilder(String name)
    {
        ProceduralMaterialRegistry.register(name, this);
    }
    ProceduralMaterial make(MaterialProperties props)
    {
        return new ProceduralMaterial(props);
    }
}

class SineWaveMaterial extends ProceduralMaterial
{
    SineWaveMaterial(MaterialProperties props)
    {
       super(props);
    }
    
    color getColor(float u, float v)
    {
       return multColor(color(255,0,0), 0.5 + 0.25*sin((u+v*sin(millis()/5000.0))*30+millis()/1000.0));
    }
}

class SineWaveMaterialBuilder extends ProceduralMaterialBuilder
{
    SineWaveMaterialBuilder()
    {
        super("SineWave");
    }
    ProceduralMaterial make(MaterialProperties props)
    {
        return new SineWaveMaterial(props);
    }
}

SineWaveMaterialBuilder sinewave = new SineWaveMaterialBuilder();

class LavaMaterial extends ProceduralMaterial
{
    PImage texture;
    LavaMaterial(MaterialProperties props)
    {
       super(props);
       this.texture = loadImage("lava.jpg");
       this.texture.loadPixels();
    }
    
    color getColor(float u, float v)
    {
       u += sin(millis()/10000.0)/15;
       v += sin(millis()/8000.0)/20;
       int x = clamp(int(this.texture.width * u), 0, this.texture.width-1);
       int y = clamp(int(this.texture.height*v), 0, this.texture.height-1);
       
       return this.texture.get(x,y);
    }
}

class LavaMaterialBuilder extends ProceduralMaterialBuilder
{
    LavaMaterialBuilder()
    {
        super("Lava");
    }
    ProceduralMaterial make(MaterialProperties props)
    {
        return new LavaMaterial(props);
    }
}

LavaMaterialBuilder lava = new LavaMaterialBuilder();
