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
    
    grunt.file.recurse gruntConfig.pkg.markdown_folder,(file)=>
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
            input = gruntConfig.pkg.jade_folder+"/"+parsed.meta.template;

            # outputh path
            if parsed.meta.permalink?
                permalink = "/"+parsed.meta.lang+"/"+parsed.meta.permalink+"/";
                output = gruntConfig.pkg.www_folder+"/"+parsed.meta.lang+"/"+parsed.meta.permalink+"/"+gruntConfig.pkg.default_document;
                base = "../../"
                depth = 2
            else
                permalink = "/"+parsed.meta.lang+"/";
                output = gruntConfig.pkg.www_folder+"/"+parsed.meta.lang+"/"+gruntConfig.pkg.default_document;
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
                copyJadeConfig.files = {}
                copyJadeConfig.files[gruntConfig.pkg.www_folder+"/"+gruntConfig.pkg.default_document] = input
                
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
    grunt.file.delete(gruntConfig.pkg.www_folder+"/"+gruntConfig.pkg.config_json,{force:true})
    grunt.file.write(gruntConfig.pkg.www_folder+"/"+gruntConfig.pkg.config_json, JSON.stringify(pagesByLanguage) )

    gruntConfig.percolator =
        compile:
            source: gruntConfig.pkg.coffee_folder
            output: gruntConfig.pkg.www_folder+"/"+gruntConfig.pkg.compiled_js
            main: gruntConfig.pkg.percolator_main
            compile: true

    gruntConfig.compass =
        compile:
            options:
                sassDir: gruntConfig.pkg.compass_folder
                cssDir: gruntConfig.pkg.www_folder+'/'+gruntConfig.pkg.compass_output_folder
                outputStyle: 'expanded'

    gruntConfig.glsl_threejs =
        compile:
            files : {}
    gruntConfig.glsl_threejs.compile.files[gruntConfig.pkg.www_folder+'/'+gruntConfig.pkg.glsl_output_file] = [gruntConfig.pkg.glsl_folder+"/*.vert",gruntConfig.pkg.glsl_folder+"/*.frag"]
            

    gruntConfig.watch =
        options:
            livereload: 35729                
        coffee:
            files: [gruntConfig.pkg.watch_folder+'/**/*.coffee']
            tasks: ['percolator','uglify:site']
        compass:
            files: [gruntConfig.pkg.watch_folder+'/**/*.{scss,sass}']
            tasks: ['compass','cssmin']
        jade:
            files: [gruntConfig.pkg.watch_folder+'/**/*.{jade,md}']
            tasks: ['jade']
        glsl_threejs:
            files: [gruntConfig.pkg.watch_folder+'/**/*.{frag,vert}']
            tasks: ['glsl_threejs','uglify:site']
        uglify :
            files: [gruntConfig.pkg.watch_folder+'/**/*.js']
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
            banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
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
            files : {}
                # "www/js/main.min.js" : ["www/js/shaders.js","www/js/main.js"]

    gruntConfig.uglify.site.files[gruntConfig.pkg.www_folder+"/"+gruntConfig.pkg.minified_main_js_file] = [gruntConfig.pkg.www_folder+"/"+gruntConfig.pkg.glsl_output_file,gruntConfig.pkg.www_folder+"/"+gruntConfig.pkg.compiled_js]


    gruntConfig.cssmin =
        all :
            options:
                keepSpecialComments : false
            files :{}

    gruntConfig.cssmin.all.files[gruntConfig.pkg.www_folder+"/"+gruntConfig.pkg.minified_main_css_file] = [gruntConfig.pkg.www_folder+"/"+gruntConfig.pkg.minified_main_css_input_file];

    gruntConfig.modernizr =
        dist:
            devFile : "modernizr.dev.js"
            outputFile : gruntConfig.pkg.js_folder+"/modernizr.js"
            uglify : true
            files : 
                src: [gruntConfig.pkg.www_folder+"/**/*.js",gruntConfig.pkg.www_folder+"/**/*.css"]
                
            



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
    grunt.loadNpmTasks('grunt-contrib-cssmin');
    
    # Default task(s).
    grunt.registerTask('default', ['concurrent']);
