RDR = class extends RDR
	currentPath: "/"
	
	buildFromTemplate: (template, data = {}, dasherized_path) ->
		data.outlet = "<div class=\"rdr-template-#{dasherized_path}-outlet\">#{data.outlet}</div>"
		"<div class=\"rdr-template-#{dasherized_path}\">#{template(data)}</div>"

	findViews: (views, callback = false) ->
		views_path = views.join("/")
		view_paths = []
		views = views.reverse()
		html = ""
		placer = []
		
		for view,index in views
			path = views.slice(0)
			path = path.splice index, path.length
			path = path.reverse()
			view_path = "/#{path.join("/")}"
			dasherized_path = path.join("-")
			view_paths.push view_path
			
			@Log "Views", "Fetching: #{view_path}"
			
			if $(".rdr-template-#{dasherized_path}").length
				@Warn "Views", "Already Present: #{view_path}"
				placer = $(".rdr-template-#{dasherized_path}-outlet") unless placer.length 
			else
				if view_path of @Templates
					html = @buildFromTemplate @Templates[view_path], { outlet: html }, dasherized_path
					@Log "Views", "Generated: #{view_path}"
				else
					@Warn "Views", "Not Found: #{view_path}"

		placer = $(@Config.container).find(".rdr-template-application-outlet") unless placer.length
		placer.html html
		@Log "Views", "Resolved: /#{views_path}"
		callback @Config.container, view_paths if typeof callback == "function"
		
	fetchPath: (path) ->
		@Debug "Router", "Fetching: #{path}"
		segments = @findRoute path
		new_path = "/#{segments.join("/")}"
		
		if new_path == @currentPath
			@Debug "Router", "Already Active: #{path}"
		else
			@currentPath = new_path
			@Debug "Router", "Found: #{new_path}"
			@findViews segments, @markActiveRoutes
	
	markActiveRoutes: (c, view_paths) ->
		$(c).find("a.active").removeClass "active"
		for p in view_paths
			$(c).find("a[href='##{p}']").addClass "active"
	
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