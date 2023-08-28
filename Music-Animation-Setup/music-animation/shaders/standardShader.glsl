
#ifdef VERTEX_SHADER
// ------------------------------------------------------//
// ----------------- VERTEX SHADER ----------------------//
// ------------------------------------------------------//

attribute vec3 a_normal;
attribute vec2 a_texcoord;
uniform mat3 u_matrixInvTransM;
varying vec3 v_normal;
varying vec2 v_texcoord;

attribute vec3 a_position; // the position of each vertex
uniform mat4 u_matrixM; // the model matrix of this object
uniform mat4 u_matrixV; // the view matrix of the camera
uniform mat4 u_matrixP; // the projection matrix of the camera

uniform vec3 u_lightWorldPosition;
uniform mat4 u_world;
varying vec3 v_surfaceToLight;

uniform vec3 u_viewWorldPosition;
varying vec3 v_surfaceToView;

void main() {
    // TODO: Complete Vertex Shader
    v_normal = normalize(u_matrixInvTransM * a_normal); // set normal data for fragment shader
    v_texcoord = a_texcoord;


    gl_Position = u_matrixP * u_matrixV * u_matrixM * vec4 (a_position, 1);

    // compute world position of surface
    vec3 surfaceWorldPosition = (u_world * vec4 (a_position, 1)).xyz;
    v_surfaceToLight = u_lightWorldPosition - surfaceWorldPosition;

    v_surfaceToView = u_viewWorldPosition - surfaceWorldPosition;
}

#endif
#ifdef FRAGMENT_SHADER
// ------------------------------------------------------//
// ----------------- Fragment SHADER --------------------//
// ------------------------------------------------------//

precision highp float; //float precision settings
uniform vec3 u_tint;            // the tint color of this object

uniform vec3 u_directionalLight;// directional light in world space
uniform vec3 u_directionalColor;// light color
uniform vec3 u_ambientColor;    // intensity of ambient light
varying vec3 v_normal;  // normal from the vertex shader
varying vec2 v_texcoord;
uniform sampler2D u_mainTex;

varying vec3 v_surfaceToLight;
varying vec3 v_surfaceToView;

void main(void){
    vec3 normal = normalize(v_normal);
    float diffuse = max(0.0, dot(normal, -u_directionalLight));
    vec3 diffuseColor = u_directionalColor * diffuse;
    vec3 ambientDiffuse = u_ambientColor + diffuseColor;
    ambientDiffuse = clamp(ambientDiffuse, vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0));

    //TODO: Add texture color sampling
    //TODO: Blend texture color with tint color for new baseColor
    vec3 textureColor = texture2D(u_mainTex, v_texcoord).rgb;
    vec3 baseColor = textureColor * u_tint;
    vec3 finalColor = ambientDiffuse * baseColor; // apply lighting to color

    vec3 surfaceToLightDirection = normalize(v_surfaceToLight);
    float light = dot(normal, surfaceToLightDirection);

    vec3 surfaceToViewDirection = normalize(v_surfaceToView);
    vec3 halfvector = normalize(surfaceToLightDirection + surfaceToViewDirection);

    float specular = dot(normal, halfvector);
    gl_FragColor = vec4(finalColor, 1);

    //gl_FragColor = vec4(u_tint, 1);
    
    gl_FragColor.rgb += specular;
}

#endif
