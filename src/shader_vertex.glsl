#version 330 core

// Atributos de v�rtice recebidos como entrada ("in") pelo Vertex Shader.
// Veja a fun��o BuildTrianglesAndAddToVirtualScene() em "main.cpp".
layout (location = 0) in vec4 model_coefficients;
layout (location = 1) in vec4 normal_coefficients;
layout (location = 2) in vec2 texture_coefficients;

// Matrizes computadas no c�digo C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

uniform int object_id;
uniform vec3 light_pos;

// Atributos de v�rtice que ser�o gerados como sa�da ("out") pelo Vertex Shader.
// ** Estes ser�o interpolados pelo rasterizador! ** gerando, assim, valores
// para cada fragmento, os quais ser�o recebidos como entrada pelo Fragment
// Shader. Veja o arquivo "shader_fragment.glsl".
out vec4 position_world;
out vec4 position_model;
out vec4 normal;
out vec2 texcoords;

out vec3 gouraud_color;

void main()
{
    // A vari�vel gl_Position define a posi��o final de cada v�rtice
    // OBRIGATORIAMENTE em "normalized device coordinates" (NDC), onde cada
    // coeficiente estar� entre -1 e 1 ap�s divis�o por w.
    // Veja {+NDC2+}.
    //
    // O c�digo em "main.cpp" define os v�rtices dos modelos em coordenadas
    // locais de cada modelo (array model_coefficients). Abaixo, utilizamos
    // opera��es de modelagem, defini��o da c�mera, e proje��o, para computar
    // as coordenadas finais em NDC (vari�vel gl_Position). Ap�s a execu��o
    // deste Vertex Shader, a placa de v�deo (GPU) far� a divis�o por W. Veja
    // slides 41-67 e 69-86 do documento Aula_09_Projecoes.pdf.

    gl_Position = projection * view * model * model_coefficients;

    // Como as vari�veis acima  (tipo vec4) s�o vetores com 4 coeficientes,
    // tamb�m � poss�vel acessar e modificar cada coeficiente de maneira
    // independente. Esses s�o indexados pelos nomes x, y, z, e w (nessa
    // ordem, isto �, 'x' � o primeiro coeficiente, 'y' � o segundo, ...):
    //
    //     gl_Position.x = model_coefficients.x;
    //     gl_Position.y = model_coefficients.y;
    //     gl_Position.z = model_coefficients.z;
    //     gl_Position.w = model_coefficients.w;
    //

    // Agora definimos outros atributos dos v�rtices que ser�o interpolados pelo
    // rasterizador para gerar atributos �nicos para cada fragmento gerado.

    // Posi��o do v�rtice atual no sistema de coordenadas global (World).
    position_world = model * model_coefficients;

    // Posi��o do v�rtice atual no sistema de coordenadas local do modelo.
    position_model = model_coefficients;

    // Normal do v�rtice atual no sistema de coordenadas global (World).
    // Veja slides 123-151 do documento Aula_07_Transformacoes_Geometricas_3D.pdf.
    normal = inverse(transpose(model)) * normal_coefficients;
    normal.w = 0.0;

    // Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
    texcoords = texture_coefficients;

    // Definição identica as do shader-fragment, para criar o modelo de Gouraud para o COWBUNNY
    vec4 p = position_world;    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;
    vec4 n = normalize(normal);
    vec4 l = normalize(vec4(0.2,1.0,0.2,0.0));
    vec4 v = normalize(camera_position - p);
    vec4 r = -l + 2*n*dot(n,l);
    vec3 Kd = vec3(0.6, 0.6, 0.6);  // Refletância difusa
    vec3 Ks = vec3(0.8, 0.8, 0.8);; // Refletância especular
    vec3 Ka = vec3(0.1,0.1,0.1);    // Refletância ambiente
    float q = 8;                    // Expoente especular para o modelo de iluminação de Phong

    vec3 I = vec3(1.0,1.0,1.0);                 // Espectro da fonte de iluminação
    vec3 Ia = vec3(0.2, 0.2, 0.2);              // o espectro da luz ambiente
    float simple_lambert = max(0,dot(n,l));     // Equação de Iluminação simples
    vec3 lambert_diffuse_term = Kd*I*max(0, dot(n,l)); // Termo difuso utilizando a lei dos cossenos de Lambert
    vec3 ambient_term =  Ka*Ia;                 // Termo ambiente
    vec3 phong_specular_term  = Ks*I*pow(max(0, dot(r,v)), q);     // Termo especular utilizando o modelo de iluminação de Phong
    gouraud_color = lambert_diffuse_term + ambient_term + phong_specular_term;

    // float lambert = max(dot(n, l), 0.0);
    // vec3 diffuse = lambert * vec3(1.0f,1.0f,1.0f);

    // float I = 4.0;
    // float q = 16.0;
    // vec3 v = vec3(normalize((inverse(view) * vec4(0.0f,0.0f,0.0f,1.0f)) - position_world));
	// vec3 r = (l*-1) + (2*n)*(dot(n,l));
    // float phong = pow(max(dot(v, -r), 0.0), q);
    // vec3 specular = I * phong * vec3(1.0f,1.0f,1.0f);

}

