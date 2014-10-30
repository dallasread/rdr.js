RDR = class extends RDR
	executeEvent: (element, data = {}) ->
		r = @
		found = false
		action = element.attr("data-rdr-bind-action")
		
		element.parents(".rdr-template").each ->
			path = $(this).attr("data-rdr-template")
			r.Log "Actions", "Fetching Path: #{path}"
			
			if path of r.Controllers && "actions" of r.Controllers[path] && action of r.Controllers[path]["actions"]
				found = true
				r.Controllers[path]["actions"][action] element, data
				r.Log "Actions", "Path Found: #{path}"
				false
		
		r.Log "Actions", "No Action Found: #{action}" unless found
	
	Events: ->
		r = @

		$(@Config.container).on "saveAttrs", "form", ->
			$(this).find("[data-rdr-bind-key]").each ->
				r.update $(this).attr("data-rdr-bind-key"), $(this).val()
			false
	
		$(@Config.container).on "blur", "[data-rdr-bind-event='blur']", ->
			r.update $(this).attr("data-rdr-bind-key"), $(this).val()
			false
		
		$(@Config.container).on "click", "[data-rdr-bind-event='click']", ->
			data = {}
			path = $(this).attr("data-rdr-bind-key")
			data = r.getLocalVarByPath path if path
			r.executeEvent $(this), data
			false
	
		$(@Config.container).on "submit", "[data-rdr-bind-event='submit']", ->
			r.executeEvent $(this)
			false