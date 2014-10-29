RDR = class extends RDR
	isLoading: false
	
	slasherized: (path) ->
		path = "#{path}".replace(/\/|\./g, "/")
		path = path.slice(1) if path[0] == "/"
		path
	
	dotterized: (path) ->
		path = "#{path}".replace(/\/|\-/g, ".")
		path = path.slice(1) if path[0] == "."
		path

	dasherized: (path) ->
		path = "#{path}".replace(/\/|\./g, "-")
		path = path.slice(1) if path[0] == "-"
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
	
		if $(".rdr-template-#{dasherized_path}").length && html != ""
			placer = $(".rdr-template-#{dasherized_path}-outlet") unless placer.length
			@Warn "Views", "Already Present: #{view_path}"
		else
			if view_path of @Templates
				Vars = $.extend {}, @synchronousVars
				Vars.Vars = @Vars
				Vars.outlet = html
				html = @buildFromTemplate @Templates[view_path], Vars, dasherized_path
				@Log "Views", "Generated: #{view_path}"
			else
				@Warn "Views", "Not Found: #{view_path}"
		
		[placer, html]
	
	buildFromTemplate: (template, data = {}, dasherized_path) ->
		data.outlet = "<div class=\"rdr-template-#{dasherized_path}-outlet\">#{data.outlet}</div>"
		"<div class=\"rdr-template rdr-template-#{dasherized_path}\" data-path=\"/#{dasherized_path.replace(/\-/g, "/")}\">#{template(data)}</div>"
	
	buildPartial: (template, data = {}, path) ->
		if template of @Templates
			html = $(@Templates[template] data)
			html.attr "data-rdr-bind-model", path
			html = $("<div>").html(html).html()
			html
		else
			""
	
	updateView: (key, value = false) ->
		key = @slasherized key
		model = typeof value == "object"
		
		if !value
			$("[data-rdr-bind-model='#{key}']").remove()
		else
			if model
				if $("[data-rdr-bind-model='#{key}']").length
					for k,v in value
						@updateVarOnPage k, v
				else
					placer = $("script.rdr-collection-first-#{key.split("/")[0]}")
					template = placer.attr("data-template")
					value._path = key
					html = @buildPartial template, value, key
					$(html).insertAfter placer
			else
				@updateVarOnPage key, value
	
	updateVarOnPage: (k, v) ->
		$("[data-rdr-bind-html='#{k}']").html v
		$("[data-rdr-bind-key='#{k}']").each ->
			attr = $(this).attr("data-rdr-bind-attr")

			if attr == "value"
				$(this).val v
			else
				$(this).attr attr, v
	
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