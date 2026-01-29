shader_type spatial;
render_mode unshaded;

#define MAX_STEPS 15
#define MAX_DIST 15.
#define SURF_DIST .01

#define GRAV 6.67430e-11
#define C 299792458.0
#define BH_POS vec2(0, 0)
#define BH_MASS 1000000.0
#define BH_R_S (2.0 * GRAV * BH_MASS) / (C*C)

float SDSphere(vec3 p, float radius) {
	return length(p) - radius;
}

float SDBox(vec3 p, vec3 half_size) {
	return length(max(abs(p) - half_size, 0));
}

float SDTorus(vec3 p, float big_radius, float small_radius) {
	return length(vec2(length(p.xz) - big_radius, p.y)) - small_radius;
}

float SDCapsule(vec3 p, float half_height, float radius) {
	vec3 axis = normalize(vec3(0, 1, 0));
	vec3 a = axis * half_height;
	vec3 b = -a;
	vec3 ab = b - a;
	vec3 pa = p - a;
	float t = dot(pa, ab) / dot(ab, ab);
	t = clamp(t, 0, 1);
	vec3 c = a + ab * t;
	return length(p - c) - radius;
}

float SDCylinder(vec3 p, float half_height, float radius) {
	vec3 axis = normalize(vec3(0, 1, 0));
	vec3 a = axis * half_height;
	vec3 b = -a;
	vec3 ab = b - a;
	vec3 pa = p - a;
	float t = dot(pa, ab) / dot(ab, ab);
	vec3 c = a + ab * t;
	float d = length(p - c) - radius;
	float y = (abs(t - 0.5) - 0.5) * length(ab);
	return length(max(vec2(d, y), 0));
}

float SDRoundDisk(vec3 p, float half_height, float big_radius, float small_radius) {
	vec3 axis = normalize(vec3(0, 1, 0));
	vec3 a = axis * half_height;
	vec3 b = -a;
	vec3 ab = b - a;
	vec3 pa = p - a;
	float t = dot(pa, ab) / dot(ab, ab);
	vec3 c = a + ab * t;
	float d = length(p - c) - big_radius;
	float y = (abs(t - 0.5) - 0.5) * length(ab);
	return length(max(vec2(d, y), 0)) - small_radius;
}

float SDF(vec3 p) {
	//float d = SDSphere(p, 0.3);
	//float d = SDBox(p, vec3(0.25));
	//float d = SDTorus(p, 0.3, 0.1);
	//float d = SDCapsule(p, 0.4, 0.1);
	//float d = SDCylinder(p, 0.4, 0.1);
	float d = SDRoundDisk(p, 0.001, 0.4, 0.001);
	//float d = SDTorusDisk(p, 0.01, 0.4, 0.1);
	return d;
}

float ray_march(vec3 ray_origin, vec3 ray_dir) {
	float dist_from_origin = 0.;
	float dist_to_surf;
	
	for(int i = 0; i < MAX_STEPS; i++) {
		vec3 point = ray_origin + ray_dir  * dist_from_origin;
		dist_to_surf = SDF(point);
		dist_from_origin += dist_to_surf;
		if (dist_from_origin > MAX_DIST || dist_to_surf < SURF_DIST)
			break;
	}
	
	return dist_to_surf;
}

varying vec3 vert;

void vertex() {
	// Called for every vertex the material is visible on.
	vert = VERTEX;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = fract(UV * vec2(3, 2)) - 0.5;
	vec3 ray_origin = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1)).xyz;
	vec3 ray_dir = normalize(vert - ray_origin);
	vec3 color = vec3(0);
	
	float dist = ray_march(ray_origin, ray_dir);
	if (dist < SURF_DIST) { // Hit Something
		color.r = 1.;
	}
	else {
		discard;
	}
	ALBEDO = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
