RDR = class extends RDR
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
			
			@DS.child(path).once "value", (snapshot) ->
				val = snapshot.val()
				val.id = where.id if "id" of where
				r.vars[v] = val
				r.Log "Vars", "Setting: #{v}"
				deferred.resolve()
				
			deferred.promise
			
	