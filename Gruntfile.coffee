module.exports = ( grunt ) ->

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-exec'
  grunt.loadNpmTasks 'grunt-casperjs'
  grunt.loadNpmTasks 'grunt-contrib-connect'

  # Project configuration.
  grunt.initConfig
    meta:
      banner: """
        /**
         * Kissmetrics JS
         * https://github.com/evansolomon/kissmetrics-js
         * Copyright (c) <%= grunt.template.today("yyyy") %>
         * Evan Solomon; Licensed MIT
         */


        """

    concat:
      options:
        banner: '<%= meta.banner %>'

      # This seemingly-useless concatenation is used to prepend the banner
      dist:
        src  : 'lib/kissmetrics.js'
        dest : 'lib/kissmetrics.js'

    uglify:
      options:
        banner      : '<%= meta.banner %>'
        sourceMapIn : 'lib/kissmetrics.map'
        sourceMap   : 'min/kissmetrics.min.map'
      dist:
        src  : 'lib/kissmetrics.js'
        dest : 'min/kissmetrics.min.js'

    coffee:
      options:
        sourceMap: true
      compile:
        files:
          'lib/kissmetrics.js' : ['src/kissmetrics.coffee', 'src/kissmetrics-anon.coffee']

    watch:
      scripts:
        files   : ['src/**/*.coffee', 'Gruntfile.coffee']
        tasks   : ['default']
        options :
          interrupt: true

      tests:
        files : ['test/**/*.coffee']
        tasks : 'mocha'

    coffeelint:
      files   : 'src/**/*.coffee'
      options :
        no_tabs             : {level: 'ignore'}
        no_empty_param_list : {level: 'error'}
        indentation         : {level: 'ignore'}  # Indentation linting is buggy https://github.com/clutchski/coffeelint/issues/4

    exec:
      docco:
        cmd: 'docco src/*.coffee -o docs'

    casperjs:
      files: ['test/casperjs/**/*.coffee']

    connect:
      server:
        options:
          port: 9000
          base: 'test'


  # Default task.
  grunt.registerTask 'default', ['coffeelint', 'coffee', 'concat', 'uglify', 'exec', 'test']

  # Helper tasks
  grunt.registerTask 'build', ['coffee', 'concat', 'uglify']
  grunt.registerTask 'docs', ['exec:docco']
  grunt.registerTask 'test', ['mocha', 'connect', 'casperjs']

  # Mocha task
  grunt.registerTask 'mocha', 'Run mocha unit tests.', ->
    done = @async()
    mocha =
      cmd: 'mocha'
      args: ['test/mocha', '--compilers','coffee:coffee-script','--colors','--reporter','spec']
    grunt.util.spawn mocha, (error, result) ->
      if error
        grunt.log.ok( result.stdout ).error( result.stderr ).writeln()
        done new Error('Error running mocha unit tests.')
      else
        grunt.log.ok( result.stdout ).writeln()
        done()
