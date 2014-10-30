RDR = class extends RDR
	DSListeners: []
	deferCount: 0
	
	removeDeferred: ->
		if @deferCount > 0
			@deferCount -= 1
			@DSDeferred.resolve() if @deferCount == 0
	
	addDeferred: ->
		@DSDeferred = Q.defer() if @deferCount == 0
		@deferCount += 1
	
	DSConnect: ->
		@DSURL = "https://#{@Config.firebase}.firebaseio.com/"
		@DS = new Firebase @DSURL
	
	find: (model, where, variable = false) ->
		r = @
		m = @Models[model]
		variable = @pluralize model if !variable && !("id" of where)
		variable = model if !variable && "id" of where

		if typeof m != "undefined"
			path = m.dataPath
			path = model if typeof path == "undefined"
			path = Handlebars.compile path
			path = path where
			path = "#{path}/#{where.id}" if "id" of where
			@varChart[variable] = path
			cached = @DSListeners.length && new RegExp(@DSListeners.join("|")).test path
			deferred = @addDeferred()
			
			@DS.child(path).once "value", (snapshot) ->
				r.updateLocalVar variable, snapshot.val(), true
				
			if cached					
				@Debug "Listeners", "Read From Cache: #{path}"
			else
				@DS.child(path).on "child_changed", (snapshot) ->
					r.updateLocalVar "#{variable}/#{snapshot.name()}", snapshot.val()
				
				@DS.child(path).on "child_added", (snapshot) ->
					r.updateLocalVar "#{variable}/#{snapshot.name()}", snapshot.val()
        
				@DS.child(path).on "child_removed", (snapshot) ->
					r.deleteLocalVar "#{variable}/#{snapshot.name()}"

				@DSListeners.push path
				@Debug "Listeners", "Added: #{path}"
				
			r.DSDeferred.promise
	
	deletebyPath: (ds_path) ->
		ds_path = @slasherized ds_path
		r = @
		
		@DS.child(ds_path).remove (error) ->
			r.DSCallback "delete", ds_path, false, error
	
	varPathToDSPath: (path) ->
		slashed_path = @slasherized path
		variable = "#{slashed_path}".split("/")[1]
		pluralized = @pluralize variable
		
		if variable of @varChart
			base_path = @varChart[variable]
		else if pluralized of @varChart
			base_path = @varChart[pluralized]

		if typeof base_path != "undefined" then "#{base_path}#{slashed_path.split(variable)[1]}" else false

	delete: (data) ->
		ds_path = @varPathToDSPath data._path
		@deletebyPath ds_path if ds_path
	
	create: (key, value) ->
		path = @varPathToDSPath key

		if path
			r = @
			@lastCreate = @DS.child(path).push value, (error) ->
				r.DSCallback "create", key, value, error
		else
			@Warn "Vars", "Bad Path: #{key}"
		
	update: (key, value) ->
		path = @varPathToDSPath key
		path = key unless path

		if path
			r = @
			@DS.child(path).set value, (error) ->
				r.DSCallback "update", key, value, error
		else
			@Warn "Vars", "Bad Path: #{key}"
	
	capitalize: (str) ->
		"#{str}".charAt(0).toUpperCase() + "#{str}".slice(1)
	
	DSCallback: (action, path, value, error) ->
		if error
			r = @
			
			@DS.child(path).once "value", (snapshot) ->
				r.updateView path, value
			
			@Warn "DS", "#{@capitalize} Failed: #{value}"