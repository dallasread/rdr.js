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