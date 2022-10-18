// faster than the built-in red(), green() and blue() functions
int r(color c)
{
  return c >> 16 & 0xFF;
}

int g(color c)
{
  return c >> 8 & 0xFF;
}

int b(color c)
{
  return c & 0xFF;
}


// restrict an integer value within a given range
int clamp(int x, int low, int high)
{
   if (x < low) return low;
   if (x > high) return high;
   return x;
}

// multiply each component of a color with a scale given by another color
// The second color's r,g,b channels define a scale between 0 and 255, and will be divided by 255 to
// ensure that the result is a valid color
color scaleColor(color c, color scale)
{
  return color(int(r(c)*r(scale)/255.0), int(g(c)*g(scale)/255.0), int(b(c)*b(scale)/255.0));
}

// perform a component-wise addition of two colors, ensuring that the components are within
// the valid range for colors.
color addColors(color x, color y)
{
  return color(clamp(r(x) + r(y), 0, 255), clamp(g(x) + g(y), 0, 255), clamp(b(x) + b(y), 0, 255));
}

// Multiply each component of a color with a given float, restricting it to valid color values
color multColor(color c, float a)
{
  return color(clamp(int(r(c)*a), 0, 255), clamp(int(g(c)*a), 0, 255), clamp(int(b(c)*a), 0, 255));
}

// Determine the sign of a float, -1 if x is negative, 1 if it is positive, 0 if it is 0
float sgn(float x)
{
  if (x < 0) return -1;
  if (x > 0) return 1;
  return 0;
}

// a "small" floating point value; useful for offsets and tolerances
float EPS = 0.01;

// Exception raised by constructors of currently unsupported operations
public class NotImplementedException extends RuntimeException 
{ 
    public NotImplementedException(String errorMessage) 
    {
        super(errorMessage);
    }
}
