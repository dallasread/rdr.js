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
		@Events()
		FastClick.attach document.body
		
		if /\#|hash/.test(@Config.history)
			@Log "Booter", "RDR History is Now: #"
			@Config.history = "#"
			
			$(window).bind "hashchange", ->
				r.fetchPath window.location.hash.replace(/\#/g, "")
			
			if window.location.hash == ""
				window.location.hash = "#/"
			else
				$(window).trigger "hashchange"
			
		else
			$(@Config.container).on "click", "a[href^='#']", ->
				r.fetchPath $(this).attr("href").replace(/\#/g, "")
				false
			
			@fetchPath @currentPath