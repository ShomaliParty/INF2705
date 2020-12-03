#version 410

uniform vec3 bDim, posPuits;
uniform float temps, dt, tempsDeVieMax, gravite;

layout(location=6) in vec3 Vertex;
layout(location=7) in vec4 Color;
layout(location=8) in vec3 vitesse;
layout(location=9) in float tempsDeVieRestant;

out vec3 VertexMod;
out vec4 ColorMod;
out vec3 vitesseMod;
out float tempsDeVieRestantMod;

uint randhash( uint seed ) // entre  0 et UINT_MAX
{
    uint i=(seed^12345391u)*2654435769u;
    i ^= (i<<6u)^(i>>26u);
    i *= 2654435769u;
    i += (i<<5u)^(i>>12u);
    return i;
}
float myrandom( uint seed ) // entre  0 et 1
{
    const float UINT_MAX = 4294967295.0;
    return float(randhash(seed)) / UINT_MAX;
}

void main( void )
{
    if ( tempsDeVieRestant <= 0.0 )
    {
        // se préparer à produire une valeur un peu aléatoire
        uint seed = uint(temps * 1000.0) + uint(gl_VertexID);
        // faire renaitre la particule au puits
        VertexMod = posPuits;
        // assigner un vitesse aléatoire
        vitesseMod = vec3( mix( -25.0, 25.0, myrandom(seed++) ),   // entre -25 et 25
                           mix( -25.0, 25.0, myrandom(seed++) ),   // entre -25 et 25
                           mix(  25.0, 50.0, myrandom(seed++) ) ); // entre  25 et 50
        //vitesseMod = vec3( -20.0, 0., 50.0 );

        // nouveau temps de vie aléatoire
        const float TEMPSMIN = 0.0;
        // tempsDeVieRestantMod = 0.0; // à modifier pour une valeur aléatoire entre 0 et tempsDeVieMax secondes
        tempsDeVieRestantMod =  mix( TEMPSMIN, tempsDeVieMax, myrandom(seed++) ) ; // entre 0.2 et 0.9

        // couleur aléatoire par interpolation linéaire entre COULMIN et COULMAX
        const float COULMIN = 0.2; // valeur minimale d'une composante de couleur lorsque la particule (re)naît
        const float COULMAX = 0.9; // valeur maximale d'une composante de couleur lorsque la particule (re)naît
        //ColorMod = ... // composantes de couleur aléatoires
        ColorMod = vec4( mix( COULMIN, COULMAX, myrandom(seed++) ),   // entre 0.2 et 0.9
                         mix( COULMIN, COULMAX, myrandom(seed++) ),   // entre 0.2 et 0.9
                         mix( COULMIN, COULMAX, myrandom(seed++) ),   // entre 0.2 et 0.9
                         1); // Opaciter pleine au depart
    }
    else
    {
        // avancer la particule (méthode de Euler)
        VertexMod = Vertex + dt * vitesse; // modifier ...
        vitesseMod = vitesse;

        // diminuer son temps de vie
        tempsDeVieRestantMod = tempsDeVieRestant - dt; // modifier ...

        // garder la couleur courante
        ColorMod = Color;

        // collision avec la demi-sphère ?
        // ...
        vec3 posSphUnitaire = VertexMod / bDim;
        vec3 vitSphUnitaire = vitesseMod * bDim;
        // On verifie si la particule est a l'interieur de la bulle
        float dist = length( posSphUnitaire );
        if ( dist >= 1.0 ) // particule a l'exterieur
        {
            VertexMod = ( 2.0 - dist ) * VertexMod;
            vec3 N = posSphUnitaire / dist;
            vec3 visReflechieSphUnitaire = reflect( vitSphUnitaire, N );
            vitesseMod = visReflechieSphUnitaire / bDim;
            vitesseMod = vitesseMod / 2.0;
        }

        // collision avec le sol ?
        // hauteur minimale à laquelle une collision avec le plancher survient
        const float hauteurPlancher = 3.0;
        // ...
        if ( VertexMod.z <= hauteurPlancher ) { 
            VertexMod.z = hauteurPlancher;
            vitesseMod.z = - vitesseMod.z;
            vitesseMod = vitesseMod / 2.0;
        }

        // appliquer la gravité
        // ...
        vitesseMod.z = vitesseMod.z - gravite * dt;
    }

    // Mettre un test bidon afin que l'optimisation du compilateur n'élimine pas les attributs dt, gravite, tempsDeVieMax posPuits et bDim.
    // Vous ENLEVEREZ cet énoncé inutile!
    if ( dt+bDim.x+gravite+tempsDeVieMax+posPuits.x < -100000 ) tempsDeVieRestantMod += .000001;
}
