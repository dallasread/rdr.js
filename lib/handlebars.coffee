RDR = class extends RDR
	escapeQuotes: (str) ->
		"#{str}".replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
	
	extractPath: (options) ->
		in_loop = false
		path = ""
		
		if "path" of options.hash
			in_loop = true
			path = $(options.hash.path).attr("data-rdr-bind-html")
			path = path.replace(/\/(_path|delete)/, "")

		[in_loop, path]
	
	singularize: (str) ->
		if "#{str}".slice(-3) == "ies"
			"#{"#{str}".slice(-3)}y"
		else if "#{str}".slice(-1) == "s"
			"#{str}".slice(-1)
		else
			str

	handlebarsHelpers: ->
		r = @
		
		Handlebars.registerHelper "bind-attr", (options) ->
			attrs = ""
			[in_loop, path] = r.extractPath options
			
			options.hash.event = "blur" unless "event" of options.hash
			
			for attr,key of options.hash
				if attr != "path"
					if attr == "event"
						attrs += "data-rdr-bind-#{attr}=\"#{key}\" "
					else
						key = "#{path}/#{key}" if in_loop
						attrs += "data-rdr-bind-attr=\"#{attr}\" "
						attrs += "data-rdr-bind-key=\"#{key}\" "
						value = r.escapeQuotes r.getLocalVarByPath key
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
		
		Handlebars.registerHelper "render", (variable, options) ->
			output = ""
			template = false
			collection = r.vars[variable]
			
			if typeof template != "string"
				first = collection[Object.keys(collection)[0]]
				path = r.singularize first._parent_key if typeof first != "undefined"
				path = r.singularize variable
				template = "/partials/#{path}"
			
			if template of r.Templates
				for k,v of collection
					# subTemplateContext = $.extend {}, this, v
					# console.log r.Templates[template] v
					output += "<tr><td>awesome</td></tr>"
			else
				r.Warn "Handlebars", "Partial Not Found: #{template}"

			new Handlebars.SafeString(output)