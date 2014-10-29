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
		variable = @pluralModel model if !variable && !("id" of where)
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
					console.log "#{variable}/#{snapshot.name()}"
					r.updateLocalVar "#{variable}/#{snapshot.name()}", snapshot.val()
				
				# @DS.child(path).on "child_added", (snapshot) ->
				# 	r.updateLocalVar "#{variable}/#{snapshot.name()}", snapshot.val()
				# 
				# @DS.child(path).on "child_removed", (snapshot) ->
				# 	r.deleteLocalVar "#{variable}/#{snapshot.name()}"

				@DSListeners.push path
				@Debug "Listeners", "Added: #{path}"
				
			r.DSDeferred.promise
	
	deletebyPath: (ds_path) ->
		r = @
		
		@DS.child(ds_path).remove (error) ->
			r.DSCallback "delete", ds_path, false, error
	
	varPathToDSPath: (path) ->
		variable = path.replace(/\./g, "/").split("/")[0]
		base_path = @varChart[variable]
		if typeof path != "undefined" then "#{base_path}#{path.split(variable)[1]}".replace(/\./g, "/") else false

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
		r = @

		if !error
			d = {}
			d[path] = value
			r.updateLocalVar "", d
			@Log "DS", "#{@capitalize action}d: #{path}"
		else
			@Warn "DS", "#{@capitalize} Failed: #{value}"

			@DS.child(path).once "value", (snapshot) ->
				r.updateView path, value