#include <imgtool.h>
#include <libfract.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAX_RAY_STEP 100
#define MAX_RAY_DIST 100
#define SURFACE_DIST 0.1f

#define px_at(bmp, x, y) (bmp.pixels + ((bmp.width * (y)) + (x)) * bmp.channels)
#define clmpf(x) (float)((x) * ((x) > 0.0 && (x) < 1.0) + ((x) >= 1.0))
#define minf(a, b) (float)(a * (a <= b) + b * (b < a))

float scene_dist(vec3 position)
{
    float sphereRadius = 1.0f;
    vec3 sphereCenter = {0.0f, 2.0f, 5.0f};
    float sphereDist = vec3_mag(vec3_sub(position, sphereCenter)) - sphereRadius;
    float planeDist = position.y;
    float dist = minf(sphereDist, planeDist);
    return dist;
}

float ray_march(vec3 origin, vec3 direction)
{
    float d = 0.0f;
    for (int i = 0; i < MAX_RAY_STEP; i++) {
        vec3 pos = vec3_add(origin, vec3_mult(direction, d));
        float dist = scene_dist(pos);
        d += dist;
        if (d > MAX_RAY_DIST || dist < SURFACE_DIST) break;
    }
    return d;
}

vec3 get_normal(vec3 pos)
{
    float dist = scene_dist(pos);
    vec2 e = {0.01, 0.0f};
    
    float x = scene_dist(vec3_sub(pos, vec3_new(e.x, e.y, e.y)));
    float y = scene_dist(vec3_sub(pos, vec3_new(e.y, e.x, e.y)));
    float z = scene_dist(vec3_sub(pos, vec3_new(e.y, e.y, e.x)));

    vec3 normal = vec3_sub(vec3_uni(dist), vec3_new(x, y, z));
    return vec3_norm(normal);
}

float get_light(vec3 pos)
{
    vec3 light_pos = vec3_new(1.0f, 5.0f, 2.0f);
    vec3 l = vec3_norm(vec3_sub(light_pos, pos));
    vec3 n = get_normal(pos);
    float dif = clampf(vec3_dot(n, l), 0.0f, 1.0f);
    float d = ray_march(vec3_add(pos, vec3_mult(n, SURFACE_DIST)), l);
    if (d < vec3_mag(vec3_sub(light_pos, pos))) dif *= 0.1f;
    return dif;
}

int main(void)
{
    int width = 800, height = 600, channels = 4;
    bmp_t bmp = bmp_new(width, height, channels);
    
    vec2 res = {(float)width, (float)height}; 
    vec3 origin = {0.0f, 2.0f, -5.0f};

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            vec2 coord = {(float)x, (float)y};
            vec2 uv = vec2_div(vec2_sub(coord, vec2_mult(res, 0.5f)), res.y);
            
            vec3 dir = vec3_norm(vec3_new(uv.x, uv.y, 1.0f));
            float d = ray_march(origin, dir);
            vec3 pos = vec3_add(origin, vec3_mult(dir, d));
            float dif = get_light(pos); 

            vec4 color = {clmpf(0.1f + dif), clmpf(0.1f + dif), clmpf(0.1f + dif), 1.0f};
            uint8_t px[4] = {(uint8_t)(color.x * 255.0f), (uint8_t)(color.y * 255.0f), (uint8_t)(color.z * 255.0f), (uint8_t)(color.w * 255.0f)};
            memcpy(px_at(bmp, x, y), &px[0], bmp.channels);
        }
    }

    char* path = "output.png";
    char op[256];
    bmp_t img = bmp_flip_vertical(&bmp);
    bmp_write(path, &img);
    bmp_free(&bmp);
    bmp_free(&img);

#ifdef __APPLE__
    strcpy(op, "open ");
#else
    strcpy(op, "xdg-open ");
#endif
    strcat(op, path);
    system(op);
    return 0;
}
