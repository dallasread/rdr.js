RDR = class extends RDR
	escapeQuotes: (str) ->
		"#{str}".replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
	
	extractPath: (options) ->
		in_loop = false
		path = ""
		
		if "_path" of options.data.root
			in_loop = true
			path = options.data.root._path

		[in_loop, path]

	handlebarsHelpers: ->
		r = @
		
		Handlebars.registerHelper "bind-attr", (options) ->
			attrs = ""
			[in_loop, path] = r.extractPath options

			for attr,key of options.hash
				if attr == "event"
					attrs += "data-rdr-bind-#{attr}=\"#{key}\" "
				else
					slashed_key = r.slasherize key
					slashed_key = "#{path}#{slashed_key}" if in_loop
					attrs += "data-rdr-bind-attr=\"#{attr}\" "
					attrs += "data-rdr-bind-key=\"#{slashed_key}\" "
					
					if key.indexOf("{") != -1
						template = Handlebars.compile key
						value = template options.data.root
					else
						value = r.escapeQuotes r.getLocalVarByPath slashed_key

					attrs += "#{attr}=\"#{value}\""
		
			new Handlebars.SafeString(attrs)
	
		Handlebars.registerHelper "action", (options) ->
			attrs = ""
			[in_loop, path] = r.extractPath options
			
			if in_loop
				attrs += "data-rdr-bind-key=\"#{path}\" "

			for attr,key of options.hash
				if attr != "path"
					attrs += "data-rdr-bind-event=\"#{attr}\" "
					attrs += "data-rdr-bind-action=\"#{key}\""
		
			new Handlebars.SafeString(attrs)
		
		Handlebars.registerHelper "render", (variable, template..., options) ->
			output = ""
			collection = r.Vars[variable]
			template = template[0] if typeof template == "object"
			
			if typeof template != "string"
				first = collection[Object.keys(collection)[0]]
				path = r.singularize if typeof first != "undefined" then first._parent_key else variable
				path = r.slasherize path
				template = "/partials#{path}"
			
			if template of r.Templates
				output += "<script class=\"rdr-collection-first-#{variable}\" data-template=\"#{template}\"></script>"
				for k,v of collection
					html = r.buildPartial template, v, "#{variable}/#{k}"
					output += html
				output += "<script class=\"rdr-collection-last-#{variable}\" data-template=\"#{template}\"></script>"
			else
				r.Warn "Partials", "Not Found: #{template}"

			new Handlebars.SafeString(output)