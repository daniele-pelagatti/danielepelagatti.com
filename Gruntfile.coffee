module.exports = (grunt)->
    # Project configuration.    
    # debugger

    env = grunt.option("env") || "prod";
    deploy_user = grunt.option("user");

    rewriteModule = require("http-rewrite-middleware");

    optional_files = [
        "src/js/optional/three.js" 
        "src/js/optional/spin.js"
        "src/js/optional/*.js"
        "src/js/optional/shaders.js"
        "src/js/optional/main.js"
    ]

    essential_files = [
        "src/js/essential/jquery.js"
        "src/js/essential/jquery.leanModal.js"
        "src/js/essential/essential.js"
    ]


    gruntConfig = 
        pkg: grunt.file.readJSON("package.json")


    gruntConfig.percolator =
        compile:
            source  : gruntConfig.pkg.coffee_folder
            output  : gruntConfig.pkg.compiled_js
            main    : gruntConfig.pkg.percolator_main
            compile : true

    gruntConfig.compass =
        compile:
            options:
                sassDir     : gruntConfig.pkg.compass_folder
                cssDir      : gruntConfig.pkg.compass_output_folder
                outputStyle : "expanded"

    gruntConfig.glsl_threejs =
        compile:
            files : {}
    gruntConfig.glsl_threejs.compile.files[gruntConfig.pkg.glsl_output_file] = [gruntConfig.pkg.glsl_folder+"/*.vert",gruntConfig.pkg.glsl_folder+"/*.frag"]
            

    gruntConfig.watch =
        options:
            livereload: 35729                
        coffee:
            files: [gruntConfig.pkg.watch_folder+"/**/*.coffee"]
            tasks: if env == "prod" then ["percolator","uglify:optional"] else ["percolator","concat:optional"]
        glsl_threejs:
            files: [gruntConfig.pkg.watch_folder+"/**/*.{frag,vert}"]
            tasks: if env == "prod" then ["glsl_threejs","uglify:optional"] else ["glsl_threejs","concat:optional"]
        compass:
            files: [gruntConfig.pkg.watch_folder+"/**/*.{scss,sass}"]
            tasks: if env == "prod" then ["compass","cssmin"] else ["compass","concat:css"]
        jsonmin:
            files: [gruntConfig.pkg.watch_folder+"/maya/data/*.json"]
            tasks: if env == "prod" then  ["jsonmin"] else ["copy:json"]            
        jade:
            files: [gruntConfig.pkg.watch_folder+"/**/*.{jade,md}"]
            tasks: ["compile_markdown_files"]

        uglify_essential :
            files: [gruntConfig.pkg.watch_folder+"/js/essential/*.js"]
            tasks: if env == "prod" then  ["uglify:essential"] else ["concat:essential"]

        # uglify_optional :
        #     files: [gruntConfig.pkg.watch_folder+"/js/optional/*.js"]
        #     tasks: ["uglify:optional"]
        # cssmin :
        #     files: [gruntConfig.pkg.watch_folder+"/**/*.css"]
        #     tasks: ["cssmin"]


        imagemin :
            files: [gruntConfig.pkg.watch_folder+"/images/**/*.{jpg,png,gif}"]
            tasks: ["imagemin:site"]
        imagemin2 :
            files: [gruntConfig.pkg.watch_folder+"/maya/images/**/*.{jpg,png,gif}"]
            tasks: ["imagemin:maya"]
        copy :
            files: [gruntConfig.pkg.watch_folder+"/include/**"]
            tasks: ["copy"]


    gruntConfig.concurrent =
        options:
            logConcurrentOutput : true
        default: ["watch", "connect"]

    gruntConfig.connect =
        default:
            options:
                port       : 8000
                hostname   : "*"
                keepalive  : true
                livereload : 35729
                base       : gruntConfig.pkg.www_folder
                # middleware: (connect, options)->
                #     middlewares = [];

                #     # RewriteRules support
                #     middlewares.push(rewriteModule.getMiddleware([
                #         # rewrite everything not contained in these folders to index.html
                #         {from: "^/(?!css|js|img|maya|en|it).*$", to: "/index.html"} 
                #     ]));

                #     if !Array.isArray(options.base)
                #         options.base = [options.base];
                    

                #     directory = options.directory || options.base[options.base.length - 1];
                #     options.base.forEach((base)->
                #         # Serve static files.
                #         middlewares.push(connect.static(base));
                #     );

                #     # Make directory browse-able.
                #     middlewares.push(connect.directory(directory));

                #     return middlewares;
        

    gruntConfig.uglify =
        options :
            banner       : "/*! <%= pkg.name %> <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n"
            drop_console : true
        optional :
            files : {}
        essential:
            files: {}
    gruntConfig.uglify.optional.files[gruntConfig.pkg.minified_optional_js_file] = optional_files
    gruntConfig.uglify.optional.files[gruntConfig.pkg.minified_essential_js_file] = essential_files


    gruntConfig.cssmin =
        all :
            options:
                banner              : "/*! <%= pkg.name %> <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n"
                keepSpecialComments : false
            files :{}

    gruntConfig.cssmin.all.files[gruntConfig.pkg.minified_main_css_file] = [gruntConfig.pkg.compass_output_folder+"/**/*.css"];


    gruntConfig.modernizr =
        dist:
            devFile             : "modernizr.dev.js"
            outputFile          : gruntConfig.pkg.www_folder+"/js/modernizr.js"
            uglify              : if env == "prod" then true else false
            matchCommunityTests : true
            files : 
                src: ["src/**/*.{css,js}"]
                
            
    gruntConfig.copy =
        include:
            files : [
                {
                    expand : true
                    cwd    : "src/include/"
                    src    : ["**"]
                    dest   : gruntConfig.pkg.www_folder+"/"
                    dot    : true
                }
            ]
        json:
            files : [
                {
                    expand : true
                    cwd    : "src/maya/data/"
                    src    : ["*.json"]
                    dest   : gruntConfig.pkg.www_folder+"/maya/data"
                    dot    : true
                }
            ]            


    gruntConfig.concat =
        optional:
            options:
                separator : ";"
            src  : optional_files
            dest : gruntConfig.pkg.minified_optional_js_file
        essential:
            options:
                separator : ";"            
            src  : essential_files
            dest : gruntConfig.pkg.minified_essential_js_file
        css:
            src  : gruntConfig.pkg.compass_output_folder+"/**/*.css"
            dest : gruntConfig.pkg.minified_main_css_file


    gruntConfig.jsonmin =
        maya:
            options:
                stripWhitespace:true
                stripComments:true
            files: {}

    gruntConfig.jsonmin.maya.files[gruntConfig.pkg.www_folder+"/maya/data/scene.json"] =  "src/maya/data/scene.json"
    gruntConfig.jsonmin.maya.files[gruntConfig.pkg.www_folder+"/maya/data/scene_canvas.json"] =  "src/maya/data/scene_canvas.json"


    gruntConfig.clean =
        all: [gruntConfig.pkg.www_folder]

    gruntConfig.compile_markdown_files =
        all:
            options:
                markdown_folder  : gruntConfig.pkg.markdown_folder
                jade_folder      : gruntConfig.pkg.jade_folder
                www_folder       : gruntConfig.pkg.www_folder
                default_document : gruntConfig.pkg.default_document
                config_json      : gruntConfig.pkg.config_json
                environment      : env

    gruntConfig.imagemin = 
        site:
            options:
                optimizationLevel : 7
            #     pngquant          : false
            #     interlaced        : true
            #     progressive       : true
            files: [
                expand : true
                cwd    : "src/images/"
                src    : ["*.{png,jpg,gif}"]
                dest   : gruntConfig.pkg.www_folder+"/img"
            ]
        maya:
            options:
                optimizationLevel : 7
            #     pngquant          : false
            #     interlaced        : true
            #     progressive       : true
            files: [
                expand : true
                cwd    : "src/maya/images/"
                src    : ["**/*.{png,jpg,gif}"]
                dest   : gruntConfig.pkg.www_folder+"/maya/images"
            ]

    gruntConfig.rsync = 
        options:
            args               : ["--verbose"]
            recursive          : true
            # dryRun             : true
            syncDestIgnoreExcl : true
            exclude            : ["casa","cgi-bin","old","error_log","php.ini","tmp"]
        dist:   
            options:
                src  : gruntConfig.pkg.www_folder
                dest : "/home2/"+deploy_user
                host : deploy_user+"@danielepelagatti.com"

    grunt.initConfig(gruntConfig)

    grunt.task.loadTasks("tasks")
    require("load-grunt-tasks")(grunt);

    
    # Default task(s).
    grunt.registerTask("deploy", ["rsync"]);

    if env == "prod"
        grunt.registerTask("build", ["clean","imagemin","copy:include","percolator","compass","glsl_threejs","compile_markdown_files","uglify","cssmin","jsonmin","modernizr"]);
        # deploy only production
    else
        grunt.registerTask("build", ["clean","imagemin","copy","percolator","compass","glsl_threejs","compile_markdown_files","concat","modernizr"]);
    

    grunt.registerTask("minify", ["copy:include","percolator","compass","glsl_threejs","compile_markdown_files","uglify","cssmin","jsonmin","modernizr"]);
    
    grunt.registerTask("default", ["build","concurrent"]);
