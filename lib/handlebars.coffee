RDR = class extends RDR
	escapeQuotes: (str) ->
		"#{str}".replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
		
	handlebarsHelpers: ->
		r = @
		
		Handlebars.registerHelper "bind-attr", (options) ->
			is_loop = "_parent" of options.data
			attrs = ""
		
			for attr,key of options.hash
				key = "canned/sweet/#{key}" if is_loop
				attrs += "data-rdr-bind-attr=\"#{attr}\" "
				attrs += "data-rdr-bind-key=\"#{key}\" "
				value = r.escapeQuotes r.getByPath(r.vars, key.replace(/\//g, "."))
				attrs += "#{attr}=\"#{value}\""
		
			new Handlebars.SafeString(attrs)
	
		Handlebars.registerHelper "action", (options) ->
			attrs = ""

			for k,v of options.hash
				attrs += "data-rdr-bind-event=\"#{k}\" "
				attrs += "data-rdr-bind-action=\"#{v}\""
		
			new Handlebars.SafeString(attrs)