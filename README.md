# Particle Swarms (GLSL shaders running in TouchDesigner)

This particle system is made in TouchDesigner. It's written as a GLSL shader and run in TouchDesigner along with a bunch of GUI features and other thingamajigs that make it fun and interactive to play with.

The particles are simple boid systems. They feel attractive and repulsive forces to other particles within a radius/cone. The forces they feel can be modified for interesting effects. Feel free to experiment with radial/conal areas of effect, or changing the ratios of forces, or changing their radii of interaction. The shader is the `particle_shader.glsl` file. Modify the inter-particle forces here.

To run it, open the TD Project File `ParticleComputeShader.GUI.toe`. Right-click on the `particles` container and click on `view` to create an interactive window for the GUI. Otherwise, double-click the container to enter the project and see all its components.

![](https://github.com/heysoos/td_swarm_particles/blob/main/media/td_open.gif)


### Keyboard shortcuts
- Press `1` to reset the particles. (You must do this if you change the # of particles in the GUI).
- `SPACEBAR` toggles time.

### GUI Parameters
![](https://raw.githubusercontent.com/heysoos/td_swarm_particles/main/media/GUI.png)

### Loading in Audio Files
...