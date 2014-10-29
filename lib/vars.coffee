RDR = class extends RDR
	varChart: {}
	synchronousVars: {}
	
	fetchSynchronousVars: ->
		@prepareVars "", @Vars, true
	
	prepareVars: (parent_key = "", parent_value = {}, synchronous = false) ->
		for key,value of parent_value
			var_key = ""
			var_key += parent_key
			var_key += "/" if var_key.length
			var_key += key

			if typeof value == "object"
				value._path = var_key
				# value._key = key
				value._parent_key = parent_key
				@prepareVars var_key, value, synchronous
			else
				@setLocalVarByPath @Vars, var_key, value
				@updateView var_key, value unless synchronous
				value = "<span data-rdr-bind-html='#{var_key.replace(/\//g, ".")}'>#{value}</span>"
				@setLocalVarByPath @synchronousVars, var_key, value
		
		if synchronous
			@removeDeferred()
			@synchronousVars
		else
			@Vars
	
	updateLocalVar: (path, value, synchronous = false) ->
		path = path.replace(/\//g, ".")
		@prepareVars path, value, synchronous
		@Log "Vars", "Set: #{path}"
		@DSDeferred.promise if synchronous
	
	deleteLocalVarByPath: (path) ->
		path = path.replace(/\//g, ".")
		path = @getLocalVarByPath path
		@deleteLocalVar path
	
	deleteLocalVar: (path_str) ->
		path_str = path_str.replace(/\//g, ".")
		d = "delete this.Vars"
		for p in path_str.split(".")
			d += "[\"#{p}\"]"
		eval d
		eval d.replace("this.Vars", "this.synchronousVars")
		@updateView path_str
	
	getLocalVarByPath: (path_str, clone = true) ->
		o = ""
		path_str = path_str.replace(/\//g, ".")
		path = path_str.split(".")
		
		if clone
			Vars = $.extend {}, @Vars
		else
			Vars = @Vars

		for p in path
			if p of Vars
				Vars = Vars[p]
			else
				Vars = ""
				break
			
		Vars
			
	setLocalVarByPath: (obj, path_str, value) ->
		path_str = path_str.replace(/\//g, ".")
		path = path_str.split(".")
		pList = path
		len = pList.length
		i = 0

		while i < len - 1
			elem = pList[i]
			obj[elem] = {} unless obj[elem]
			obj = obj[elem]
			i++
			
		obj[pList[len - 1]] = value