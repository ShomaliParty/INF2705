#version 460

layout(triangles) in;
layout(triangle_strip, max_vertices = 4) out;


in Attribs {
    vec4 couleur;
} AttribsIn[];

out Attribs {
    vec4 couleur;
} AttribsOut;



void main() 
{
    vec4 arete1 = gl_in[1].gl_Position - gl_in[0].gl_Position;
    vec4 arete2 = gl_in[2].gl_Position - gl_in[1].gl_Position;
    vec4 normale;

    normale[0] = arete1[1] * arete2[2] - arete1[2] * arete2[1]; 
    normale[1] = arete1[2] * arete2[0] - arete1[0] * arete2[2]; 
    normale[2] = arete1[0] * arete2[1] - arete1[1] * arete2[0]; 

    EmitVertex();

    EndPrimitive();

}
