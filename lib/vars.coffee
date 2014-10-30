RDR = class extends RDR
	varChart: {}
	synchronousVars: {}
	
	fetchSynchronousVars: ->
		@prepareVars "", @Vars, true
	
	prepareVars: (parent_key = "", parent_value = {}, synchronous = false) ->
		parent_key = @slasherize parent_key
		
		if !synchronous && parent_key.replace(/\//g, "").length && typeof parent_value == "object"
			parent_value._path = parent_key
			parent_value._parent_key = parent_value._path.substr 0, parent_value._path.lastIndexOf("/")
		
		if typeof parent_value == "object" && !Object.keys(parent_value).length
			@setLocalVarByPath @Vars, parent_key, {}
			@setLocalVarByPath @synchronousVars, parent_key, {}
		else
			for key,value of parent_value
				var_key = ""
				var_key += parent_key
				var_key += "/" if var_key.length
				var_key += key

				if typeof value == "object"
					value._path = @slasherize var_key
					value._parent_key = @slasherize parent_key
					@prepareVars var_key, value, synchronous
				else
					@setLocalVarByPath @Vars, var_key, value
					value = "<span data-rdr-bind-html='#{var_key}'>#{value}</span>"
					@setLocalVarByPath @synchronousVars, var_key, value
		
		if synchronous
			@removeDeferred()
			@synchronousVars
		else
			@Vars
	
	updateLocalVar: (path, value, synchronous = false) ->
		@prepareVars path, value, synchronous
		@Log "Vars", "Set: #{path}"
		@updateView path, value if !synchronous
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
		o = ""
		path_str = @dotterize path_str
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
			
		obj[pList[len - 1]] = value