RDR = class extends RDR
	currentPath: "/"
	
	buildRoute: (segments) ->
		r = @
		
		Q.allSettled( @initControllers segments ).then ->
			r.generateViews segments.slice(0).reverse()
			r.isLoading = false
		
	pathForSegments: (pieces, reverse = false, index = 0) ->
		segments = pieces.slice(0)
		segments.reverse() if reverse
		segments.splice segments.length - index, segments.length
		"/#{segments.join("/")}".replace("//", "/")
		
	fetchPath: (path) ->
		r = @
		@Log "Router", "Fetching: #{path}"
		segments = @findRoute path
		routes = segments.slice(0).reverse()
		new_path = "/#{segments.join("/")}"
		@markActiveRoutes routes
		@showLoading routes
	
		if new_path == @currentPath
			@Log "Router", "Already Active: #{path}"
		else
			@currentPath = new_path
			@Log "Router", "Found: #{new_path}"
			@buildRoute segments
	
	findRoute: (path, pristine = true, selected_path = [], routes = {}) ->
		path = path.slice 1 if path[0] == "/"
		routes = @Routes if pristine
		
		unless path.length
			selected_path.push "index"
		else
			folders = path.split("/")
	
			for route,children of routes
				route = route.replace("/", "")
	
				if route == folders[0]
					selected_path.push route
					path = path.slice route.length
					if typeof children == "object"
						@findRoute path, false, selected_path, children
					break
					false

		selected_path.push "index" if selected_path[selected_path.length - 1] != "index"
		selected_path