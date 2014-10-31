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
		r = @
		@DSURL = "https://#{@Config.firebase}.firebaseio.com/"
		@DS = new Firebase @DSURL
		@DS.onAuth (authData) ->
			if authData
				r.Vars.me = {}
				r.Vars.me.key = authData.uid
				r.Vars.me.email = authData.password.email if "password" of authData
			else
				delete r.Vars.currentUserKey
	
	snapshotWithKey: (snapshot, model) ->
		data = snapshot.val()
		data ||= {}
		unless $.isEmptyObject data
			data._key = snapshot.name()
			data._model = model
		data
	
	find: (model, where, variable = false) ->
		r = @
		m = @Models[model]
		supplied_variable = !!variable
		variable = @pluralize model if !variable && !("key" of where)
		variable = model if !variable && "key" of where

		if typeof m != "undefined"
			path = m.dataPath
			path = model if typeof path == "undefined"
			path = Handlebars.compile path
			path = path where
			path = "#{path}/#{where.key}" if "key" of where
			@varChart[variable] = path
			cached = @DSListeners.length && new RegExp(@DSListeners.join("|")).test path
			deferred = @addDeferred()
			
			@DS.child(path).once "value", (snapshot) ->
				r.updateLocalVar variable, r.snapshotWithKey(snapshot, model), true
			
			if cached
				#unless variable of @Vars
				#	local_cached_path = "/#{@pluralize model}"
				#	local_cached_path = "#{local_cached_path}/#{where.id}" if "id" of where
				#	@Vars[variable] = @getLocalVarByPath local_cached_path
				@removeDeferred()
				@Debug "Listeners", "Read From Cache: #{path}"
			else
				@DS.child(path).on "child_changed", (snapshot) ->
					r.updateLocalVar "#{variable}/#{snapshot.name()}", r.snapshotWithKey(snapshot, model)
				
				@DS.child(path).on "child_added", (snapshot) ->
					r.updateLocalVar "#{variable}/#{snapshot.name()}", r.snapshotWithKey(snapshot, model)
        
				@DS.child(path).on "child_removed", (snapshot) ->
					r.deleteLocalVar "#{variable}/#{snapshot.name()}"

				@DSListeners.push path
				@Debug "Listeners", "Added: #{path}"
				
			r.DSDeferred.promise
	
	deletebyPath: (ds_path) ->
		ds_path = @slasherize ds_path
		r = @
		
		@DS.child(ds_path).remove (error) ->
			r.DSCallback "delete", ds_path, false, error
			
			if error
				r.Warn "DS", "Unable to Delete: #{ds_path}"
			else
				r.Log "DS", "Deleted: #{ds_path}"
	
	varPathToDSPath: (path) ->
		slashed_path = @slasherize path
		variable = "#{slashed_path}".split("/")[1]
		pluralize = @pluralize variable
		
		if variable of @varChart
			base_path = @varChart[variable]
		else if pluralize of @varChart
			base_path = @varChart[pluralize]

		if typeof base_path != "undefined"
			"#{base_path}#{slashed_path.split(variable)[1]}"
		else
			false

	delete: (path) ->
		ds_path = @varPathToDSPath path
		@deletebyPath ds_path if ds_path
	
	create: (key, value, callback = false) ->
		path = @varPathToDSPath key
		
		if !path && key of @Models
			m = @Models[@singularize key]
			path = m.dataPath
			path = model if typeof path == "undefined"
			path_args = {}
			
			for k,v of value
				if k[0] == "_"
					delete value[k]
					path_args[k.slice(1)] = v
					
			path = Handlebars.compile path
			path = @slasherize path path_args

		if path
			r = @
			if "key" of value
				path = "#{path}/#{value.key}"
				delete value.key
				@DS.child(path).set value, (error) ->
					r.DSCallback "create", key, value, error
					callback() if typeof callback == "function"
			else
				r.lastInsert = @DS.child(path).push value, (error) ->
					r.DSCallback "create", key, value, error
					callback() if typeof callback == "function"
		else
			@Warn "Vars", "Bad Path: #{key}"
		
	update: (key, value, callback = false) ->
		path = @varPathToDSPath key
		path = key unless path

		if path
			r = @
			@DS.child(path).set value, (error) ->
				r.DSCallback "update", key, value, error
				callback() if typeof callback == "function"
		else
			@Warn "Vars", "Bad Path: #{key}"
	
	DSCallback: (action, path, value, error) ->
		if error
			r = @
			console.log "#{callback}"
			
			@DS.child(path).once "value", (snapshot) ->
				r.updateView path, value
			
			@Warn "DS", "#{@capitalize} Failed: #{value}"