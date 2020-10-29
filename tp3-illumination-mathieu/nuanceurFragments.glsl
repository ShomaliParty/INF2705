#version 410

// Définition des paramètres des sources de lumière
layout (std140) uniform LightSourceParameters
{
    vec4 ambient[3];
    vec4 diffuse[3];
    vec4 specular[3];
    vec4 position[3];      // dans le repère du monde
} LightSource;

// Définition des paramètres des matériaux
layout (std140) uniform MaterialParameters
{
    vec4 emission;
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    float shininess;
} FrontMaterial;

// Définition des paramètres globaux du modèle de lumière
layout (std140) uniform LightModelParameters
{
    vec4 ambient;       // couleur ambiante globale
    bool twoSide;       // éclairage sur les deux côtés ou un seul?
} LightModel;

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

uniform sampler2D laTextureCoul;
uniform sampler2D laTextureNorm;

/////////////////////////////////////////////////////////////////

in Attribs {
    vec4 couleur;
    vec3 normale, lumiDir[3], obsVec;
} AttribsIn;

out vec4 FragColor;

float attenuation = 1.0;
vec4 calculerReflexion( in int j, in vec3 L, in vec3 N, in vec3 O ) // pour la lumière j
{
    vec4 grisUniforme = vec4(0.7,0.7,0.7,1.0);
    return( grisUniforme );
}

void main( void )
{
    // ...

    // assigner la couleur finale
    // FragColor = 0.01*AttribsIn.couleur + vec4( 0.5, 0.5, 0.5, 1.0 ); // gris moche!
    FragColor = clamp( AttribsIn.couleur, 0.0, 1.0 );

    int j = 0;
    // vec4 coul = calculerReflexion( j, L, N, O );
    // ...

    //if ( afficheNormales ) FragColor = clamp( vec4( (N+1)/2, AttribsIn.couleur.a ), 0.0, 1.0 );
}
