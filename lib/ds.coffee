RDR = class extends RDR
	DSListeners: []
	
	DSConnect: ->
		@DSURL = "https://#{@Config.firebase}.firebaseio.com/"
		@DS = new Firebase @DSURL
	
	find: (model, where, variable = false) ->
		r = @
		m = @Models[model]
		variable = @pluralModel model unless variable

		if typeof m != "undefined"
			path = m.dataPath
			path = model if typeof path == "undefined"
			path = Handlebars.compile path
			path = path where
			path = "#{path}/#{where.id}" if "id" of where
			@varChart[variable] = path
			cached = false
			
			deferred = Q.defer()

			if @DSListeners.length && new RegExp(@DSListeners.join("|")).test path
				deferred.resolve()
				@Debug "Listeners", "Read From Cache: #{path}"
			else
				@DS.child(path).once "value", (snapshot) ->
					r.updateLocalVar variable, snapshot.val(), deferred
				
				@DS.child(path).on "child_added", (snapshot) ->
					r.updateLocalVar "#{variable}/#{snapshot.name()}", snapshot.val()
					
				@DS.child(path).on "child_changed", (snapshot) ->
					r.updateLocalVar "#{variable}/#{snapshot.name()}", snapshot.val()
				
				@DS.child(path).on "child_removed", (snapshot) ->
					r.updateLocalVar "#{variable}/#{snapshot.name()}", snapshot.val()

				@DSListeners.push path
				@Debug "Listeners", "Added: #{path}"
				
			deferred.promise
		
		save: (attrs) ->
				r = @
		
				for k,v of attrs
					variable = k.split("/")[0]
					path = @varChart[variable]

					if typeof path != "undefined"
						path = "#{path}#{k.split(variable)[1]}"
						r.DS.child(path).set v, (error) ->
							if !error
								r.vars[k.replace(/\//, ".")] = v
								r.synchronousVars[k.replace(/\//, ".")] = v
								r.Log "Vars", "Saved: #{path}"
							else
								r.Warn "Vars", "Permission Denied: #{v}"
		
								r.DS.child(path).once "value", (snapshot) ->
									value = snapshot.val()
									$("[data-rdr-bind-html='#{k}']").html value
									$("[data-rdr-bind-key='#{k}']").each ->
										attr = $(this).attr("data-rdr-bind-attr")
										if attr == "value" then $(this).val value else $(this).attr attr, value
					else
						r.Warn "Vars", "Unable to Save: #{k}"