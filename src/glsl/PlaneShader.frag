uniform float opacity;
//#THREE.ShaderChunk["map_pars_fragment"]
uniform sampler2D focused_map;
uniform float focus_balance;
// uniform sampler2D overlay_map;
uniform float ovelay_unfocused_alpha;
uniform vec3 diffuse;


void main() {

	vec3 white = vec3( 1.0 );
	gl_FragColor = vec4( mix( diffuse, white , clamp(ovelay_unfocused_alpha + focus_balance,0.0,1.0) )  , (1.0 - focus_balance) );

	#ifdef USE_MAP
		vec4 texelColor = texture2D( map, vUv );
		// vec4 focusedColor = texture2D( focused_map, vUv );
		// vec4 finalColor = mix(texelColor,focusedColor,focus_balance);

		// #ifdef GAMMA_INPUT
		// finalColor.xyz *= finalColor.xyz;
		// #endif

		gl_FragColor *= texelColor;
	#endif

	// overlay an image
	// vec4 overlay = texture2D( overlay_map , vUv );
	// vec3 mixed = mix( white, overlay.xyz, clamp(ovelay_unfocused_alpha + focus_balance,0.0,1.0) );
	// gl_FragColor.xyz *= ( mixed );



	//#THREE.ShaderChunk["alphatest_fragment"]
	//#THREE.ShaderChunk["linear_to_gamma_fragment"]
	//#THREE.ShaderChunk["fog_fragment"]
}
