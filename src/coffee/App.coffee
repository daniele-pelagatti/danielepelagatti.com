class App

	CONTAINER_X              : 200;
	SCREEN_WIDTH             : window.innerWidth - @CONTAINER_X;
	SCREEN_HEIGHT            : window.innerHeight;
	FLOOR                    : -50;
	TRANSITION_DURATION      :  0.5;
	PAGE_SCALE_MULTIPLIER    : 0.1;
	SCENE_SCALE_MULTIPLIER   : 100;
	CSS3D_SCALE_MULTIPLIER   : 1;
	
	container                : null;
	# stats                  : null;
	
	camera                   : null;
	scene                    : null;
	css3DScene               : null;
	webglRenderer            : null;
	css3dRenderer            : null;
	
	mouseX                   : 0;
	mouseY                   : 0;
	pickMouseX               : 0;
	pickMouseY               : 0;
	
	windowHalfX              : @SCREEN_WIDTH / 2;
	windowHalfY              : @SCREEN_HEIGHT / 2;
	
	has_gl                   : false;
	
	projector                : null;
	raycaster                : null;
	
	overObject               : null;
	excludeFromPicking       : ["scene_baked_pPlane1"]
	
	initialObjectsProperties : {};
	clickedObject            : null;
	clickedObjectWPosition   : null;
	clickedObjectWRotation   : null;
	clickedObjectWScale      : null;
	isFocused                : false;
	
	pageLanguage             : window.PAGE_LANG;
	pagePermalink            : window.PAGE_PERMALINK;
	pageDepth                : window.PAGE_DEPTH;
	pageBase                 : window.PAGE_BASE;
	pageId                   : "";
	
	config                   : []
	allLanguagesConfig       : []
	thisPageConfig           : null
	
	
	page3DObjects            : {}
	doPicking                : true
	currentHistoryState      : {}
	cameraLookAt             : new THREE.Vector3(-50,-300,0)
	
	htmlMain                 : null
	delayID                  : -1

	constructor:->

		isIE11 = !!window.MSInputMethodContext;

		if @checkWebGL() && window.navigator.userAgent.indexOf("MSIE ") == -1 && !isIE11
			@htmlMain = $("main")
			# @htmlMain.css
			# 	opacity : 0
			# 	display : "none"
			@htmlMain.remove();
			$("body").css("overflow-y","hidden");
			$.ajax(@pageBase+"config.json",
				success : @onConfigLoaded
				error : @onConfigError
			)
		else
			# we cannot continue, no webgl support

	checkWebGL:->
		ua = navigator.userAgent.toLowerCase()
		isStockAndroid = /android/.test(ua) and !/chrome/.test(ua)
		try
			return !!window.WebGLRenderingContext && !!document.createElement('canvas').getContext('experimental-webgl') and !isStockAndroid
		catch
			return false


	onConfigLoaded:( data, textStatus, jqXHR  )=>
		@container = $( '.javascriptContent' );

		@CONTAINER_X   = @container.position().left;
		@SCREEN_WIDTH  = window.innerWidth - @CONTAINER_X;
		@SCREEN_HEIGHT = window.innerHeight;
		@windowHalfX   = @SCREEN_WIDTH / 2;
		@windowHalfY   = @SCREEN_HEIGHT / 2;


		@allLanguagesConfig = data;
		# @pageLanguage = document.URL.split("/")[3] || "en"
		# @pagePermalink = document.URL.split("/")[4] || ""
		@config = data[@pageLanguage]
		if !@config?
			throw "Cannot find config for this language"

		# for configItem in @config
		# 	if configItem.link == "ciao"
		# 		@thisPageConfig = configItem;
		# 		break;

		@init();
		@animate();

		
		# link overrides
		$(".projectsMenu").find("a").mouseover(@onMenuLinkOver)
		$(".projectsMenu").find("a").mouseout(@onMenuLinkOut)
		$(".projectsMenu").find("a").click(@onMenuLinkClick)
		$(".close-page").click(@onCloseClick)
		$(window).bind("popstate",@onPopStateChange);
		null

	onCloseClick:=>
		@unfocus()

	onPopStateChange:(event)=>
		return if !event.originalEvent.state?;

		newPath = event.originalEvent.state.path;

		for page in @config
			if page.link == newPath
				@pageId = page.meta.id
				@thisPageConfig = page
				break

		@pageLanguage = @thisPageConfig.lang
		@pagePermalink = @thisPageConfig.meta.permalink
		@pageDepth = @thisPageConfig.depth
		@pageBase = @thisPageConfig.base;


		document.title = "Daniele Pelagatti - "+@thisPageConfig.meta.title

		obj3D =  @page3DObjects[newPath];

		if @isFocused
			if @clickedObject != obj3D

				@doPicking = false

				# make focused object retract
				@overObject = null;
				@handleFocus()

				if @delayID != -1
					clearTimeout(@delayID)

				# delay new plane in focus
				@delayID = _.delay ()=> 
					@overObject = obj3D;
					@isFocused = false;				
					@handleFocus()
					@doPicking = true;
				,(@TRANSITION_DURATION*1000)+100
				
			
		else
			@overObject = obj3D;
			@handleFocus()


		# change language change link on languages menu to go to the current page
		languageLinks = $(".languagesMenu").find("a");
		for languageLink in languageLinks

			languageConfig = @allLanguagesConfig[languageLink.id]

			for page in languageConfig
				if page.meta.id == @pageId
					# console.log("OK");

					$(languageLink).attr("href", @getRelativeLink(page.link) )#.split("/")
					# hrefArr[2] = page.link;
					# $(languageLink).attr( "href" , hrefArr.join("/") )


		#update selected project on the menu
		projectsLinks = $(".projectsMenu").find("a");
		for projectLink in projectsLinks
			if $(projectLink).attr("permalink") == @currentHistoryState
				$(projectLink).addClass("selected")
			else
				$(projectLink).removeClass("selected")

			$(projectLink).attr("href", @pageBase+@getRelativeLink( $(projectLink).attr("permalink") ).substr(1) )

		
		ga('send', 'pageview', @thisPageConfig.link);

		null

	onMenuLinkOver:(event)=>
		obj3D =  @page3DObjects[ $(event.currentTarget).attr("permalink") ];
		@doPicking = false;
		@handlePicking(obj3D)
		null

	onMenuLinkClick:(event)=>
		event.originalEvent.preventDefault();
		@handlePushState( $(event.currentTarget).attr("permalink") ) 

	on3DSceneMouseClick:(event)=>

		# @onMouseMove(event);

		if !@overObject?
			# required to unfocus ( click outside focused plane )
			@handleFocus();
			return;
		@handlePushState(@overObject.link)

	handlePushState:(path)=>
		stateObj = {path:path}

		if path != @currentHistoryState

			history.pushState(stateObj,"Title",@pageBase+path.substr(1))
			@currentHistoryState = path;


		@onPopStateChange 
			originalEvent:
				state: stateObj

	onMenuLinkOut:(event)=>
		@doPicking = true;
		null

	onConfigError:(jqXHR,textStatus,errorThrown )=>

	init:-> 
		
		@camera = new THREE.PerspectiveCamera( 75, @SCREEN_WIDTH / @SCREEN_HEIGHT, 1, 10000 );
		@camera.position.z = 300;

		@scene = new THREE.Scene();


		@css3DScene = new THREE.Scene();
		@css3DScene.scale.set(@CSS3D_SCALE_MULTIPLIER,@CSS3D_SCALE_MULTIPLIER,@CSS3D_SCALE_MULTIPLIER)
		@css3DScene.updateMatrix();
		# RENDERER

		try 
			@webglRenderer = new THREE.WebGLRenderer({antialias:true});
			@webglRenderer.setClearColor( 0xffffff );
			@webglRenderer.setSize( @SCREEN_WIDTH, @SCREEN_HEIGHT );
			@webglRenderer.domElement.style.position = "relative";
			$(@webglRenderer.domElement).addClass("threejs-container");
			@container.append( @webglRenderer.domElement );

			@has_gl = true;

		# @container.append("<div class='threejsMousePonter'></div>");

		@css3dRenderer = new THREE.CSS3DRenderer()
		@css3dRenderer.setClearColor( 0xffffff );
		@css3dRenderer.setSize( @SCREEN_WIDTH, @SCREEN_HEIGHT );
		@css3dRenderer.domElement.style.position = "absolute";
		@css3dRenderer.domElement.style.top = "0";
		@css3dRenderer.domElement.style.left = "0";
		$(@css3dRenderer.domElement).addClass("css3d-container");
		@container.append( @css3dRenderer.domElement );


		# STATS

		# @stats = new Stats();
		# @stats.domElement.style.position = 'absolute';
		# @stats.domElement.style.top = '0px';
		# @stats.domElement.style.zIndex = 100;
		# @container.append( @stats.domElement );

		@projector = new THREE.Projector();
		@raycaster = new THREE.Raycaster();

		loader = new THREE.SceneLoader();
		loader.load( @pageBase+"maya/data/scene2.json", @sceneLoadCallback );

		$(window).bind( 'resize', @onWindowResize );
		@container.bind( 'mousemove touchmove touchstart', @onMouseMove );
		@container.bind( 'click touchend', @on3DSceneMouseClick );
		@container.bind( "transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd" , @onWindowResize);

		@onWindowResize()

	

	
	setupCSS3DPage: ( pageObj, object, link )=>


		# pageObj = 
		pageObj.css
			opacity : 0
			display : "none"

		cssObj = new THREE.CSS3DObject( pageObj[0] );
		cssObj.rotation.order  = "ZYX";
		cssObj.position.set(object.position.x * @SCENE_SCALE_MULTIPLIER,object.position.y * @SCENE_SCALE_MULTIPLIER,object.position.z * @SCENE_SCALE_MULTIPLIER);


		cssObj.quaternion.set(object.quaternion.x,object.quaternion.y,object.quaternion.z,object.quaternion.w);
		
		rot2 = new THREE.Quaternion();
		rot2.setFromAxisAngle( new THREE.Vector3( 1, 0, 0 ), -Math.PI / 2 );

		cssObj.quaternion.multiply(rot2);

		cssObj.scale.set(object.scale.x * @PAGE_SCALE_MULTIPLIER,object.scale.y * @PAGE_SCALE_MULTIPLIER,object.scale.z * @PAGE_SCALE_MULTIPLIER);

		object.page = pageObj;
		object.cssObj = cssObj;

		@css3DScene.add( cssObj )

		# show page belonging to loaded page on browser
		linkArr = link.split("/");
		if linkArr[1] == @pageLanguage && linkArr[2] == @pagePermalink
			_.delay( =>
				@handlePushState(link);
			, 1000 );
			
		null; 


	showLoading:=>
		$(".javascriptContent").spin
			lines     : 8, # The number of lines to draw
			length    : 8, # The length of each line
			width     : 5, # The line thickness
			radius    : 11, # The radius of the inner circle
			corners   : 1, # Corner roundness (0..1)
			rotate    : 0, # The rotation offset
			direction : 1, # 1: clockwise, -1: counterclockwise
			color     : '#444', # #rgb or #rrggbb or array of colors
			speed     : 1.3, # Rounds per second
			trail     : 60, # Afterglow percentage
			shadow    : true, # Whether to render a shadow
			hwaccel   : true, # Whether to use hardware acceleration
			className : 'spinner', # The CSS class to assign to the spinner
			zIndex    : 2e9, # The z-index (defaults to 2000000000)
			top       : '47%', # Top position relative to parent in px
			left      : '47%' # Left position relative to parent in px	
	hideLoading:=>
		$(".javascriptContent").spin(false)		
	
	sceneLoadCallback: ( result )=> 

		$(".page-container").css
			display : "none"

		# Generate colors (as Chroma.js objects)
		@colors = paletteGenerator.generate result.scene.children.length, # Colors
			(color)-> # This function filters valid colors
				hcl = color.hcl();
				return 	hcl[0] >= 0 && hcl[0] <= 360 && 
						hcl[1] >= 0 && hcl[1] <= 0.9 && 
						hcl[2] >= 1 && hcl[2] <= 1.5;
			,
			false, # Using Force Vector instead of k-Means
			50 # Steps (quality)
		
		# Sort colors by differenciation first
		@colors = paletteGenerator.diffSort(@colors);
		objectIndex = 0;

		result.scene.traverse (object)=> 
				object.rotation.order  = "ZYX";
				if object.material && @excludeFromPicking.indexOf(object.name) == -1

					@initialObjectsProperties[object.name] = {}
					@initialObjectsProperties[object.name].position = object.position.clone();
					@initialObjectsProperties[object.name].quaternion = object.quaternion.clone();
					@initialObjectsProperties[object.name].scale = object.scale.clone();

					uniforms = THREE.UniformsUtils.clone(THREE.PlaneShader.uniforms)
					uniforms.focus_balance.value = 0;
					uniforms.ovelay_unfocused_alpha.value = 1;
					uniforms.opacity.value = 1;
					uniforms.diffuse.value.set( @colors[objectIndex].rgb[0] / 255 , @colors[objectIndex].rgb[1] /255 , @colors[objectIndex].rgb[2] /255 )
					uniforms.map.value = object.material.map
					uniforms.focused_map.value = THREE.ImageUtils.loadTexture(@pageBase+'maya/images/focused.jpg')
					uniforms.overlay_map.value = THREE.ImageUtils.loadTexture(@pageBase+'maya/images/overlay.png')

					defines = {}
					defines["USE_MAP"] = "";


					material = new THREE.ShaderMaterial
						uniforms: uniforms
						attributes: {}
						vertexShader: THREE.PlaneShader.vertexShader
						fragmentShader: THREE.PlaneShader.fragmentShader
						transparent: true
						lights : false
						fog : false
						shading: THREE.FlatShading
						defines : defines;

					object.material = material;

					object.material.side = THREE.DoubleSide;

					if @config[objectIndex]?

						@page3DObjects[@config[objectIndex].link] = object;

						link = object.link = @config[objectIndex].link;

						container = $("<div class='object3DContainer' permalink='"+link+"'></div>")

						if @config[objectIndex].meta.permalink == @pagePermalink
							# don't load ourselves
							# cont = $("<div></div>")
							# cont.append(@htmlMain[0])
							container.append(@htmlMain)

						@setupCSS3DPage( container , object, link )
						# $.ajax(@getRelativeLink(link),
						# 	success : ( data, textStatus, jqXHR  ) =>
						# 		@setupCSS3DPage(data,object,link)
						# 	error : (jqXHR,textStatus,errorThrown ) =>
						# 		console.error(textStatus);
						# )
					else
						@excludeFromPicking.push(object.name)


					objectIndex++


				object.updateMatrix();

				if object.geometry
					object.geometry.computeFaceNormals();
					object.geometry.computeVertexNormals();
					object.geometry.computeCentroids();
					object.geometry.computeTangents();
					object.geometry.computeBoundingBox();




		
			
		@scene = result.scene;
		@scene.position.set(0,-450,0)
		@css3DScene.position.set(0,-450,0)

		@scene.scale.set(@SCENE_SCALE_MULTIPLIER,@SCENE_SCALE_MULTIPLIER,@SCENE_SCALE_MULTIPLIER)
		@scene.updateMatrix();	
		@css3DScene.updateMatrix();	

		# @scene.updateMatrix();
		null;
	

	handleFocus:()=>
		if !@isFocused
			if @overObject
				@clickedObject = @overObject;
				@focus();
		else
			if !@overObject
				@unfocus();

		null;

	focus:()=>
		@isFocused = true;


		pageIsLoaded = @clickedObject.page.find("main").length > 0

		if !pageIsLoaded
			@showLoading()
			$.ajax( @getRelativeLink( @clickedObject.page.attr("permalink") ),
				success : ( data, textStatus, jqXHR  ) =>
					# @setupCSS3DPage(data,object,link)
					mainArticle = $(data).find("main")
					@clickedObject.page.append( mainArticle )
					@focus()
				error : (jqXHR,textStatus,errorThrown ) =>
					console.error(textStatus);
			)			
			return

		@hideLoading();
		@clickedObjectWPosition = @initialObjectsProperties[@clickedObject.name].position.clone();
		@clickedObjectWRotation = @initialObjectsProperties[@clickedObject.name].quaternion.clone();
		@clickedObjectWScale    = @initialObjectsProperties[@clickedObject.name].scale.clone();

		newPos = @getFocusedPagePosition();


		@clickedObject.page.css
			"pointer-events" : "none"



		TweenMax.to @clickedObject.position, @TRANSITION_DURATION, 
			x:newPos.x
			y:newPos.y
			z:newPos.z
			onUpdateParams : [@clickedObject]
			onCompleteParams : [@clickedObject]
			onUpdate:(object)=>
				object.cssObj.position.set( object.position.x * @SCENE_SCALE_MULTIPLIER,object.position.y * @SCENE_SCALE_MULTIPLIER,object.position.z * @SCENE_SCALE_MULTIPLIER)
			onComplete:(object)=>
				object.page.css
					"pointer-events" : ""

		camRot = @camera.quaternion.clone();
		rot2 = new THREE.Quaternion();
		rot2.setFromAxisAngle( new THREE.Vector3( 1, 0, 0 ), Math.PI / 2 );

		camRot.multiply(rot2);
		
		TweenMax.to @clickedObject.quaternion, @TRANSITION_DURATION,
			x:camRot.x
			y:camRot.y
			z:camRot.z
			w:camRot.w
			onUpdateParams : [@clickedObject]
			onUpdate:(object)=>
				object.cssObj.quaternion.set(object.quaternion.x,object.quaternion.y,object.quaternion.z,object.quaternion.w)					
				rot2 = new THREE.Quaternion();
				rot2.setFromAxisAngle( new THREE.Vector3( 1, 0, 0 ), -Math.PI / 2 );
				object.cssObj.quaternion.multiply(rot2);						

		TweenMax.to @clickedObject.scale, @TRANSITION_DURATION,
			x:1
			y:1
			z:1
			onUpdateParams : [@clickedObject]
			onUpdate:(object)=>
				object.cssObj.scale.set(object.scale.x * @PAGE_SCALE_MULTIPLIER,object.scale.y * @PAGE_SCALE_MULTIPLIER,object.scale.z * @PAGE_SCALE_MULTIPLIER)	
				# console.log(object.scale.x * @PAGE_SCALE_MULTIPLIER)					

		TweenMax.to @clickedObject.material.uniforms.focus_balance, @TRANSITION_DURATION,
			value:1

		@clickedObject.page.css 
			display : "block"

		TweenMax.to @clickedObject.page[0], @TRANSITION_DURATION,
			css:
				opacity:1	


		$(".close-page").show();

		null;

	getFocusedPagePosition:=>
		rotMat = new THREE.Matrix4();
		rotMat.makeRotationFromQuaternion(@camera.quaternion);

		forward = new THREE.Vector3(0,0,-1);
		forward.applyMatrix4( rotMat );
		forward.normalize();

		right = new THREE.Vector3(1,0,0);
		right.applyMatrix4( rotMat );
		right.normalize();		

		# 600 : 0.4 = height : x
		zDistance = (window.innerHeight*0.00065)#/600

		# 1050 : 0 = width : x
		xDistance = 0 #- ( ( window.innerWidth- 1050) * 0.00054 )

		right.multiplyScalar(xDistance);
		forward.multiplyScalar(zDistance);


		newPos = @camera.position.clone();
		newPos.x -= @scene.position.x;
		newPos.y -= @scene.position.y;
		newPos.z -= @scene.position.z;
		newPos.x /= @SCENE_SCALE_MULTIPLIER;
		newPos.y /= @SCENE_SCALE_MULTIPLIER;
		newPos.z /= @SCENE_SCALE_MULTIPLIER;

		newPos.add(right);
		newPos.add(forward);

		return newPos;		

	unfocus:=>
		TweenMax.to @clickedObject.position, @TRANSITION_DURATION,
			x:@clickedObjectWPosition.x
			y:@clickedObjectWPosition.y
			z:@clickedObjectWPosition.z
			onComplete:()=>
				@isFocused = false;
			onUpdateParams : [@clickedObject]
			onUpdate:(object)=>
				object.cssObj.position.set(object.position.x * @SCENE_SCALE_MULTIPLIER,object.position.y * @SCENE_SCALE_MULTIPLIER,object.position.z * @SCENE_SCALE_MULTIPLIER)					

		TweenMax.to @clickedObject.quaternion, @TRANSITION_DURATION,
			x:@clickedObjectWRotation.x
			y:@clickedObjectWRotation.y
			z:@clickedObjectWRotation.z
			w:@clickedObjectWRotation.w
			onUpdateParams : [@clickedObject]
			onUpdate:(object)=>
				object.cssObj.quaternion.set(object.quaternion.x,object.quaternion.y,object.quaternion.z,object.quaternion.w)					
				rot2 = new THREE.Quaternion();
				rot2.setFromAxisAngle( new THREE.Vector3( 1, 0, 0 ), -Math.PI / 2 );
				object.cssObj.quaternion.multiply(rot2);					

		TweenMax.to @clickedObject.scale, @TRANSITION_DURATION,
			x:@clickedObjectWScale.x
			y:@clickedObjectWScale.y
			z:@clickedObjectWScale.z
			onUpdateParams : [@clickedObject]
			onUpdate:(object)=>
				object.cssObj.scale.set(object.scale.x * @PAGE_SCALE_MULTIPLIER,object.scale.y * @PAGE_SCALE_MULTIPLIER,object.scale.z * @PAGE_SCALE_MULTIPLIER)					

		TweenMax.to @clickedObject.material.uniforms.focus_balance, @TRANSITION_DURATION,
			value:0


		

		TweenMax.to @clickedObject.page[0], @TRANSITION_DURATION,
			css:
				opacity:0
			onComplete:()=>
				@clickedObject.page.css 
					display : "none"	


		$(".close-page").hide();
		null;				

	


	onWindowResize:()=> 
		@CONTAINER_X = @container.position().left;
		@SCREEN_WIDTH = window.innerWidth - @CONTAINER_X
		@SCREEN_HEIGHT = window.innerHeight

		@windowHalfX = @SCREEN_WIDTH / 2;
		@windowHalfY = @SCREEN_HEIGHT / 2;

		@camera.aspect = @SCREEN_WIDTH / @SCREEN_HEIGHT;
		@camera.updateProjectionMatrix();


		@webglRenderer?.setSize( @SCREEN_WIDTH, @SCREEN_HEIGHT );
		@css3dRenderer?.setSize( @SCREEN_WIDTH, @SCREEN_HEIGHT );

		if @isFocused
			pos = @getFocusedPagePosition()
			@clickedObject.position.set(pos.x,pos.y,pos.z)
			@clickedObject.cssObj.position.set(pos.x* @SCENE_SCALE_MULTIPLIER,pos.y* @SCENE_SCALE_MULTIPLIER,pos.z* @SCENE_SCALE_MULTIPLIER)




	onMouseMove:(event)=> 

		if !@isFocused
			event.originalEvent.preventDefault();

		mx = event.clientX || event.originalEvent.touches[0]?.clientX
		my = event.clientY || event.originalEvent.touches[0]?.clientY

		@mouseX = ( (mx - @CONTAINER_X) - @windowHalfX ) * 0.5;
		@mouseY = ( my - @windowHalfY ) * 0.5;

		@pickMouseX = ( (mx - @CONTAINER_X) / @SCREEN_WIDTH ) * 2 - 1;			
		@pickMouseY = - ( my / @SCREEN_HEIGHT ) * 2 + 1;	

		console.log("MOVE")

	animate:()=>
		requestAnimationFrame( @animate );
		@render();
		# @stats.update();

	render:()=> 
		if !@isFocused
			@camera.position.x += ( @mouseX - @camera.position.x ) * 0.05;
			@camera.position.y += ( - @mouseY - @camera.position.y ) * 0.05;
			@camera.position.y = Math.max( @FLOOR, @camera.position.y );
			@camera.lookAt( @cameraLookAt );
		

		
		@webglRenderer?.render( @scene, @camera );
		@css3dRenderer?.render( @css3DScene, @camera );


		vector = new THREE.Vector3( @pickMouseX, @pickMouseY, 1 );
		@projector.unprojectVector( vector, @camera );
		@raycaster.set( @camera.position, vector.sub( @camera.position ).normalize() );
		intersects = @raycaster.intersectObjects( @scene.children );

		# console.log(intersects.length);

		if @doPicking
			if intersects.length > 0
				@handlePicking(intersects[ 0 ].object)
			else 
				# doesn't intersect
				if ( @overObject ) 
					TweenMax.to( @overObject.material.uniforms.ovelay_unfocused_alpha, 1, {value:1} );
				@overObject = null;

		if @overObject? && !@isFocused
			$("body").css('cursor', 'pointer');
		else
			$("body").css('cursor', '');


	handlePicking:(object)=>
		if @overObject != object
			# intersects and it's different from before
			if ( @overObject ) 
				TweenMax.to( @overObject.material.uniforms.ovelay_unfocused_alpha, 1, {value:1} );	

			if @excludeFromPicking.indexOf(object.name) == -1 
				# filter picked objects
				@overObject = object;			
				TweenMax.to( @overObject.material.uniforms.ovelay_unfocused_alpha, 1, {value:0} );
			else
				# picked object is excluded
				@overObject = null;
		else
			# intersects but it's no different from before
			# if ( @overObject && intersects[ 0 ].object.name == "scene_baked_pPlane1" ) 
			# 	TweenMax.to( @overObject.material.uniforms.ovelay_unfocused_alpha, 1, {value:1} );		

	getUpDirs:(howMany)=>
		retValue = ""
		for i in [0...howMany] by 1
			retValue += "../"
		return retValue;
		

	getRelativeLink:(objectPermalink)=>
		thisDepth = @pageDepth;
		# otherDepth = objectToLink.depth
		updirs = @getUpDirs(thisDepth);
		if(thisDepth > 0)
			return updirs.substr(0,updirs.length-1)+objectPermalink;	
		else
			return 	"."+objectPermalink;

	cleanupPathName:(path)=>
		arr = path.split("/")

		return "/"+arr[ arr.length-3 ] + "/" +arr[ arr.length-2 ]+"/"
