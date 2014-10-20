RDR = class extends RDR
	DSListeners: []
	
	DSConnect: ->
		@DS = new Firebase "https://#{@Config.firebase}.firebaseio.com/"
	
	find: (model, where, v = false) ->
		r = @
		m = @Models[model]
		v = @pluralModel model unless v

		if typeof m != "undefined"
			path = m.dataPath
			path = model if typeof path == "undefined"
			path = Handlebars.compile path
			path = path where
			path = "#{path}/#{where.id}" if "id" of where
			
			deferred = Q.defer()
			
			if $.inArray(path, @DSListeners) != -1
				deferred.resolve()
				@Debug "Listeners", "Already Listening: #{path}"
			else
				listener = @DS.child(path).on "value", (snapshot) ->
					id = snapshot.name()
					val = snapshot.val()
					path = "#{snapshot.ref()}".replace("https://#{r.Config.firebase}.firebaseio.com/", "")
					r.vars[v] = val
					r.Log "Vars", "Setting: #{v}"
					$("[data-rdr-var='#{path}']").html val
					deferred.resolve()

				@DSListeners.push path
				@Debug "Listeners", "Added: #{path}"
				
			deferred.promise
			
	