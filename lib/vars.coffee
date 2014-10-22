RDR = class extends RDR
	varChart: {}
	synchronousVars: {}
	
	fetchSynchronousVars: ->
		@prepareVars "", @vars, true
	
	prepareVars: (parent_key = "", parent_value = {}, synchronous = false) ->
		for key,value of parent_value
			var_key = ""
			var_key += parent_key
			var_key += "/" if var_key.length
			var_key += key

			if typeof value == "object"
				value._path = var_key
				@prepareVars var_key, value, synchronous
			else
				@setLocalVarByPath @vars, var_key, value
				@updateView var_key, value
				value = "<span data-rdr-bind-html='#{var_key}'>#{value}</span>"
				@setLocalVarByPath @synchronousVars, var_key, value
		
		if synchronous then @synchronousVars else @vars
	
	updateLocalVar: (path, value, synchronous = false) ->
		@prepareVars path, value, synchronous
		@Log "Vars", "Set: #{path}"
		synchronous.promise if synchronous
	
	deleteLocalVar: (path) ->
		delete @getLocalVarByPath path
		@updateView path
	
	getLocalVarByPath: (path_str) ->
		o = ""
		path_str = path_str.replace(/\//g, ".")
		path = path_str.split(".")
		vars = $.extend {}, @vars

		for p in path
			if p of vars
				vars = vars[p]
			else
				vars = ""
				break
			
		vars
			
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