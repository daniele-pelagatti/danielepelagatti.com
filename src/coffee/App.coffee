#import utils/MotionAnalysis
#import utils/QueryString

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
	
	camera                   : null;
	scene                    : null;
	css3DScene               : null;
	renderer                 : null;
	css3dRenderer            : null;
	isWebGLCapable           : false;
	isCSS3DCapable           : false;
	isCanvasCapable          : false;
	isIE11                   : false;
	
	mouseX                   : 0;
	mouseY                   : 0;
	pickMouseX               : -90000;
	pickMouseY               : -90000;
	
	windowHalfX              : @SCREEN_WIDTH / 2;
	windowHalfY              : @SCREEN_HEIGHT / 2;
	
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
	doRender                 : true;
	
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
	minCameraX               : -250
	maxCameraX               : 250
	minCameraY               : -50
	maxCameraY               : 300
	unfocusingTween          : null
	motionAnalysis           : null
	lockedOnDeviceMotion     : false
	deviceMotionChangeTimes  : 0		
	prevMotionAnalysis       : 
		x : 0
		y : 0
		z : 0


	constructor:->

		@isIE11              = !!window.MSInputMethodContext;
		@isCSS3DCapable      = Modernizr.csstransforms3d && !@isIE11#Modernizr.transformstylepreserve3d 
		@isWebGLCapable      = @checkWebGL() && Modernizr.webgl
		@isPushStateCapable  = Modernizr.history


		# disable canvas mode, too slow on ipads
		# @isCanvasCapable = Modernizr.canvas

		if @isCSS3DCapable && @isPushStateCapable && ( @isCanvasCapable || @isWebGLCapable )# minimum requirements
			@htmlMain = $("main")
			ga('send', 'event', 'webgl-test', 'passed');
			$("body").css("overflow-y","hidden");
			$("html").css("overflow-y","hidden");

			TweenMax.to @htmlMain, 1,
				css:
					opacity:0
				onComplete:(thisPage)=>
					@showLoading()
					TweenMax.to(@htmlMain,0,{css:{opacity: 1}});
					@htmlMain.remove()

			

					$.ajax @pageBase+"config.json",
						success : @onConfigLoaded
						error   : @onConfigError
					

					@init();
					@animate();			
		else
			# we cannot continue, no webgl support
			ga('send', 'event', 'webgl-test', 'failed');


		null

	init:-> 
		@container = $( '.javascriptContent' );

		@CONTAINER_X   = @container.position().left;
		@SCREEN_WIDTH  = window.innerWidth - @CONTAINER_X;
		@SCREEN_HEIGHT = window.innerHeight;
		@windowHalfX   = @SCREEN_WIDTH / 2;
		@windowHalfY   = @SCREEN_HEIGHT / 2;

		@motionAnalysis = new MotionAnalysis()
		


		@camera = new THREE.PerspectiveCamera( 75, @SCREEN_WIDTH / @SCREEN_HEIGHT, 1, 10000 );
		@camera.position.z = 300;

		@scene = new THREE.Scene();


		@css3DScene = new THREE.Scene();
		@css3DScene.scale.set(@CSS3D_SCALE_MULTIPLIER,@CSS3D_SCALE_MULTIPLIER,@CSS3D_SCALE_MULTIPLIER)
		@css3DScene.updateMatrix();


		if @isWebGLCapable
			@renderer = new THREE.WebGLRenderer
				antialias   : true
				# sortObjects : false

			@renderer.gammeInput = true;
			@renderer.gammeOutput = true;
		else if @isCanvasCapable
			@renderer = new THREE.CanvasRenderer
				# sortObjects  : false
				# sortElements : false

		@renderer.setClearColor( 0xffffff, 1 );
		@renderer.setSize( @SCREEN_WIDTH, @SCREEN_HEIGHT );
		@renderer.domElement.style.position = "relative";
		$(@renderer.domElement).addClass("threejs-container");
		@container.append( @renderer.domElement );



		@css3dRenderer = new THREE.CSS3DRenderer()
		@css3dRenderer.setClearColor( 0xffffff );
		@css3dRenderer.setSize( @SCREEN_WIDTH, @SCREEN_HEIGHT );
		@css3dRenderer.domElement.style.position = "absolute";
		@css3dRenderer.domElement.style.top = "0";
		@css3dRenderer.domElement.style.left = "0";
		$(@css3dRenderer.domElement).addClass("css3d-container");
		@container.append( @css3dRenderer.domElement );

		@projector = new THREE.Projector();
		@raycaster = new THREE.Raycaster();



		$(window).bind( 'resize', @onWindowResize );
		@container.bind( 'mousemove touchmove touchstart', @onMouseMove );
		@container.bind( 'click touchend', @on3DSceneMouseClick );
		@container.bind( "transitionend webkitTransitionEnd oTransitionEnd otransitionend MSTransitionEnd" , @onWindowResize);
		# link overrides
		$(".projectsMenu").find("a").mouseover(@onMenuLinkOver)
		$(".projectsMenu").find("a").mouseout(@onMenuLinkOut)
		$(".projectsMenu").find("a").click(@onMenuLinkClick)

		$(".menu").find("a").mouseover =>
			@doPicking = false
		$(".menu").find("a").mouseout =>
			@doPicking = true

		$(".close-page").click(@onCloseClick)
		$(window).bind("popstate",@onPopStateChange);		

		@onWindowResize()

		TweenMax.to( $(".threejs-container"), 0, {css:{opacity:0}} )
		TweenMax.to( $(".css3d-container"), 0, {css:{opacity:0}} )

		if @pagePermalink? && @pagePermalink != ""
			@currentHistoryState = "/"+@pageLanguage+"/"+@pagePermalink+"/"
		else
			@currentHistoryState = "/"+@pageLanguage+"/"

		null


	onConfigLoaded:( data, textStatus, jqXHR  )=>
		@allLanguagesConfig = data;
		@config = data[@pageLanguage]
		if !@config?
			throw "Cannot find config for this language"

		# load scene
		loader = new THREE.SceneLoader();
		if @isWebGLCapable
			loader.load( @pageBase+"maya/data/scene.json", @sceneLoadCallback );
		else
			loader.load( @pageBase+"maya/data/scene_canvas.json", @sceneLoadCallback );

		
		null


	onPopStateChange:(event)=>
		return if !event.originalEvent.state?

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

		if @unfocusingTween? && !@unfocusingTween._active
			@unfocusingTween = null

		if @unfocusingTween?
			# we are in the middle of an unfocus tween
			# we need to replace what happens next on the fly
			@unfocusingTween.vars.onCompleteParams[1] = =>
				@clickedObject = @overObject = obj3D
				@unfocusingTween = null
				@focus()

		else if @isFocused
			# we are focused on a page

			if newPath != @currentHistoryState
				# a different page needs to be focused
				# we need to unfocus then focus again next
				@unfocus =>
					@clickedObject = @overObject = obj3D
					@focus()				
		else
			# we are roaming free in the 3d space, we need to focus on a page
			@overObject = @clickedObject = obj3D;
			@focus()


		if newPath != @currentHistoryState
			# change language change link on languages menu to go to the current page
			languageLinks = $(".languagesMenu").find("a");
			for languageLink in languageLinks
				languageConfig = @allLanguagesConfig[languageLink.id]
				for page in languageConfig
					if page.meta.id == @pageId
						$(languageLink).attr("href", @getRelativeLink(page.link) )



			#update selected project on the menu

			selectedMenuItem = @findMenuItemByPermalink( newPath, 
				(item)=>
					item.removeClass("selected")
				,
				(item)=>
					item.attr("href", @pageBase+@getRelativeLink( item.attr("permalink") ).substr(1) )
					item.parent().removeClass("hover")
				);

			# scroll menu to selected item
			if selectedMenuItem?
				selectedMenuItem.addClass("selected")
				@scrollMenuToItem(selectedMenuItem)


			ga('send', 'pageview', @thisPageConfig.link);

			@currentHistoryState = newPath;

		null

	scrollMenuToItem:(item)=>
		scrollTarget = $(".menu")
		targetPosition = item.position()
		scroller = scrollTarget.scrollTop()
		scrollToY = (targetPosition.top+scroller) - (@SCREEN_HEIGHT/2)

		TweenMax.to(scrollTarget[0], 0.5, {scrollTo:{y:scrollToY}, ease:Power2.easeOut});
		null

	onMenuLinkOver:(event)=>
		if !@isFocused
			obj3D =  @page3DObjects[ $(event.currentTarget).attr("permalink") ];
			@handle3DPlaneMouseInteraction(obj3D,"menu")
		null

	onMenuLinkOut:(event)=>
		null

	onMenuLinkClick:(event)=>
		event.originalEvent.preventDefault();
		@on3DPlaneMouseOut(@overObject)
		@overObject = null
		@handlePushState( $(event.currentTarget).attr("permalink") ) 
		null

	onCloseClick:=>
		ga('send', 'event', 'close-page-button', 'click');
		@unfocus()		
		null

	on3DPlaneMouseOver:(plane,source)=>
		if !@isFocused
			if @isWebGLCapable
				TweenMax.to( plane.material.uniforms.color_opacity, 0.5, {value:1} );


			if source != "menu"
				menuItem = @findMenuItemByPermalink plane.page.attr("permalink"), (item) -> item.parent().removeClass("hover")
				menuItem.parent().addClass("hover")
				@scrollMenuToItem(menuItem)
		null
		
	on3DPlaneMouseOut:(plane,source)=>
		
		return if !plane?

		if @isWebGLCapable
			TweenMax.to( plane.material.uniforms.color_opacity, 0.5, {value:0} );

		if !@isFocused
			menuItem = @findMenuItemByPermalink( plane.page.attr("permalink") )
			menuItem.parent().removeClass("hover")
		null

	findMenuItemByPermalink:(permalink,executeOnOthers,executeOnAll)=>		
		projectsLinks = $(".projectsMenu").find("a");
		
		retValue = null


		for menuItem in projectsLinks
			projectLink = $(menuItem)
			if projectLink.attr("permalink") == permalink
				retValue = projectLink
			else
				executeOnOthers?( projectLink )

			executeOnAll?( projectLink )
		
		return retValue
					

	on3DSceneMouseClick:(event)=>

		@calcPicking()

		if !@overObject?
			# required to unfocus ( click outside focused plane )
			if !@isFocused
				if @overObject
					@clickedObject = @overObject;
					@focus();
			else
				if !@overObject
					@unfocus();
			ga('send', 'event', '3d-empty-space', 'click');
			return;

		ga('send', 'event', '3d-plane:'+@overObject.link, 'click');
		@handlePushState(@overObject.link)

	handlePushState:(path)=>
		stateObj = {path:path}

		if path != @currentHistoryState
			history.pushState(stateObj,"Title",@pageBase+path.substr(1))

		@onPopStateChange 
			originalEvent:
				state: stateObj
		
		

	onConfigError:(jqXHR,textStatus,errorThrown )=> throw errorThrown



	
	onTouchStart:(event)=>
	onTouchMove:(event)=>
	onTouchEnd:(event)=>

	
	setupCSS3DPage: ( pageObj, object, link )=>

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
		null; 


	
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

		thisPage = null;

		result.scene.traverse (object)=> 
			object.rotation.order  = "ZYX";

			if object.material?

				if @excludeFromPicking.indexOf(object.name) == -1
					@initialObjectsProperties[object.name] = {}
					@initialObjectsProperties[object.name].position = object.position.clone();
					@initialObjectsProperties[object.name].quaternion = object.quaternion.clone();
					@initialObjectsProperties[object.name].scale = object.scale.clone();



					if @config[objectIndex]?
						object.config = @config[objectIndex]

						@page3DObjects[@config[objectIndex].link] = object;

						link = object.link = @config[objectIndex].link;

						container = $("<div class='object3DContainer' permalink='"+link+"'></div>")

						if object.config.meta.permalink == @pagePermalink || ( object.config.meta.permalink == null && @pagePermalink == "" )
							# don't load ourselves
							@htmlMain.find("#no-webgl-warning").remove()
							@htmlMain.find(".no-webgl-warning-button").remove()
							container.append(@htmlMain)
							thisPage = link

						@setupCSS3DPage( container , object, link )		
					else
						@excludeFromPicking.push(object.name)


					objectIndex++;


				if @isWebGLCapable
					# replace material with our simple webgl one
					@replaceThreeJsMaterial(object,objectIndex)

					if object.name != "scene_baked_pPlane1"
						object.material.uniforms.fresnelIntensity.value = 1;
				else
					# replace material with a simple threejs one
					object.material = new THREE.MeshBasicMaterial
						lights : false
						fog: false
						shading: THREE.FlatShading
						map : object.material.map
					object.material.overdraw = true

				object.material.transparent = true;
				object.material.opacity = 1;
				object.material.side = THREE.DoubleSide;				


			if object.geometry?
				object.geometry.computeFaceNormals();
				object.geometry.computeVertexNormals();
				# object.geometry.computeCentroids();
				object.geometry.computeTangents();
				object.geometry.computeBoundingBox();

			object.updateMatrix();



		
			
		@scene = result.scene;
		@scene.position.set(0,-450,0)
		@css3DScene.position.set(0,-450,0)

		@scene.scale.set(@SCENE_SCALE_MULTIPLIER,@SCENE_SCALE_MULTIPLIER,@SCENE_SCALE_MULTIPLIER)

		@scene.updateMatrix();	
		@css3DScene.updateMatrix();	

		@hideLoading()



		
		TweenMax.to $(".threejs-container"), 1,
			css:
				opacity:1


		TweenMax.to $(".css3d-container"), 1,
			css:
				opacity:1

			onCompleteParams: [thisPage]

			onCompleteParams: [thisPage]
			onComplete:(thisPage)=>
				if thisPage?
					@handlePushState(thisPage)
		null;
	

	replaceThreeJsMaterial:(object,objectIndex)=>
		uniforms = THREE.UniformsUtils.clone(THREE.PlaneShader.uniforms)
		# uniforms.focus_balance.value = 0;
		uniforms.color_opacity.value = 0;
		uniforms.opacity.value = 1;
		uniforms.diffuse.value.set( @colors[objectIndex].rgb[0] / 255 , @colors[objectIndex].rgb[1] /255 , @colors[objectIndex].rgb[2] /255 )
		uniforms.map.value = object.material.map


		defines = {}
		defines["USE_MAP"] = "";
		# defines["GAMMA_OUTPUT"] = "";
		if @isIE11
			# IE11 doesn't support gl_frontFacing
			defines["NO_FRESNEL"] = "";


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



	focus:(callback)=>
		@isFocused = true;

		pageIsLoaded = @clickedObject.page.find("main").length > 0

		if !pageIsLoaded
			
			@showLoading()

			$.ajax @getRelativeLink( @clickedObject.page.attr("permalink") ),
				success : ( data, textStatus, jqXHR  ) =>
					mainArticle = $(data).find("main")
					mainArticle.find("#no-webgl-warning").remove()
					mainArticle.find(".no-webgl-warning-button").remove()
					@clickedObject.page.append( mainArticle )
					@focus()
				error : (jqXHR,textStatus,errorThrown ) =>
					console.error(textStatus);
					
			return

		@hideLoading();


		# mouseout all planes
		@scene.traverse (object)=> 
			if object.material?
				@on3DPlaneMouseOut(object)


		@clickedObjectWPosition = @initialObjectsProperties[@clickedObject.name].position.clone();
		@clickedObjectWRotation = @initialObjectsProperties[@clickedObject.name].quaternion.clone();
		@clickedObjectWScale    = @initialObjectsProperties[@clickedObject.name].scale.clone();

		newPos = @getFocusedPagePosition();


		@clickedObject.page.css
			"pointer-events" : "none"



		TweenMax.to @clickedObject.position, @TRANSITION_DURATION, 
			x                : newPos.x
			y                : newPos.y
			z                : newPos.z
			onUpdateParams   : [@clickedObject]
			onUpdate         : @syncCss3dPlanePosition
			onCompleteParams : [@clickedObject,callback]
			onComplete       : (object,callback)=>
				object.page.css
					"pointer-events" : ""
				@doRender = false;
				@syncCss3dPlanePosition(object);
				@onWindowResize();
				@render();
				callback?();

		camRot = @camera.quaternion.clone();
		rot2 = new THREE.Quaternion();
		rot2.setFromAxisAngle( new THREE.Vector3( 1, 0, 0 ), Math.PI / 2 );

		camRot.multiply(rot2);
		
		TweenMax.to @clickedObject.quaternion, @TRANSITION_DURATION,
			x                : camRot.x
			y                : camRot.y
			z                : camRot.z
			w                : camRot.w
			onUpdateParams   : [@clickedObject]
			onUpdate         : @syncCss3dPlaneRotation
			onCompleteParams : [@clickedObject]
			onComplete       : @syncCss3dPlaneRotation					

		TweenMax.to @clickedObject.scale, @TRANSITION_DURATION,
			x                : 1
			y                : 1
			z                : 1
			onUpdateParams   : [@clickedObject]
			onUpdate         : @syncCss3dPlaneScale		
			onCompleteParams : [@clickedObject]
			onComplete       : @syncCss3dPlaneScale					

		if @isWebGLCapable
			TweenMax.to @clickedObject.material.uniforms.opacity, @TRANSITION_DURATION,
				value:0
		else
			TweenMax.to @clickedObject.material, @TRANSITION_DURATION,
				opacity:0			

		@clickedObject.page.css 
			display : "block"

		TweenMax.to @clickedObject.page[0], @TRANSITION_DURATION,
			css:
				opacity:1	


		$(".close-page").show();

		null;

	

	unfocus:(callback)=>
		@doRender = true
		@isFocused = false;
		@animate()

		TweenMax.to @clickedObject.position, @TRANSITION_DURATION,
			x                : @clickedObjectWPosition.x
			y                : @clickedObjectWPosition.y
			z                : @clickedObjectWPosition.z
			onUpdateParams   : [@clickedObject]
			onUpdate         : @syncCss3dPlanePosition
			onCompleteParams : [@clickedObject]
			onComplete       : @syncCss3dPlanePosition


		TweenMax.to @clickedObject.quaternion, @TRANSITION_DURATION,
			x                : @clickedObjectWRotation.x
			y                : @clickedObjectWRotation.y
			z                : @clickedObjectWRotation.z
			w                : @clickedObjectWRotation.w
			onUpdateParams   : [@clickedObject]
			onUpdate         : @syncCss3dPlaneRotation
			onCompleteParams : [@clickedObject]
			onComplete       : @syncCss3dPlaneRotation
					

		TweenMax.to @clickedObject.scale, @TRANSITION_DURATION,
			x                : @clickedObjectWScale.x
			y                : @clickedObjectWScale.y
			z                : @clickedObjectWScale.z
			onUpdateParams   : [@clickedObject]
			onUpdate         : @syncCss3dPlaneScale		
			onCompleteParams : [@clickedObject]
			onComplete       : @syncCss3dPlaneScale					

		if @isWebGLCapable
			TweenMax.to @clickedObject.material.uniforms.opacity, @TRANSITION_DURATION,
				value:1
		else
			TweenMax.to @clickedObject.material, @TRANSITION_DURATION,
				opacity:1


		

		@unfocusingTween = TweenMax.to @clickedObject.page[0], @TRANSITION_DURATION,
			css:
				opacity:0
			onCompleteParams: [@clickedObject,callback]
			onComplete:(object,callback)=>
				
				object.page.find("main").remove()

				object.page.css 
					display : "none"
				@unfocusingTween = null
				callback?();


		$(".close-page").hide();
		null;				

	syncCss3dPlaneScale:(object)=>
		object.cssObj.scale.set(object.scale.x * @PAGE_SCALE_MULTIPLIER,object.scale.y * @PAGE_SCALE_MULTIPLIER,object.scale.z * @PAGE_SCALE_MULTIPLIER)	

	syncCss3dPlanePosition:(object)=>
		object.cssObj.position.set(object.position.x * @SCENE_SCALE_MULTIPLIER,object.position.y * @SCENE_SCALE_MULTIPLIER,object.position.z * @SCENE_SCALE_MULTIPLIER)	

	syncCss3dPlaneRotation:(object)=>
		object.cssObj.quaternion.set(object.quaternion.x,object.quaternion.y,object.quaternion.z,object.quaternion.w)					
		rot2 = new THREE.Quaternion();
		rot2.setFromAxisAngle( new THREE.Vector3( 1, 0, 0 ), -Math.PI / 2 );
		object.cssObj.quaternion.multiply(rot2);
	
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

	onWindowResize:()=> 
		@CONTAINER_X = @container.position().left;
		@SCREEN_WIDTH = window.innerWidth - @CONTAINER_X
		@SCREEN_HEIGHT = window.innerHeight

		@windowHalfX = @SCREEN_WIDTH / 2;
		@windowHalfY = @SCREEN_HEIGHT / 2;

		@camera.aspect = @SCREEN_WIDTH / @SCREEN_HEIGHT;
		@camera.updateProjectionMatrix();


		@renderer?.setSize( @SCREEN_WIDTH, @SCREEN_HEIGHT );
		@css3dRenderer?.setSize( @SCREEN_WIDTH, @SCREEN_HEIGHT );

		if @isFocused
			pos = @getFocusedPagePosition()
			@clickedObject.position.set(pos.x,pos.y,pos.z)
			@clickedObject.cssObj.position.set(pos.x* @SCENE_SCALE_MULTIPLIER,pos.y* @SCENE_SCALE_MULTIPLIER,pos.z* @SCENE_SCALE_MULTIPLIER)

		@render()


	onMouseMove:(event)=> 

		if !@isFocused
			event.originalEvent.preventDefault();

		mx = event.clientX || event.originalEvent.touches?[0]?.clientX || 0
		my = event.clientY || event.originalEvent.touches?[0]?.clientY || 0

		@mouseX = ( (mx - @CONTAINER_X) - @windowHalfX );
		@mouseY = ( my - @windowHalfY );
		# @mouseX = mx - @CONTAINER_X;
		# @mouseY = my;

		@pickMouseX = ( (mx - @CONTAINER_X) / @SCREEN_WIDTH ) * 2 - 1;			
		@pickMouseY = - ( my / @SCREEN_HEIGHT ) * 2 + 1;	

		# console.log("MOVE")

	animate:()=>
		@render();
		# @stats.update();
		requestAnimationFrame( @animate ) if @doRender;



	render:()=> 


		if !@isFocused

			rangeX = @maxCameraX - @minCameraX
			rangeY = @maxCameraY - @minCameraY

			if @lockedOnDeviceMotion || @prevMotionAnalysis.x != @motionAnalysis.rotation.x || @prevMotionAnalysis.y != @motionAnalysis.rotation.y || @prevMotionAnalysis.z != @motionAnalysis.rotation.z
				
				@deviceMotionChangeTimes++;

				if @deviceMotionChangeTimes >= 4
					@lockedOnDeviceMotion = true
				
				lim = 4

				mrX = Math.max( Math.min( @motionAnalysis.rotation.x , lim ), -lim );
				mrY = Math.max( Math.min( @motionAnalysis.rotation.z , lim ), -lim );

				camX = ( mrX * rangeX ) / (lim*2)
				camY = ( mrY * rangeY ) / (lim*2)
			else

				camX = ( @mouseX * rangeX ) / @SCREEN_WIDTH
				camY = ( -@mouseY * rangeY ) / @SCREEN_HEIGHT

				# @mouseX : @SCREEN_WIDTH = x : Math.PI/2

				# t = ( -@mouseX * Math.PI ) / @SCREEN_WIDTH
				# t += Math.PI/2
				
				# camX = 400 * Math.cos(t)
				# camZ = 400 * Math.sin(t)

				# camY = ( -@mouseY * rangeY ) / @SCREEN_HEIGHT


			@camera.position.x += ( camX - @camera.position.x ) * 0.05;
			@camera.position.y += ( camY - @camera.position.y ) * 0.05;
			# @camera.position.z += ( camZ - @camera.position.z ) * 0.05;



			@camera.lookAt( @cameraLookAt );


		@prevMotionAnalysis.x = @motionAnalysis.rotation.x
		@prevMotionAnalysis.y = @motionAnalysis.rotation.y
		@prevMotionAnalysis.z = @motionAnalysis.rotation.z

		@calcPicking();

		@renderer?.render( @scene, @camera );
		@css3dRenderer?.render( @css3DScene, @camera );


	calcPicking:()=>
		vector = new THREE.Vector3( @pickMouseX, @pickMouseY, 1 );
		@projector.unprojectVector( vector, @camera );
		@raycaster.set( @camera.position, vector.sub( @camera.position ).normalize() );
		intersects = @raycaster.intersectObjects( @scene.children );

		if @doPicking
			if intersects.length > 0
				@handle3DPlaneMouseInteraction(intersects[ 0 ].object,"3d")
			else 
				@handle3DPlaneMouseInteraction(null,"3d")
					
				@overObject = null;


		if @overObject? && !@isFocused
			$("body").css('cursor', 'pointer');
		else
			$("body").css('cursor', '');


	handle3DPlaneMouseInteraction:(object,initiator)=>

		if !object? && @overObject?
			@on3DPlaneMouseOut(@overObject)
			return

		if @overObject != object
			# intersects and it's different from before
			if @overObject
				@on3DPlaneMouseOut(@overObject,initiator)

			if @excludeFromPicking.indexOf(object.name) == -1 
				# filter picked objects
				@overObject = object;
				@on3DPlaneMouseOver(@overObject,initiator)
				if !@isFocused
					ga('send', 'event', '3d-plane:'+@overObject.link, 'over');
			else
				@overObject = null;

	getUpDirs:(howMany)=>
		retValue = ""
		for i in [0...howMany] by 1
			retValue += "../"
		return retValue;
		

	getRelativeLink:(objectPermalink)=>
		updirs = @getUpDirs(@pageDepth);
		if(@pageDepth > 0)
			return updirs.substr(0,updirs.length-1)+objectPermalink;	
		else
			return 	"."+objectPermalink;

		
	checkWebGL:->
		ua = navigator.userAgent.toLowerCase()
		isStockAndroid = /android/.test(ua) and !/chrome/.test(ua)
		try
			return !!window.WebGLRenderingContext && !!document.createElement('canvas').getContext('experimental-webgl') and !isStockAndroid
		catch
			return false

	showLoading:=>
		$("body").spin
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
			top       : '50%', # Top position relative to parent in px
			left      : '50%' # Left position relative to parent in px	

		null

	hideLoading:=>
		$("body").spin(false)	
		null	