uniform float opacity;
//#THREE.ShaderChunk["map_pars_fragment"]
uniform float color_opacity;
uniform vec3 diffuse;


void main() {

	vec3 white = vec3( 1.0 );
	gl_FragColor = vec4( mix(  white, diffuse , color_opacity * opacity )  , opacity );
	// gl_FragColor = vec4( diffuse  , opacity );


	vec4 texelColor = texture2D( map, vUv );
	gl_FragColor.xyz *= texelColor.xyz;

	// #THREE.ShaderChunk["alphatest_fragment"]
	// #THREE.ShaderChunk["linear_to_gamma_fragment"]
	// #THREE.ShaderChunk["fog_fragment"]
}
