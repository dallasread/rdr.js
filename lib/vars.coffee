RDR = class extends RDR
	varChart: {}
	linkedVars: {}
	synchronousVars: {}
	
	fetchSynchronousVars: ->
		@prepareVars "", @Vars, true
	
	applyVars: (parent_key = "", parent_value = {}, synchronous = false) ->
		for key,value of parent_value
			var_key = ""
			var_key += parent_key
			var_key += "/" if var_key.length
			var_key += key

			if typeof value == "object"
				value._key = key
				value._path = @slasherize var_key
				value._parent_key = @slasherize parent_key
				model = @singularize @dotterize parent_key
				
				# HAS MANY FAIL
				# if model of @Models && "fields" of @Models[model]
				# 	for k,v of @Models[model].fields
				# 		if v == "has_many"
				# 			model_name = @singularize(k)
				# 			where = {}
				# 			where[model] = key
				# 			where["chatbox"] = "k34j3-dfkj3ldf-3rkjf"
				# 			@find model_name, where, "#{var_key}.#{k}"
							
				@prepareVars var_key, value, synchronous
			else
				@addDeferred() if synchronous
				@setLocalVarByPath @Vars, var_key, value
				value = "<span data-rdr-bind-html='#{var_key}'>#{value}</span>"
				@addDeferred() if synchronous
				@setLocalVarByPath @synchronousVars, var_key, value
		
		if synchronous then @DSDeferred.promise else true
	
	prepareVars: (parent_key = "", parent_value = {}, synchronous = false) ->
		parent_key = @slasherize parent_key
		
		if @setLocalVarByPath @Vars, parent_key, {}
			if @setLocalVarByPath @synchronousVars, parent_key, {}

				if !synchronous && parent_key.replace(/\//g, "").length && typeof parent_value == "object"
					parent_value._path = parent_key
					parent_value._parent_key = parent_value._path.substr 0, parent_value._path.lastIndexOf("/")

				if @applyVars parent_key, parent_value, synchronous
					if synchronous
						@removeDeferred()
						@synchronousVars
					else
						@updateView parent_key, parent_value
						@Vars
	
	updateLocalVar: (path, value, synchronous = false) ->
		@prepareVars path, value, synchronous
		@Log "Vars", "Set: #{path}"
		@DSDeferred.promise if synchronous
	
	deleteLocalVarByPath: (path) ->
		path = @dotterize "#{path}"
		path = @getLocalVarByPath path
		@deleteLocalVar path
	
	deleteLocalVar: (path_str) ->
		path_str = @dotterize "#{path_str}"
		d = "delete this.Vars"
		for p in path_str.split(".")
			d += "[\"#{p}\"]"
		eval d
		eval d.replace("this.Vars", "this.synchronousVars")
		@updateView path_str
	
	getLocalVarByPath: (path_str, clone = true) ->
		fail = false
		o = ""
		path_str = @dotterize path_str
		path = path_str.split(".")
		vars = if clone then $.extend {}, @Vars else @Vars

		for p in path
			if typeof vars == "object" && p of vars
				vars = vars[p]
			else
				fail = true
				break

		if fail then null else vars
			
	setLocalVarByPath: (obj, path_str, value) ->
		path_str = @dotterize path_str
		path = path_str.split(".")
		pList = path
		len = pList.length
		i = 0

		while i < len - 1
			elem = pList[i]
			obj[elem] = {} unless obj[elem]
			obj = obj[elem]
			i++

		@removeDeferred()
		obj[pList[len - 1]] = value