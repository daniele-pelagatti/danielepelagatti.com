'use strict';
meta_marked = require('meta-marked');
chalk = require('chalk');
module.exports = (grunt)->
    grunt.registerMultiTask 'compile_markdown_files', 'Takes Markdown files, returns HTML files', ()->
        

        options = @options
            markdown_folder  : "markdown"
            jade_folder      : "jade"     
            www_folder       : "www"
            default_document : "index.html"
            config_json      : "config.json"
            environment      : "prod"


        globalJadeConfig = {}

        # building jade templates compilation based on markdown files
        isMarkDown = new RegExp("^.*\\.md$");

        # array of different localized page versions indexed by page ID
        languageByPageID = {};
        # array of pages indexed by language code
        pagesByLanguage = {};
        
        grunt.file.recurse options.markdown_folder,(file)=>
            if isMarkDown.test(file)
                md = grunt.file.read(file);
                parsed = meta_marked(md);
                grunt.log.oklns("Markdown File "+chalk.cyan(file)+" parsed")
                debugger;

                if !parsed.meta.lang?
                    parsed.meta.lang = "en"

                jadeConfig = globalJadeConfig[parsed.meta.id+"-"+parsed.meta.lang] =
                    options: 
                        pretty : if options.environment == "prod" then false else true
                        data : {}
                    files : {}

                # jade input template
                input = options.jade_folder+"/"+parsed.meta.template;

                # outputh path
                if parsed.meta.permalink?
                    permalink = "/"+parsed.meta.lang+"/"+parsed.meta.permalink+"/";
                    output    = options.www_folder+"/"+parsed.meta.lang+"/"+parsed.meta.permalink+"/"+options.default_document;
                    base      = "../../"
                    depth     = 2
                else
                    permalink = "/"+parsed.meta.lang+"/";
                    output    = options.www_folder+"/"+parsed.meta.lang+"/"+options.default_document;
                    base      = "../"
                    depth     = 1


                jadeConfig.files[output] = input;



                jadeConfig.options.data             = JSON.parse( JSON.stringify( parsed.meta ) );
                jadeConfig.options.data.content     = parsed.html;
                jadeConfig.options.data.link        = permalink;
                jadeConfig.options.data.base        = base;
                jadeConfig.options.data.depth       = depth;
                jadeConfig.options.data.environment = options.environment;
                # jadeConfig.options.data.videos = if parsed.meta.videos? then JSON.parse(parsed.meta.videos) else null;

                # create another target with the same configurations if this is the root page
                if parsed.meta.root
                    #jadeConfig.files["www/index.html"] = input;
                    copyJadeConfig = globalJadeConfig[parsed.meta.id+"-"+parsed.meta.lang+"-root"] = JSON.parse( JSON.stringify( jadeConfig ) )
                    copyJadeConfig.files = {}
                    copyJadeConfig.files[options.www_folder+"/"+options.default_document] = input
                    
                    copyJadeConfig.options.data.link  = "/"
                    copyJadeConfig.options.data.base  = "./"
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
        for targetName of globalJadeConfig
            target                        = globalJadeConfig[targetName];
            target.options.data.languages = languageByPageID[target.options.data.id];
            otherPagesLinks               = pagesByLanguage[target.options.data.lang].concat()
            target.options.data.links     = otherPagesLinks;

            # if target.options.data.root
            #     rootTarget = globalJadeConfig[targetName+"-root"] = JSON.parse( JSON.stringify( target ) );
            #     rootTarget.files


        # create json file so that javascript can read it
        if grunt.file.exists(options.config_json)
            grunt.file.delete(options.config_json,{force:true})
        grunt.file.write(options.config_json, JSON.stringify(pagesByLanguage) )

        grunt.config.set("jade",globalJadeConfig);
        grunt.task.run("jade")