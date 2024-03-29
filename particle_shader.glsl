uniform float dt;
uniform vec2 bounds;

uniform vec4 m_in;

// boid stuff
uniform vec4 B_rads; // boid radius
uniform float G; // attraction  
uniform float C; // repulsion
uniform float A; // alignment

uniform float F; // friction 
uniform vec2 S; // strong force [amp. coef, exp. coef]
uniform float rand;

layout (local_size_x = 4, local_size_y = 4) in;
int resX = int(uTD2DInfos[0].res.b);
int resY = int(uTD2DInfos[0].res.a);

float x_lim = bounds[0];
float y_lim = bounds[1];

float V_MAX = 10.;
// float dv_max = 10;
float eps = 0.0001;


// Particle struct
struct ParticleData {
    vec4 position;
    vec4 velocity;
    int color;
    float mass;
    float charge;
};


vec4 move(vec4 pos, vec4 vel) {
	pos.xy += vel.xy * dt;
	return pos;
}

vec2 pb_distance(vec2 diff){
    // Assuming diff is the displacement vector from one particle to another
    diff = diff - round(diff / vec2(x_lim, y_lim)) * vec2(x_lim, y_lim);
    return diff;
}

vec2 calc_particle_forces(ParticleData self) {
	vec2 gs = vec2(0., 0.); // net force on self particle
	vec2 p_g;

	
	for (int x = 0; x < resX; x++) {
		for (int y = 0; y < resY; y++) {
		
			if (x != gl_GlobalInvocationID.x || y != gl_GlobalInvocationID.y) { 

				vec2 p_g = vec2(0., 0.); // net particle-particle forces

				ivec2 otherIndex = ivec2(x, y);
                ParticleData other;
                other.position = texelFetch(sTD2DInputs[0], otherIndex, 0);
                other.velocity = texelFetch(sTD2DInputs[1], otherIndex, 0);
                other.color = int(texelFetch(sTD2DInputs[3], otherIndex, 0).x);
                other.mass = abs(texelFetch(sTD2DInputs[5], ivec2(other.color, other.color), 0).x + eps);
                other.charge = texelFetch(sTD2DInputs[5], ivec2(other.color, other.color), 0).y;

				vec4 Jijcol_j = texelFetch(sTD2DInputs[4], ivec2(self.color, other.color), 0);
				
				
				// periodic boundaries for distance calc
				vec2 diff = other.position.xy - self.position.xy;
				if (abs(diff.x) > x_lim / 2) {
					diff.x = -1 * sign(diff.x) * (x_lim - abs(diff.x));
				}
				if (abs(diff.y) > y_lim / 2) {
					diff.y = -1 * sign(diff.y) * (y_lim - abs(diff.y));
				}
				float r = length(diff);
				vec2 diff_dir = normalize(diff);
				vec2 vel_dir = normalize(self.velocity.xy);

				// how aligned is the particle's velocity with the attracting object's position?
				// if greater than 0 it's in front, if less than 0 it's behind the cone of vision.

				float pointing = vel_dir.x * diff_dir.x + vel_dir.y * diff_dir.y;
				if (r < B_rads[0] * abs(Jijcol_j[2]) && pointing > B_rads[2]) {

					p_g += Jijcol_j[0] * G * (self.mass * other.mass) * normalize(diff) / (pow(r, 2) + eps); // attraction
					// p_g += Jijcol_j[1] * A * (other.velocity.xy - vel); // alignment
					
					// strong force thingy
					// p_g += clamp(S[0] * normalize(diff) / (r*r + 0.001) + S[1], -dv_max, dv_max);
					// (or weak force)
					// gs += clamp(S[0] * normalize(diff) / (r*r + 0.001) * exp(-S[1]*r), -5., 5.);
					
				}

				// boid stuff
				if (r < B_rads[1] * abs(Jijcol_j[3])) {
					p_g += Jijcol_j[2] * C * normalize(diff) / (pow(r, 2) + eps); // close-range repulsion
				}

				// p_g += normalize(diff) * (S[0] / (r*r + 0.001) + S[1]); // strong force thingy
				
				gs += p_g; // net forces from all particles
			}
		}
	}

	return gs;
}


vec2 calc_gravity(vec2 pos){
	// currently used to make RMB/LMB pull/push particles around

	vec2 g = vec2(0., 0.);
	// float r2 = length(pos);
	
	// if (r2 > 0.5) {
	// 	g *= 0.;
	// }
	// else if (r2 < 1.) {
		// g  = -G * normalize(pos.xy) * sqrt(r2);  // sphere of uniform density 
	// }
	// if (r2 > 0.4 && r2 < 0.5){ // ring of gravity
	// 	g = -0.1 * normalize(pos.xy) / r2; 
	// }


	vec2 diff = m_in.xy - pos.xy;
	diff = pb_distance(diff);
	// vec2 diff = vec2(0., m_in.y - pos.y); // 
	float r = length(diff);
	if (r < m_in.w ) {
		g = m_in.z * normalize(diff) ;
	}
	// g = -0.05 * normalize(diff) / r2;
	
	return g;
}

vec2 norm_clip(vec2 vec) {
	// particles need to obey the speed limit
	float norm = length(vec.xy);
	if (norm > V_MAX) {
		vec = V_MAX * normalize(vec);
	}	
	return vec;
}

vec4 forces(ParticleData self) {
	vec2 gravity;
	vec2 friction;
	vec2 particle_forces;
	vec2 dv;

	gravity = calc_gravity(self.position.xy);
	friction = -F * sign(self.velocity.xy) * self.velocity.xy * self.velocity.xy;
	particle_forces = calc_particle_forces(self);

	dv = (particle_forces + gravity + friction) / (self.mass + eps);
	self.velocity.xy += dt * dv;
	self.velocity.xy = norm_clip(self.velocity.xy);

	return self.velocity;
}


vec4 edge(vec4 pos) {
	
	if (pos.x < -x_lim * 0.5) {
		pos.x = pos.x + x_lim;
	}
	if (pos.x > x_lim * 0.5) {
		pos.x = pos.x - x_lim;
	}
	if (pos.y < -y_lim * 0.5) {
		pos.y = pos.y + y_lim;
	}
	if (pos.y > y_lim * 0.5) {
		pos.y = pos.y - y_lim;
	}
	return pos;
}


void main()
{	
	ivec2 selfIndex = ivec2(gl_GlobalInvocationID.xy);
    ParticleData self;
    self.position = texelFetch(sTD2DInputs[0], selfIndex, 0);
    self.velocity = texelFetch(sTD2DInputs[1], selfIndex, 0);
    self.color = int(texelFetch(sTD2DInputs[3], selfIndex, 0).x);
    self.mass = abs(texelFetch(sTD2DInputs[5], ivec2(self.color, self.color), 0).x + eps);
    self.charge = texelFetch(sTD2DInputs[5], ivec2(self.color, self.color), 0).y;

	vec4 rand_vel = rand * texelFetch(sTD2DInputs[2], selfIndex, 0);
	
	vec4 vel = forces(self) + rand_vel;
	vec4 pos = move(self.position, vel);
	pos = edge(pos);
	
	imageStore(mTDComputeOutputs[0], ivec2(gl_GlobalInvocationID.xy), TDOutputSwizzle(pos));
	imageStore(mTDComputeOutputs[1], ivec2(gl_GlobalInvocationID.xy), TDOutputSwizzle(vel));
}
