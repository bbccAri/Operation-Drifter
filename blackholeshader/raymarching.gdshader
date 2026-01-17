shader_type spatial;
render_mode unshaded;

#define MAX_STEPS 15
#define MAX_DIST 15.
#define SURF_DIST .01

float get_distance_to_surface(vec3 p) {
	float radius = .3;
	return length(p) - radius;
}

float ray_march(vec3 ray_origin, vec3 ray_dir) {
	float dist_from_origin = 0.;
	float dist_to_surf;
	
	for(int i = 0; i < MAX_STEPS; i++) {
		vec3 point = ray_origin + ray_dir  * dist_from_origin;
		dist_to_surf = get_distance_to_surface(point);
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
