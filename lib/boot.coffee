RDR = class extends RDR
	createTemplates: ->
		html = @buildFromTemplate @Templates["/application"], { outlet: "" }, "application"
		$(@Config.container).html html

	Boot: ->
		@Log "App", "Initializing"
		
		for init,index in @Initializers
			@Warn "Booter", "Initializer Executing: ##{index}"
			init() if typeof init == "function"
		
		@Debug "Booter", "Booting"
		@createTemplates()
		FastClick.attach document.body
		r = @
		
		if /\#|hash/.test(@Config.history)
			@Log "Booter", "RDR History is Now: #"
			
			@Config.history = "#"
			window.location.hash = "#/" if window.location.hash == ""
			
			$(window).bind "hashchange", ->
				r.fetchPath window.location.hash.replace("#", "")
			$(window).trigger "hashchange"
			
		else
			$(@Config.container).on "click", "a[href^='#']", ->
				unless r.Config.history == "#"
					r.fetchPath $(this).attr("href").replace("#", "")
					false
			
			@fetchPath @currentPath