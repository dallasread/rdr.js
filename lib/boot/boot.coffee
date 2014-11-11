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
		
		@DSConnect ->
			FastClick.attach document.body
			r.handlebarsHelpers()
			r.createApplicationView()
			r.Events()
		
			if /\#|hash/.test(r.Config.history)
				r.Log "Booter", "RDR History is Now: #"
				r.Config.history = "#"
			
				$(window).bind "hashchange", ->
					r.fetchPath window.location.hash.replace(/\#/g, "")
			
				if window.location.hash == ""
					window.location.hash = "##{r.currentPath}"
				else
					$(window).trigger "hashchange"
			
			else
				$(r.Config.container).on "click", "a[href^='#']", ->
					r.fetchPath $(this).attr("href").replace(/\#/g, "")
					false
			
				r.fetchPath r.currentPath

			r.DSDeferred.promise