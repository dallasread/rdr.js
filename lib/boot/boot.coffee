RDR = class extends RDR
	createApplicationView: ->
		html = @buildFromTemplate @Templates["/application"], { outlet: "" }, "application"
		$(@Config.container).html html

	Boot: ->
		@Log "App", "Initializing"
		r = @
		
		@handlebarsHelpers()
		
		for init,index in @Initializers
			@Warn "Booter", "Initializer Executing: ##{index + 1}"
			init() if typeof init == "function"
		
		@Log "Booter", "Booting"
		
		@createApplicationView()
		@DSConnect()
		FastClick.attach document.body
		
		if /\#|hash/.test(@Config.history)
			@Log "Booter", "RDR History is Now: #"
			@Config.history = "#"
			window.location.hash = "#/" if window.location.hash == ""
			
			$(window).bind "hashchange", ->
				r.fetchPath window.location.hash.replace(/\#/g, "")
			
			$(window).trigger "hashchange"
			
		else
			$(@Config.container).on "click", "a[href^='#']", ->
				r.fetchPath $(this).attr("href").replace(/\#/g, "")
				false
			
			@fetchPath @currentPath
		
		$(@Config.container).on "saveAttrs", "form", ->
			$(this).find("[data-rdr-bind-key]").each ->
				attrs = {}
				path = $(this).attr("data-rdr-bind-key")
				value = $(this).val()
				attrs[path] = value
				r.save attrs
			false
		
		$(@Config.container).on "submit", "[data-rdr-bind-event='submit']", ->
			form = $(this)
			path = ""
			found = false
			event = $(this).attr("data-rdr-bind-action")
			
			$(this).parents(".rdr-template").each ->
				path = $(this).attr("data-path")
				
				if path of r.Controllers && "actions" of r.Controllers[path] && event of r.Controllers[path]["actions"]
					found = true
					r.Controllers[path]["actions"][event] form
					false
					
			r.Log "Events", "No Function Found: #{event}" unless found
			false