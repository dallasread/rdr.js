RDR = class extends RDR
	DSListeners: []
	
	synchronousVars: {}
	
	fetchSynchronousVars: ->
		@denormalizeVars true, @vars
	
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
	
	denormalizeVars: (synchronous = false, vars = {}, path = "", initial = true) ->
		if typeof vars == "object"
			global_vars = if synchronous then @synchronousVars else @vars
			
			for k,v of vars
				var_path = ""
				var_path += path
				var_path += "/" if var_path.length
				var_path += k if typeof k != "undefined"
	
				if typeof v == "object"
					@denormalizeVars synchronous, v, var_path, false
				else
					@setLocalVarByPath @vars, var_path, v
					
					if synchronous
						v = "<span data-rdr-bind-html='#{var_path}'>#{v}</span>"
						@setLocalVarByPath @synchronousVars, var_path, v
					else
						$("[data-rdr-bind-html='#{var_path}']").html v
						$("[data-rdr-bind-key='#{var_path}']").each ->
							attr = $(this).attr("data-rdr-bind-attr")
							$(this).attr attr, v
		
		if initial then global_vars else vars
	
	updateLocalVar: (variable, snapshot, synchronous = false) ->
		key = snapshot.name()
		value = snapshot.val()
		path = if synchronous then variable else "#{variable}/#{key}"
		
		if typeof value != "object"
			data = {}
			data[key] = value
			value = data
			path = variable
		
		@denormalizeVars synchronous, value, path
		synchronous.resolve() if synchronous
		
		@Log "Vars", "Set: #{path}"
	
	DSConnect: ->
		@DSURL = "https://#{@Config.firebase}.firebaseio.com/"
		@DS = new Firebase @DSURL
	
	varChart: {}
	
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
					r.updateLocalVar variable, snapshot, deferred
				
				@DS.child(path).on "child_added", (snapshot) ->
					r.updateLocalVar variable, snapshot
					
				@DS.child(path).on "child_changed", (snapshot) ->
					r.updateLocalVar variable, snapshot
				
				@DS.child(path).on "child_removed", (snapshot) ->
					r.updateLocalVar variable, snapshot

				@DSListeners.push path
				@Debug "Listeners", "Added: #{path}"
				
			deferred.promise
	
	getByPath: (obj, desc) ->
		obj = obj or window
		arr = desc.split(".")
		while arr.length
			obj = obj[arr.shift()]
		obj
			
	setLocalVarByPath: (obj, path, value) ->
		path = path.replace(/\//g, ".")
		pList = path.split(".")
		len = pList.length
		i = 0

		while i < len - 1
			elem = pList[i]
			obj[elem] = {}	unless obj[elem]
			obj = obj[elem]
			i++
			
		obj[pList[len - 1]] = value