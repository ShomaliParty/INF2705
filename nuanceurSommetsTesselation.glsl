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

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;
uniform mat3 matrNormale;

/////////////////////////////////////////////////////////////////

layout(location=2) in vec3 Normal;
layout(location=3) in vec4 Color;
layout(location=8) in vec4 TexCoord;

out Attribs {
    vec3 normale;
    vec2 texCoord;
} AttribsOut;

uniform float temps;

void main( void )
{

    // calcul de la normale
    vec3 normale = matrNormale * Normal;
    AttribsOut.normale = normale;

    // calcul de la position du sommet dans le repère de la caméra
    // vec3 pos = (matrVisu * matrModel * gl_position).xyz;


    // A partir d'ici, c'est uniquement Gouraud, le code plus haut est utiliser
    // dans le cas des deux modele, Gouraud et Phong.

    // Application de la translation.
    vec2 translation = vec2(- 0.1 * temps, 0.0);
    // Application des textures.
    AttribsOut.texCoord = TexCoord.st + translation;
}
