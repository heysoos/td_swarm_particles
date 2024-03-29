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
- `record`: records a video and saves it in the directory.
- `seed`: Sets the random seed for the noise used to generate the inter-particle interactions (and any other randomly generated thing).
- `dt`: Sets the rate at which time ticks. The smaller the better for accuracy, though the interactions aren't conserved, meaning they can change if you change dt.
- `alignment`: An alignment of -1 means the cone of vision for each particle is a circle. At 0 it is a semi-circle, and for values less than 1 and greater than 0, it is a cone.
- `C` vs. `G`: This 2D slider allows you to control the forces of the Coulomb (repulsive) and Gravitational (attractive) forces.
- `R_c` vs. `R_g`: This 2D slider allows you to control the radii of the respective `C` and `G` forces.

Then for the parameters in second box on the right:
#### Particle Params.
- `Res`: The resolution of the particle data textures. Since they are 2D textures, the `# of particles` = `Res * Res`.
- `Mass Variance`: Different particle colours can have different masses, and this slider controls the variance of their distribution. 
- `Force Ratio`: The ratio of values available in the `C` vs. `G` 2D slider. A large value will mean that the maximum `C` force is much stronger than the maximum `G` force.
- `Max G`: The maximum value of G. Possibly a redundant parameter.
- `Friction`: How much particles slow down as a function of their current velocity.
- `Random Vel.`: The magnitude of the random velocity that is added to each particle at each time.
...
- `Num. Colors`: This sets the number of different particle types there are. With 1 color, every particle is identical. With 2 colors, there are two types of particles and each has a (semi-)random interaction with other colored particles. I have customized how the different colors interact with a combination of random noise as well as some structural differences. Feel free to experiment with how different coloured particles interact. I think there is some magic to be discovered here by introducing certain symmetries or symmetry-breaking interactions. 

The rest of the parameters should be self-explanatory.

### Loading in Audio Files
...