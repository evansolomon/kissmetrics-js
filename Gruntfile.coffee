module.exports = ( grunt ) ->

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-exec'

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

      dist:
        src  : 'lib/kissmetrics.js'
        dest : 'lib/kissmetrics.js'

    uglify:
      options:
        banner: '<%= meta.banner %>'
      dist:
        src  : 'lib/kissmetrics.js'
        dest : 'lib/kissmetrics.min.js'

    coffee:
      options:
        sourceMap: true
      compile:
        files:
          'lib/kissmetrics.js' : 'src/kissmetrics.coffee'

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

  grunt.registerTask 'mocha', 'Run mocha unit tests.', ->
    done = @async()
    mocha =
      cmd: 'mocha'
      args: ['--compilers','coffee:coffee-script','--colors','--reporter','spec']
    grunt.util.spawn mocha, (error, result) ->
      if error
        grunt.log.ok( result.stdout ).error( result.stderr ).writeln()
        done new Error('Error running mocha unit tests.')
      else
        grunt.log.ok( result.stdout ).writeln()
        done()

  # Default task.
  grunt.registerTask 'default', ['coffeelint', 'coffee', 'concat', 'uglify', 'exec', 'mocha']