module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON("package.json"),
		coffee: {
			compileJoined: {
				options: {
					bare: true,
					join: true
				},
				files: {
					"tmp/rdr.js": [
						"lib/init.coffee",
						"lib/*.coffee",
						"lib/boot/*.coffee"
					],
				}
	    }
	  },
    concat: {
      js: {
				options: {
					banner: "/*! <%= pkg.name %> <%= pkg.version %> (Development) compiled on <%= grunt.template.today('yyyy-mm-dd') %> */\n",
				},
				files: {
					"../vendor/js/rdr.js": [
						"vendor/*.js",
						"tmp/rdr.js"
					]
				}
      }
    },
    uglify: {
      js: {
				options: {
					banner: "/*! <%= pkg.name %> <%= pkg.version %> compiled on <%= grunt.template.today('yyyy-mm-dd') %> */\n",
				},
				files: {
					"rdr.min.js": ["../vendor/js/rdr.js"]
				}
      }
    },
		watch: {
			vendor_js: {
		    files: ["vendor/*"],
		    tasks: ["uglify"]
		  },
		  js: {
		    files: ["lib/**/*"],
		    tasks: ["js"]
		  }
		}
  });

  grunt.loadNpmTasks("grunt-contrib-uglify");
	grunt.loadNpmTasks("grunt-contrib-coffee");
	grunt.loadNpmTasks("grunt-contrib-watch");
	grunt.loadNpmTasks("grunt-contrib-concat");
	
	grunt.registerTask("default", ["js"]);
	grunt.registerTask("js", ["coffee", "concat"]);
	grunt.registerTask("build", ["js", "uglify"]);

};