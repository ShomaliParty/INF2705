layout(triangles) in;
layout(triangle_strip, max vertices = 3) out;


void produitvectoriel(glm::vec3 vecA, glm::vec3 vecB, glm::vec3 resultat) 
  
{ 
    resultat[0] = vecA[1] * vecB[2] - vecA[2] * vecB[1]; 
    resultat[1] = vecA[2] * vecB[0] - vecA[0] * vecB[2]; 
    resultat[2] = vecA[0] * vecB[1] - vecA[1] * vecB[0]; 
} 

void main(void) 
{
    glm::vec3 arete1 = gl_in[1].gl_Position - gl_in[0].gl_Position;
    glm::vec3 arete2 = gl_in[2].gl_Position - gl_in[1].gl_Position;
    glm::vec3 normale;

    produitVectoriel(arete1, arete2, normale);

    EmitVertex();

    EndPrimitive();

}
