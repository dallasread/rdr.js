RDR = class extends RDR
	varChart: {}
	synchronousVars: {}
	
	fetchSynchronousVars: ->
		@prepareVars "", @Vars, true
	
	prepareVars: (parent_key = "", parent_value = {}, synchronous = false) ->
		parent_key = @slasherized parent_key
		
		for key,value of parent_value
			var_key = ""
			var_key += parent_key
			var_key += "/" if var_key.length
			var_key += key

			if typeof value == "object"
				value._path = @slasherized var_key
				value._parent_key = @slasherized parent_key
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
		if "#{path}".length
			@prepareVars path, value, synchronous
			@Log "Vars", "Set: #{path}"
			# @updateView path, value unless synchronous
			@DSDeferred.promise if synchronous
	
	deleteLocalVarByPath: (path) ->
		path = @dotterized "#{path}"
		path = @getLocalVarByPath path
		@deleteLocalVar path
	
	deleteLocalVar: (path_str) ->
		path_str = @dotterized "#{path_str}"
		d = "delete this.Vars"
		for p in path_str.split(".")
			d += "[\"#{p}\"]"
		eval d
		eval d.replace("this.Vars", "this.synchronousVars")
		@updateView path_str
	
	getLocalVarByPath: (path_str, clone = true) ->
		o = ""
		path_str = @dotterized path_str
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
		path_str = @dotterized path_str
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