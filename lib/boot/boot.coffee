RDR = class extends RDR
	createApplicationView: ->
		html = @buildFromTemplate @Templates["/application"], { outlet: "" }, "application"
		$(@Config.container).html html

	Boot: ->
		@Log "App", "Initializing"
		r = @
		
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
				r.fetchPath window.location.hash.replace("#", "")
			
			$(window).trigger "hashchange"
			
		else
			$(@Config.container).on "click", "a[href^='#']", ->
				r.fetchPath $(this).attr("href").replace("#", "")
				false
			
			@fetchPath @currentPath