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
    vec2 texCoord;
} AttribsIn;

out vec4 FragColor;

float attenuation = 1.0;
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

vec3 modifierNormale( in vec3 N ) {
    // Application de la texture de relief.
    vec3 coulText2 = texture(laTextureNorm, AttribsIn.texCoord).rgb;
    vec3 dN = normalize((coulText2 - 0.5) * 2.0);
    // N = normalize(N);
    return normalize(N + dN);
}

void main( void )
{
    vec4 coulText = texture(laTextureCoul, AttribsIn.texCoord);
    vec4 couleurFinal;
    if(typeIllumination == 1) { // Phong
        vec4 coul;
        // ...
        // couleur du sommet
        if(typeIllumination == 1) {

            vec3 L[3];
            vec3 N; // vecteur normal
            N = AttribsIn.normale;
            N = normalize(AttribsIn.normale);
            if(iTexNorm != 0) N = modifierNormale(N);
            // else N = normalize(N);
            vec3 O = vec3( 0.0, 0.0, 1.0 );  // position de l'observateur

            int j = 0;
            L[j] = normalize(AttribsIn.lumiDir[j]);
            coul = calculerReflexion( j, L[j], N, O );
            for (j = 1; j < 3; j++) {
                L[j] = normalize(AttribsIn.lumiDir[j]);
                coul += calculerReflexion( j, L[j], N, O );
            }
        }
        couleurFinal = clamp( coul, 0.0, 1.0 );
    }
    else {  // Gouraud
        couleurFinal = clamp( AttribsIn.couleur, 0.0, 1.0 );    
    }
    
    FragColor = couleurFinal;
    if(iTexCoul != 0) {
        FragColor *= coulText;
        if(length(coulText.rgb) < 0.5) discard;
    }
}
