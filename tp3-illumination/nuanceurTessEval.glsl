#version 410

layout(quads) in;


in Attribs {
    vec4 couleur;
    vec3 normale, lumiDir[3], obsVec;
    vec2 texCoord;
} AttribsIn[];

out Attribs {
    vec4 couleur;
    vec3 normale, lumiDir[3], obsVec;
    vec2 texCoord;
} AttribsOut;


vec4 interpole(vec4 v0, vec4 v1, vec4 v2, vec4 v3) {
    vec4 v01 = mix( v0, v1, gl_TessCoord.x );
    vec4 v32 = mix( v3, v2, gl_TessCoord.x );
    return mix( v01, v32, gl_TessCoord.y );
}

void main(void) {

    vec4 p0 = gl_in[0].gl_Position;
    vec4 p1 = gl_in[1].gl_Position;
    vec4 p2 = gl_in[2].gl_Position;
    vec4 p3 = gl_in[3].gl_Position;
    gl_Position = interpole(p0, p1, p3, p2);
    AttribsOut.couleur = interpole( AttribsIn[0].couleur, AttribsIn[1].couleur, AttribsIn[2].couleur, AttribsIn[3].couleur );

   
    for (int i = 0; i < 3; i++) {
        AttribsOut.lumiDir[i] = AttribsIn[0].lumiDir[i];
    }
    
    AttribsOut.couleur = AttribsIn[0].couleur;
    AttribsOut.normale = AttribsIn[0].normale;
    AttribsOut.texCoord = AttribsIn[0].texCoord;
    AttribsOut.obsVec = AttribsIn[0].obsVec;
 
}
