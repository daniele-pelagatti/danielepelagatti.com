module.exports = (grunt)->
    # Project configuration.    
    # debugger

    env = grunt.option("env") || "prod";

    rewriteModule = require("http-rewrite-middleware");

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
            tasks: ["percolator"]
        compass:
            files: [gruntConfig.pkg.watch_folder+"/**/*.{scss,sass}"]
            tasks: ["compass"]
        jade:
            files: [gruntConfig.pkg.watch_folder+"/**/*.{jade,md}"]
            tasks: ["compile_markdown_files"]
        glsl_threejs:
            files: [gruntConfig.pkg.watch_folder+"/**/*.{frag,vert}"]
            tasks: ["glsl_threejs"]
        uglify_essential :
            files: [gruntConfig.pkg.watch_folder+"/js/essential/*.js"]
            tasks: ["uglify:essential"]
        uglify_optional :
            files: [gruntConfig.pkg.watch_folder+"/js/optional/*.js"]
            tasks: ["uglify:optional"]
        cssmin :
            files: [gruntConfig.pkg.watch_folder+"/**/*.css"]
            tasks: ["cssmin"]

    gruntConfig.concurrent =
        options:
            logConcurrentOutput : true
        default: ["watch", "connect"]

    gruntConfig.connect =
        default:
            options:
                port       : 8000
                hostname   : "localhost"
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
            # mangle     : false
            # beautify   : true
        optional :
            files : 
                "public_html/js/optional.min.js" : [
                    "src/js/optional/three.min.js" 
                    "src/js/optional/spin.js"
                    "src/js/optional/*.js"
                    "src/js/optional/shaders.js"
                    "src/js/optional/main.js"
                ]
        essential:
            files:
                "public_html/js/essential.min.js" : [
                    "src/js/essential/jquery.min.js"
                    "src/js/essential/jquery.leanModal.min.js"
                    "src/js/essential/essential.js"
                ]


    gruntConfig.cssmin =
        all :
            options:
                banner              : "/*! <%= pkg.name %> <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n"
                keepSpecialComments : false
            files :{}

    gruntConfig.cssmin.all.files[gruntConfig.pkg.minified_main_css_file] = [gruntConfig.pkg.compass_output_folder+"/**/*.css"];

    gruntConfig.modernizr =
        dist:
            devFile    : "modernizr.dev.js"
            outputFile : gruntConfig.pkg.js_folder+"/modernizr.js"
            uglify     : true
            files : 
                src: [gruntConfig.pkg.www_folder+"/**/*.js",gruntConfig.pkg.www_folder+"/**/*.css"]
                
            
    gruntConfig.copy =
        include:
            files : [
                {
                    expand : true
                    cwd    : "include/"
                    src    : ["**"]
                    dest   : gruntConfig.pkg.www_folder+"/"
                    dot    : true             
                }
                {
                    expand : true
                    cwd    : "maya/data"
                    src    : ["**"]
                    dest   : gruntConfig.pkg.www_folder+"/maya/data"                
                    dot    : false             
                }
                {
                    expand : true
                    cwd    : "maya/images"
                    src    : ["**"]
                    dest   : gruntConfig.pkg.www_folder+"/maya/images"   
                    dot    : false             
                }
            ]

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
        all:
            options:
                optimizationLevel : 3
                pngquant          : true
                interlaced        : true
                progressive       : true

            files: [
                expand : true
                cwd    : "include/img/"
                src    : ["*.{png,jpg,gif}"]
                dest   : gruntConfig.pkg.www_folder+"/img"
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
                dest : "/home2/danielep"
                host : "danielep@danielepelagatti.com"

    grunt.initConfig(gruntConfig)

    grunt.task.loadTasks("tasks")
    require("load-grunt-tasks")(grunt);

    
    # Default task(s).
    grunt.registerTask("build", ["clean","copy","percolator","compass","glsl_threejs","compile_markdown_files","uglify","cssmin"]);
    grunt.registerTask("deploy", ["build","rsync"]);
    grunt.registerTask("default", ["build","concurrent"]);
