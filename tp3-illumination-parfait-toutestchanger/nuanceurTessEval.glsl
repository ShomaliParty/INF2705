#version 410

layout (std140) uniform varsUnif
{
    // partie 1: illumination
    int typeIllumination;     // 0:Gouraud, 1:Phong
    bool utiliseBlinn;        // indique si on veut utiliser modèle spéculaire de Blinn ou Phong
    bool afficheNormales;     // indique si on utilise les normales comme couleurs (utile pour le débogage)
    // partie 2: texture
    int iTexCoul;             // numéro de la texture de couleurs appliquée
    int iTexNorm;             // numéro de la texture de normales appliquée
};

layout (std140) uniform LightSourceParameters
{
    vec4 ambient[3];
    vec4 diffuse[3];
    vec4 specular[3];
    vec4 position[3];      // dans le repère du monde
} LightSource;

layout (std140) uniform MaterialParameters
{
    vec4 emission;
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    float shininess;
} FrontMaterial;

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;
uniform mat3 matrNormale;

layout(quads) in;


in Attribs {
    vec3 normale;
    vec2 texCoord;
} AttribsIn[];

out Attribs {
    vec4 couleur;
    vec3 normale, lumiDir[3], obsVec;
    vec2 texCoord;
} AttribsOut;


vec4 interpole(vec4 v0, vec4 v1, vec4 v2, vec4 v3){
    // return (gl_TessCoord.x * v0 + gl_TessCoord.y * v1 + gl_TessCoord.z * v2);
    vec4 v01 = mix( v0, v1, gl_TessCoord.x );
    vec4 v32 = mix( v3, v2, gl_TessCoord.x );
    return mix( v01, v32, gl_TessCoord.y );
}

vec4 calculerReflexion( in int j, in vec3 L, in vec3 N, in vec3 O ) // pour la lumière j
{
    vec4 coul = FrontMaterial.emission;

    coul += FrontMaterial.ambient * LightSource.ambient[j];

    float NdotL = max( 0.0, dot( N, L ) );
    if ( NdotL > 0.0 )
    {

        coul += LightSource.diffuse[j] * FrontMaterial.diffuse * NdotL;

        float spec = max( 0.0, ( utiliseBlinn ) ?
                          dot( normalize( L + O ), N ) : // dot( B, N )
                          dot( reflect( -L, N ), O ) ); // dot( R, O )
        if ( spec > 0 ) coul += LightSource.specular[j] * FrontMaterial.specular * pow( spec, FrontMaterial.shininess );
    }

    return(coul);
}

void main(void) {

    vec4 p0 = gl_in[0].gl_Position;
    vec4 p1 = gl_in[1].gl_Position;
    vec4 p2 = gl_in[2].gl_Position;
    vec4 p3 = gl_in[3].gl_Position;
    gl_Position = interpole(p0, p1, p3, p2);

    vec3 normale = matrNormale * AttribsIn[0].normale;
    AttribsOut.normale = normale;

    vec3 L[3];

    // vecteur de la direction de la lumière
    vec3 pos = (matrVisu * matrModel * gl_Position).xyz;
    for (int i = 0; i < 3; i++) {
        AttribsOut.lumiDir[i] = L[i] = (matrVisu * LightSource.position[i]).xyz - pos;
        L[i] = normalize(L[i]);
    }


     AttribsOut.couleur = vec4(0.0, 0.0, 0.0, 0.0);

    if(typeIllumination == 0) {

        vec4 c1, c2, c3, c4;
        vec3 N = normalize( normale ); // vecteur normal

        vec3 O = vec3( 0.0, 0.0, 1.0 );  // position de l'observateur

        int j = 0;
        c1 = calculerReflexion( j, L[j], N, O );
        c2 = calculerReflexion( j, L[j], N, O );
        c3 = calculerReflexion( j, L[j], N, O );
        c4 = calculerReflexion( j, L[j], N, O );

        for (j = 1; j < 3; j++) {
           c1 += calculerReflexion( j, L[j], N, O );
           c2 += calculerReflexion( j, L[j], N, O );
           c3 += calculerReflexion( j, L[j], N, O );
           c4 += calculerReflexion( j, L[j], N, O );

        }
        
        AttribsOut.couleur = interpole( c1, c2, c3, c4 );

    }


   
    for (int i = 0; i < 3; i++) {
        AttribsOut.lumiDir[i] = L[i];
    }
    
    AttribsOut.texCoord = AttribsIn[0].texCoord;
    AttribsOut.obsVec = vec3( 0.0, 0.0, 1.0 );
 
}