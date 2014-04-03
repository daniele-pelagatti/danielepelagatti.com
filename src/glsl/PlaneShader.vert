//#UNIFORMLIB THREE.UniformsLib["common"]
//#UNIFORMLIB THREE.UniformsLib["fog"]
//#UNIFORM "ambient": {type: "c",value: new THREE.Color(0xffffff)}
//#UNIFORM "emissive": {type: "c",value: new THREE.Color(0x000000)}
//#UNIFORM "wrapRGB": {type: "v3",value: new THREE.Vector3(1, 1, 1)}


//#THREE.ShaderChunk["map_pars_vertex"]

// varying float vFresnel;
varying vec3 vTransformedNormal;
varying vec4 vPosition;

void main() {
	//#THREE.ShaderChunk["map_vertex"]
	//#THREE.ShaderChunk["default_vertex"]
	//#THREE.ShaderChunk[ "defaultnormal_vertex" ]


	vPosition = mvPosition;
	vTransformedNormal = transformedNormal;


	//#THREE.ShaderChunk["worldpos_vertex"]

}
