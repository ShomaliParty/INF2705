#version 410

////////////////////////////////////////////////////////////////////////////////

// Définition des paramètres des sources de lumière
layout (std140) uniform LightSourceParameters
{
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    vec4 position;      // dans le repère du monde
    vec3 spotDirection; // dans le repère du monde
    float spotExponent;
    float spotAngleOuverture; // ([0.0,90.0] ou 180.0)
    float constantAttenuation;
    float linearAttenuation;
    float quadraticAttenuation;
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
    vec4 ambient;       // couleur ambiante
    bool localViewer;   // observateur local ou à l'infini?
    bool twoSide;       // éclairage sur les deux côtés ou un seul?
} LightModel;

////////////////////////////////////////////////////////////////////////////////

uniform int illumination; // on veut calculer l'illumination ?

const bool utiliseBlinn = true;

in Attribs {
    vec4 couleur;
    vec3 lumiDir;
    vec3 obsVec;
    vec3 normale;
} AttribsIn;

out vec4 FragColor;

float attenuation = 1.0;
vec4 calculerReflexion( in vec3 L, in vec3 N, in vec3 O )
{
    vec4 coul = vec4(0.0);

    // calcul de la composante ambiante pour la source de lumière
    coul += FrontMaterial.ambient * LightSource.ambient;

    // calcul de l'éclairage seulement si le produit scalaire est positif
    float NdotL = max( 0.0, dot( N, L ) );
    if ( NdotL > 0.0 )
    {
        // calcul de la composante diffuse
        // (dans cet exemple, on utilise plutôt la couleur de l'objet au lieu de FrontMaterial.diffuse)
        //coul += attenuation * FrontMaterial.diffuse * LightSource.diffuse * NdotL;
        coul += attenuation * AttribsIn.couleur * LightSource.diffuse * NdotL;

        // calcul de la composante spéculaire (Blinn ou Phong : spec = BdotN ou RdotO )
        float spec = max( 0.0, ( utiliseBlinn ) ?
                          dot( normalize( L + O ), N ) : // dot( B, N )
                          dot( reflect( -L, N ), O ) ); // dot( R, O )
        if ( spec > 0 ) coul += FrontMaterial.specular * LightSource.specular * pow( spec, FrontMaterial.shininess );
    }

    return( coul );
}

void main( void )
{
    // Ici, on normalise.
    vec3 lumiDir = normalize(AttribsIn.lumiDir);
    vec3 obsVec = normalize(AttribsIn.obsVec);
    vec3 normale = normalize( gl_FrontFacing ? AttribsIn.normale : -AttribsIn.normale );

    vec4 coul = calculerReflexion( lumiDir, normale, obsVec );

    // la couleur du fragment est la couleur interpolée
    // FragColor = AttribsIn.couleur;

    // Mettre un test bidon afin que l'optimisation du compilateur n'élimine la variable "illumination".
    // Vous ENLEVEREZ ce test inutile!
    // if ( illumination > 10000 ) FragColor.r += 0.001;

    // utiliser le .alpha de la couleur courante (essentiellement pour le miroir transparent)
    coul.a = AttribsIn.couleur.a;

    // assigner la couleur finale
    FragColor = clamp( coul, 0.0, 1.0 );

}
