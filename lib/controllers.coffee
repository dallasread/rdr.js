RDR = class extends RDR
	initControllers: (controllers, call) ->
		initializers = []
		
		for c,index in controllers
			path = @pathForSegments controllers, false, controllers.length - index
			path = "/application" if path == "/"
			@Log "Controllers", "Fetching: #{path}"
			
			if path of @Controllers && call of @Controllers[path]
				initializers.push path
				@Log "Controllers", "Executing: #{path}"

		r = @
		Q.all(initializers.map (c) -> r.Controllers[c][call]())