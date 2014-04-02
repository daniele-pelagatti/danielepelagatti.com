THREE.PlaneShader = {
	uniforms: THREE.UniformsUtils.merge([
		THREE.UniformsLib["fog"],
		THREE.UniformsLib["common"],
		{
		"wrapRGB": {type: "v3",value: new THREE.Vector3(1, 1, 1)},
		"emissive": {type: "c",value: new THREE.Color(0x000000)},
		"ambient": {type: "c",value: new THREE.Color(0xffffff)},
		"opacity" : { type: "f", value: -1 },
		"color_opacity" : { type: "f", value: -1 },
		"diffuse" : { type: "v3", value: new THREE.Vector3( 0, 0, 0 ) },
		}
	]),
	vertexShader: [
		THREE.ShaderChunk["map_pars_vertex"],
		'void main() {',
			THREE.ShaderChunk["map_vertex"],
			THREE.ShaderChunk["default_vertex"],
			THREE.ShaderChunk["worldpos_vertex"],
		'}'].join("\n"),
	fragmentShader: [
		'uniform float opacity;',
		THREE.ShaderChunk["map_pars_fragment"],
		'uniform float color_opacity;',
		'uniform vec3 diffuse;',
		'void main() {',
		'	vec3 white = vec3( 1.0 );',
		'	gl_FragColor = vec4( mix(  white, diffuse , color_opacity * opacity )  , opacity );',
		'	// gl_FragColor = vec4( diffuse  , opacity );',
		'	vec4 texelColor = texture2D( map, vUv );',
		'	gl_FragColor.xyz *= texelColor.xyz;',
		'	// #THREE.ShaderChunk["alphatest_fragment"]',
		'	// #THREE.ShaderChunk["linear_to_gamma_fragment"]',
		'	// #THREE.ShaderChunk["fog_fragment"]',
		'}'].join("\n")
};
