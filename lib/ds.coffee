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
				
				@DS.child(path).on "child_removed", (snapshot) ->
					r.deleteLocalVar "#{variable}/#{snapshot.name()}"

				@DSListeners.push path
				@Debug "Listeners", "Added: #{path}"
				
			deferred.promise
	
	deletebyPath: (path) ->
		r = @
		
		@DS.child(path).remove (error) ->
			r.DSCallback "delete", path, false, error
	
	varPathToDSPath: (path) ->
		variable = path.split("/")[0]
		base_path = @varChart[variable]
		if typeof path != "undefined" then "#{base_path}#{path.split(variable)[1]}" else false

	delete: (data) ->
		path = @varPathToDSPath data._path
		@deletebyPath path if path
	
	create: (key, value) ->
		path = @varPathToDSPath key

		if path
			r = @
			@DS.child(path).push value, (error) ->
				r.DSCallback "update", path, value, error
		else
			@Warn "Vars", "Bad Path: #{key}"
		
	update: (key, value) ->
		path = @varPathToDSPath key

		if path
			r = @
			@DS.child(path).set value, (error) ->
				r.DSCallback "update", path, value, error
		else
			@Warn "Vars", "Bad Path: #{key}"
	
	capitalize: (str) ->
		"#{str}".charAt(0).toUpperCase() + "#{str}".slice(1)
	
	DSCallback: (action, path, value, error) ->
		r = @

		if !error
			@setLocalVarByPath @vars, path, value
			@Log "DS", "#{@capitalize action}d: #{path}"
		else
			@Warn "DS", "#{@capitalize} Failed: #{value}"

			@DS.child(path).once "value", (snapshot) ->
				r.updateView key, value