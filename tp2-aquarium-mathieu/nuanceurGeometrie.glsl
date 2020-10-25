#version 460

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;


in Attribs {
    vec4 couleur;
} AttribsIn[];

out Attribs {
    vec4 couleur;
    vec3 lumiDir;
    vec3 obsVec;
    vec3 normale;
} AttribsOut;



void main() 
{
    vec3 lumiDir = vec3( 0, 0, 1 );
    vec3 obsVec = vec3( 0, 0, 1 );
    vec3 arete1 = vec3(gl_in[1].gl_Position - gl_in[0].gl_Position);
    vec3 arete2 = vec3(gl_in[2].gl_Position - gl_in[0].gl_Position);
    vec3 normale;
    // normale[0] = arete1[1] * arete2[2] - arete1[2] * arete2[1]; 
    // normale[1] = arete1[2] * arete2[0] - arete1[0] * arete2[2]; 
    // normale[2] = arete1[0] * arete2[1] - arete1[1] * arete2[0]; 
    // normale = normalize( normale );
    // EmitVertex();

    normale = cross(arete1, arete2);
    for ( int i = 0 ; i < gl_in.length() ; ++i )
    {
        AttribsOut.lumiDir = lumiDir;
        AttribsOut.obsVec = obsVec;
        gl_Position = gl_in[i].gl_Position;
        AttribsOut.couleur = AttribsIn[i].couleur;
        AttribsOut.normale = normale;
        EmitVertex();
    }

    EndPrimitive();

}
