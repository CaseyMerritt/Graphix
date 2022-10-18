# Scripts

The framework comes with some python scripts that are provided as-is, with no further documentation or support. You may find them helpful if you want to write your own scripts to generate more complex scenes or animations, though.

- `make_moon.py` creates a sphere with many smaller spheres carved out of it, such as in `milestone3/test14.json`, "the moon". Care is taken that the smaller spheres are on the side of the moon that is closer to the camera.
- `make_spheres.py` creates a scene with a plane and many spheres atop it, such as in `milestone3/test10.json` to `milestone3/test12.json`, which use the same base code with some variations.
- `make_rotating_lens.py` creates the animation files for `milestone3/animation1`, where the camera rotates around a scene consisting of two spheres and a lens.
- `make_moving_transparency.py` creates the animation files for `milestone3/animation2`, where a sphere moves behind a partially transparent hyperboloid intersected with a sphere.
- `convert_obj.py` reads a wavefront obj-file, and outputs the triangles (including texture mapping!) in the json file format suitable for our raytracer.
- `make_textured_moon.py` creates the animation files for `milestone4/animation1` of earth orbited by a moon (that's no moon!).
