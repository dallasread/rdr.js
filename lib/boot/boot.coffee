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
				attrs[path] = $(this).val()
				r.save attrs
			false
		
		$(@Config.container).on "blur", "[data-rdr-bind-event='blur']", ->
			attrs = {}
			path = $(this).attr("data-rdr-bind-key")
			value = 
			attrs[path] = $(this).val()
			r.save attrs
			false
			
		$(@Config.container).on "click", "[data-rdr-bind-event='click']", ->
			r.executeEvent $(this)
			false
		
		$(@Config.container).on "submit", "[data-rdr-bind-event='submit']", ->
			r.executeEvent $(this)
			false