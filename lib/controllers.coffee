RDR = class extends RDR
	initControllers: (controllers) ->
		initializers = []
		
		for c,index in controllers
			path = @pathForSegments controllers, false, controllers.length - index
			path = "/application" if path == "/"
			@Log "Controllers", "Fetching: #{path}"
			
			if path of @Controllers && "init" of @Controllers[path]
				initializers.push path

		r = @
		Q.all(initializers.map (c) -> r.Controllers[c].init())