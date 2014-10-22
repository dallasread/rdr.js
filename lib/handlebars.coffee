RDR = class extends RDR
	escapeQuotes: (str) ->
		"#{str}".replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
		
	handlebarsHelpers: ->
		r = @
		
		Handlebars.registerHelper "bind-attr", (options) ->
			in_loop = false
			attrs = ""
			path = ""
			
			if "path" of options.hash
				in_loop = true
				path = $(options.hash.path).attr("data-rdr-bind-html").replace("/_path", "")
			
			options.hash.event = "blur" unless "event" of options.hash
			
			for attr,key of options.hash
				if attr == "event"
					attrs += "data-rdr-bind-#{attr}=\"#{key}\" "
				else if attr != "path"
					key = "#{path}/#{key}" if in_loop

					attrs += "data-rdr-bind-attr=\"#{attr}\" "
					attrs += "data-rdr-bind-key=\"#{key}\" "
					value = r.escapeQuotes r.getLocalVarByPath key
					attrs += "#{attr}=\"#{value}\""
		
			new Handlebars.SafeString(attrs)
	
		Handlebars.registerHelper "action", (options) ->
			attrs = ""

			for k,v of options.hash
				attrs += "data-rdr-bind-event=\"#{k}\" "
				attrs += "data-rdr-bind-action=\"#{v}\""
		
			new Handlebars.SafeString(attrs)