RDR = class extends RDR
	singularize: (str) ->
		if "#{str}".slice(-3) == "ies"
			"#{"#{str}".slice(0, -3)}y"
		else if "#{str}".slice(-1) == "s"
			"#{str}".slice(0, -1)
		else
			"#{str}"
	
	pluralize: (str) ->
		if str of @Models && "plural" of @Models[str]
			@Models[str].plural
		else
			if "#{str}".slice(-1) == "y"
				"#{str.slice(0, -1)}ies"
			else if "#{str}".slice(-1) == "s"
				"#{str}"
			else
				"#{str}s"
	
	capitalize: (str) ->
		"#{str}".charAt(0).toUpperCase() + "#{str}".slice(1)
	
	slasherize: (str) ->
		str = "#{str}".replace(/\./g, "/")
		str = "/#{str}" if str[0] != "/"
		str
	
	dotterize: (str) ->
		str = "#{str}".replace(/\//g, ".")
		str = str.slice(1) if str[0] == "."
		str