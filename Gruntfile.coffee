module.exports = (grunt)->
    # Project configuration.    
    debugger

    rewriteModule = require('http-rewrite-middleware');
    meta_marked = require('meta-marked');


    gruntConfig = 
        pkg: grunt.file.readJSON('package.json')

    gruntConfig.jade = {}


    # building jade templates compilation based on markdown files
    isMarkDown = new RegExp("^.*\\.md$");

    # array of different localized page versions indexed by page ID
    languageByPageID = {};
    # array of pages indexed by language code
    pagesByLanguage = {};
    
    grunt.file.recurse "src/markdown",(file)=>
        if isMarkDown.test(file)
            md = grunt.file.read(file);
            # grunt.log.write("Parsing "+md)
            parsed = meta_marked(md);

            if !parsed.meta.lang?
                parsed.meta.lang = "en"

            jadeConfig = gruntConfig.jade[parsed.meta.id+"-"+parsed.meta.lang] =
                options: 
                    pretty : true
                    data : {}
                files : {}

            # jade input template
            input = "src/jade/"+parsed.meta.template;

            # outputh path
            if parsed.meta.permalink?
                permalink = "/"+parsed.meta.lang+"/"+parsed.meta.permalink+"/";
                output = "www/"+parsed.meta.lang+"/"+parsed.meta.permalink+"/index.html";
                base = "../../"
                depth = 2
            else
                permalink = "/"+parsed.meta.lang+"/";
                output = "www/"+parsed.meta.lang+"/index.html";
                base = "../"
                depth = 1


            jadeConfig.files[output] = input;



            jadeConfig.options.data = JSON.parse( JSON.stringify( parsed.meta ) );
            jadeConfig.options.data.content = parsed.html;
            jadeConfig.options.data.link = permalink;
            jadeConfig.options.data.base = base;
            jadeConfig.options.data.depth = depth;

            # create another target with the same configurations if this is the root page
            if parsed.meta.root
                #jadeConfig.files["www/index.html"] = input;
                copyJadeConfig = gruntConfig.jade[parsed.meta.id+"-"+parsed.meta.lang+"-root"] = JSON.parse( JSON.stringify( jadeConfig ) )
                copyJadeConfig.files = {"www/index.html":input}
                copyJadeConfig.options.data.link = "/"
                copyJadeConfig.options.data.base = "./"
                copyJadeConfig.options.data.depth = 0


            if !languageByPageID[parsed.meta.id]
                languageByPageID[parsed.meta.id] = []

            languageByPageID[parsed.meta.id].push
                lang  : parsed.meta.lang
                link  : permalink
                base  : base
                depth : depth
                meta  : parsed.meta

            # sort by date
            languageByPageID[parsed.meta.id].sort (a,b)->
                arr = [a.meta.date,b.meta.date]
                arr.sort()
                if arr.indexOf(a.meta.date) == 0
                    return 1
                return -1

            if !pagesByLanguage[parsed.meta.lang]
                pagesByLanguage[parsed.meta.lang] = []

            pagesByLanguage[parsed.meta.lang].push
                lang  : parsed.meta.lang
                link  : permalink
                base  : base
                depth : depth
                meta  : parsed.meta


            # sort by date
            pagesByLanguage[parsed.meta.lang].sort (a,b)->
                arr = [a.meta.date,b.meta.date]
                arr.sort()
                if arr.indexOf(a.meta.date) == 0
                    return 1
                return -1




    # create links for language versions of the same page
    for targetName of gruntConfig.jade
        target = gruntConfig.jade[targetName];
        target.options.data.languages = languageByPageID[target.options.data.id];
        otherPagesLinks = pagesByLanguage[target.options.data.lang].concat()
        target.options.data.links = otherPagesLinks;

        # if target.options.data.root
        #     rootTarget = gruntConfig.jade[targetName+"-root"] = JSON.parse( JSON.stringify( target ) );
        #     rootTarget.files


    # create json file so that javascript can read it
    grunt.file.delete("www/config.json",{force:true})
    grunt.file.write("www/config.json", JSON.stringify(pagesByLanguage) )

    gruntConfig.uglify =
        options:
            banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'


    gruntConfig.percolator =
        compile:
            source: 'src/coffee'
            output: 'www/js/main.js'
            main: 'main.coffee'
            compile: true

    gruntConfig.compass =
        compile:
            options:
                sassDir:'src/compass'
                cssDir:'www/css'
                outputStyle: 'expanded'

    gruntConfig.glsl_threejs =
        compile:
            files : 
                "www/js/shaders.js" : ["src/glsl/*.vert","src/glsl/*.frag"]

    gruntConfig.watch =
        options:
            livereload: 35729                
        coffee:
            files: ['src/**/*.coffee']
            tasks: ['percolator','uglify:site']
        compass:
            files: ['src/**/*.{scss,sass}']
            tasks: ['compass']
        jade:
            files: ['src/**/*.{jade,md}']
            tasks: ['jade']
        glsl_threejs:
            files: ['src/**/*.{frag,vert}']
            tasks: ['glsl_threejs','uglify:site']
        uglify :
            files: ['src/**/*.js']
            tasks: ['uglify:vendor']
                                
    gruntConfig.concurrent =
        options:
            logConcurrentOutput : true
        default: ['watch', 'connect']

    gruntConfig.connect =
        default:
            options:
                port: 8000
                hostname: "localhost"
                keepalive: true
                livereload: 35729
                base : "www"
                # middleware: (connect, options)->
                #     middlewares = [];

                #     # RewriteRules support
                #     middlewares.push(rewriteModule.getMiddleware([
                #         # rewrite everything not contained in these folders to index.html
                #         {from: '^/(?!css|js|img|maya|test).*$', to: '/index.html'} 
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
            drop_console: true
            # mangle : false
            # beautify : true
        vendor :
            files : 
                "www/js/vendor.min.js" : [
                    "src/js/three.min.js" 
                    "src/js/spin.js" 
                    "src/js/*.js"
                ]
        site : 
            files :
                "www/js/main.min.js" : ["www/js/shaders.js","www/js/main.js"]



    gruntConfig.modernizr =
        dist:
            devFile : "modernizr.dev.js"
            outputFile : "src/js/modernizr.js"
            uglify : false
            files : 
                src: ["www/js/*.js","www/css/*.css"]
                
            



    grunt.initConfig(gruntConfig)

    # Load the plugin that provides the "uglify" task.
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-compass');
    grunt.loadNpmTasks('grunt-contrib-jade');
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-connect');
    grunt.loadNpmTasks('grunt-coffee-percolator-v2');
    grunt.loadNpmTasks('grunt-glsl-threejs');
    grunt.loadNpmTasks('grunt-concurrent');
    grunt.loadNpmTasks('grunt-modernizr');
    
    # Default task(s).
    grunt.registerTask('default', ['concurrent']);
