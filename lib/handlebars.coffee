RDR = class extends RDR
	escapeQuotes: (str) ->
		"#{str}".replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;')
		
	handlebarsHelpers: ->
		r = @
		
		Handlebars.registerHelper "bind-attr", (options) ->
			attrs = ""
		
			for k,v of options.hash
				value = r.escapeQuotes r.getByPath(r.vars, v)
				attrs += "data-rdr-bind-attr=\"#{k}\" "
				attrs += "data-rdr-bind-key=\"#{v.replace(/\./g, "/")}\" "
				attrs += "#{k}=\"#{value}\""
		
			new Handlebars.SafeString(attrs)
	
		Handlebars.registerHelper "action", (options) ->
			attrs = ""

			for k,v of options.hash
				attrs += "data-rdr-bind-event=\"#{k}\" "
				attrs += "data-rdr-bind-action=\"#{v}\""
		
			new Handlebars.SafeString(attrs)