#version 410

layout(points) in;
// layout(points, max_vertices = 1) out; // Points, avant
layout(triangle_strip, max_vertices = 4) out; // Triangle pour les panneau

uniform mat4 matrProj;

uniform int texnumero;
uniform float tempsDeVieMax;

in Attribs {
    vec4 couleur;
    float tempsDeVieRestant;
    //float sens; // du vol (partie 3)
    //float hauteur; // du vol (partie 3)
} AttribsIn[];

out Attribs {
    vec4 couleur;
    vec2 texCoord;
} AttribsOut;

// la hauteur minimale en-dessous de laquelle les lutins ne tournent plus (partie 3)
const float hauteurInerte = 8.0;

void main()
{
    // ******** AVANT ******** // 
    // // assigner la position du point
    // gl_Position = matrProj * gl_in[0].gl_Position;

    // // assigner la taille des points (en pixels)
    // gl_PointSize = gl_in[0].gl_PointSize;

    // // assigner la couleur courante
    // AttribsOut.couleur = AttribsIn[0].couleur;

    // EmitVertex();
    
    
    // ******** MAINTENANT ******** // 
    vec2 coins[4];
    coins[0] = vec2( -0.5,   0.5);
    coins[1] = vec2( -0.5,  -0.5);
    coins[2] = vec2(  0.5,   0.5);
    coins[3] = vec2(  0.5,  -0.5);

    for ( int i = 0; i < 4; i++ )
    {
        float fact = gl_in[0].gl_PointSize;

        vec2 decalage = coins[i];
        vec4 pos = vec4( gl_in[0].gl_Position.xy + fact * decalage, gl_in[0].gl_Position.zw );

        if ( texnumero == 1 ) {
            float dt = 3.0 * AttribsIn[0].tempsDeVieRestant;
            mat2 rotation = mat2(  cos(dt), sin(dt),
                                   -sin(dt), cos(dt)
                                   );
            coins[i] *= rotation;
        }

        gl_Position = matrProj * pos;

        AttribsOut.texCoord = coins[i] + vec2( 0.5, 0.5 );

        AttribsOut.couleur = AttribsIn[0].couleur;
        if ( texnumero == 2 ) {
            const float nlutins = 16.0;
            int num = int( mod( 18.0 * AttribsIn[0].tempsDeVieRestant, nlutins ) );
            AttribsOut.texCoord.x = ( AttribsOut.texCoord.x + num ) / nlutins;
        }

        
            
        EmitVertex();
    }
}
