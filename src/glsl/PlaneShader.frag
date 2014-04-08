uniform float opacity;
//#THREE.ShaderChunk["map_pars_fragment"]
uniform float color_opacity;
uniform float fresnelIntensity;
uniform vec3 fresnelColor;
uniform vec3 diffuse;
// varying float vFresnel;
varying vec3 vTransformedNormal;
varying vec4 vPosition;

void main() {

	vec3 white = vec3( 1.0 );

	// start with the "mouseover" color
	// make it disappear along with opacity
	gl_FragColor = vec4( mix(  white, diffuse , color_opacity * opacity )  , opacity );


	// multiply texture over "mouseover" color
	gl_FragColor.xyz *= texture2D( map, vUv ).xyz;


	//fresnel reflection
	#ifdef NO_FRESNEL 
		float flipNormal = 1.0;
	#else
		float flipNormal = -1.0 + ( 2.0 * float( gl_FrontFacing ) );
		vec3 transformedNormal = vTransformedNormal * flipNormal;
		float fresnelPow = 5.0 ;
		float f = 1.0 + dot( normalize( vPosition.xyz ) , normalize( transformedNormal.xyz ) ) ;
		float fresnel = clamp( pow( abs( f ) , fresnelPow ) , 0.0, 1.0 ) ;
		float fresnelFactor = fresnel * fresnelIntensity;
		gl_FragColor.xyz = mix( gl_FragColor.xyz, vec3(0.9,0.9,0.9), fresnelFactor );
	#endif



	// #THREE.ShaderChunk["alphatest_fragment"]
	//#THREE.ShaderChunk["linear_to_gamma_fragment"]
	// #THREE.ShaderChunk["fog_fragment"]
}
