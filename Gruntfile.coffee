# gruntfile

module.exports = (grunt) ->
  grunt.initConfig

    coffee:
      build:
        expand: yes
        flatten: no
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'

    mochaTest:
      options:
        require: ["coffee-script/register"]
      test:
        src: ["test/**/*.coffee"]

    clean:
      files: ["build", "www/script.js"]

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'default', ['clean', 'coffee', 'mochaTest']
