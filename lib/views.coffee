RDR = class extends RDR
	isLoading: false
	
	markActiveRoutes: (segments) ->
		segments = segments.slice(0).reverse()
		paths = []
		paths.push "a[href='##{@hashPath}']"
		
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
			placer = $(@Config.container).find("[data-rdr-template-outlet='/application']") unless placer.length
			placer.html html
			@markActiveRoutes views
			@Log "Routes", "Resolved: #{current_path}"
	
	generateView: (view_path, placer = "", html = "") ->
		view_path = @slasherize view_path
		@Log "Views", "Fetching: #{view_path}"
	
		if $("[data-rdr-template='#{view_path}']").length && html != ""
			placer = $("[data-rdr-template-outlet='#{view_path}']") unless placer.length
			@Warn "Views", "Already Present: #{view_path}"
		else
			if view_path of @Templates
				Vars = $.extend {}, @synchronousVars
				Vars.Vars = @Vars
				Vars.outlet = html
				html = @buildFromTemplate @Templates[view_path], Vars, view_path
				@Log "Views", "Generated: #{view_path}"
			else
				@Warn "Views", "Not Found: #{view_path}"
		
		[placer, html]
	
	buildFromTemplate: (template, data = {}, path) ->
		path = @slasherize path
		data.outlet = "<div data-rdr-template-outlet=\"#{path}\">#{data.outlet}</div>"
		"<div class=\"rdr-template\" data-rdr-template=\"#{path}\">#{template(data)}</div>"
	
	buildPartial: (template, data = {}, path) ->
		if template of @Templates
			path = @slasherize path
			html = $(@Templates[template] data)
			html.attr "data-rdr-bind-model", path
			html = $("<div>").html(html).html()
			html
		else
			""
	
	updateView: (path, value = false) ->
		path = @slasherize path
		is_model = typeof value == "object"
		
		if !value
			$("[data-rdr-bind-model='#{path}']").remove()
		else
			if is_model
				if $("[data-rdr-bind-model='#{path}']").length
					for k,v of value
						@updateVarOnPage "#{path}/#{k}", v
				else
					if "_parent_key" of value
						placer = $("script[data-rdr-collection-last='#{value._parent_key}']")
						template = placer.attr("data-template")
						value._path = path
						html = @buildPartial template, value, path
						$(html).insertBefore placer
			else
				@updateVarOnPage path, value
	
	updateVarOnPage: (k, v) ->
		$("[data-rdr-bind-html='#{k}']").html v
		$("[data-rdr-bind-key='#{k}']").each ->
			attr = $(this).attr("data-rdr-bind-attr")

			if attr == "value"
				$(this).val v
			else
				$(this).attr attr, v
	
	hideLoading: ->
		$(".rdr-template[data-rdr-template='/loading']").remove()
		@isLoading = false
	
	showLoading: (segments, placer = "", html = "") ->
		segments = segments.slice(1).reverse()
		
		for segment,index in segments
			path = @pathForSegments segments, false, index
			path = @slasherize path
			loading_path = "#{path}/loading".replace(/\/\//g, "/")
			@Log "Loading", "Fetching: #{loading_path}"
			
			if loading_path of @Templates && $("[data-rdr-template-outlet='#{path}']").length
				@Log "Loading", "Found: #{loading_path}"
				placer = $("[data-rdr-template-outlet='#{path}']")
				[placer, html] = @generateView loading_path, placer
				break
		
		unless placer.length
			application_loading_path = "/loading"
			if application_loading_path of @Templates
				@Log "Loading", "Use Application: #{application_loading_path}"
				placer = $(@Config.container).find("[data-rdr-template-outlet='/application']") unless placer.length
				[placer, html] = @generateView application_loading_path, placer, @Templates[application_loading_path]
		
		placer.append html if placer.length