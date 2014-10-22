RDR = class extends RDR
	isLoading: false

	dasherized: (path) ->
		path = path.slice(1) if path[0] == "/"
		path = path.replace(/\//g, "-")
		path
	
	markActiveRoutes: (segments) ->
		segments = segments.slice(0).reverse()
		paths = []
		
		for segment,index in segments
			path = @pathForSegments segments, false, index
			paths.push "a[href='##{path}']"
		
		container = $(@Config.container)
		container.find("a.active").removeClass "active"
		container.find( paths.join(", ") ).addClass "active"
		
	generateViews: (views, placer = "", html = "") ->
		current_path = "/#{views.slice(0).reverse().join("/")}"
		
		for view,index in views
			path = @pathForSegments views, true, index
			[placer, html] = @generateView path, placer, html
		
		if @currentPath != current_path
			@Log "Routes", "Resolved, but No Longer Relevant: #{current_path}"
		else
			placer = $(@Config.container).find(".rdr-template-application-outlet") unless placer.length
			placer.html html
			@markActiveRoutes views
			@Log "Routes", "Resolved: #{current_path}"
	
	generateView: (view_path, placer = "", html = "") ->
		dasherized_path = @dasherized view_path
		@Log "Views", "Fetching: #{view_path}"
	
		if $(".rdr-template-#{dasherized_path}").length
			placer = $(".rdr-template-#{dasherized_path}-outlet") unless placer.length
			@Warn "Views", "Already Present: #{view_path}"
		else
			if view_path of @Templates
				vars = $.extend {}, @synchronousVars
				vars.vars = @vars
				vars.outlet = html
				html = @buildFromTemplate @Templates[view_path], vars, dasherized_path
				@Log "Views", "Generated: #{view_path}"
			else
				@Warn "Views", "Not Found: #{view_path}"
		
		[placer, html]
	
	buildFromTemplate: (template, data = {}, dasherized_path) ->
		data.outlet = "<div class=\"rdr-template-#{dasherized_path}-outlet\">#{data.outlet}</div>"
		"<div class=\"rdr-template rdr-template-#{dasherized_path}\" data-path=\"/#{dasherized_path.replace(/\-/g, "/")}\">#{template(data)}</div>"
	
	updateView: (key, value) ->
		$("[data-rdr-bind-html='#{key}']").html value
		$("[data-rdr-bind-key='#{key}']").each ->
			attr = $(this).attr("data-rdr-bind-attr")

			if attr == "value"
				$(this).val value
			else
				$(this).attr attr, value
	
	showLoading: (segments, placer = "", html = "") ->
		segments = segments.slice(1).reverse()
		
		for segment,index in segments
			path = @pathForSegments segments, false, index
			loading_path = "#{path}/loading".replace(/\/\//g, "/")
			dasherized_path = @dasherized path
			@Debug "Loading", "Fetching: #{path}"
			@Debug "Loading", "Load Path: #{loading_path}"
			
			if loading_path of @Templates && $(".rdr-template-#{dasherized_path}-outlet").length
				@Log "Loading", "Found: #{loading_path}"
				placer = $(".rdr-template-#{dasherized_path}-outlet")
				[placer, html] = @generateView loading_path, placer
				break
		
		unless placer.length
			application_loading_path = "/loading"
			if application_loading_path of @Templates
				@Debug "Loading", "Use Application: #{application_loading_path}"
				placer = $(@Config.container).find(".rdr-template-application-outlet") unless placer.length
				[placer, html] = @generateView application_loading_path, placer, @Templates[application_loading_path]
		
		placer.append html if placer.length