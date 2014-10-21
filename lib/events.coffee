RDR = class extends RDR
	executeEvent: (element) ->
		r = @
		found = false
		action = element.attr("data-rdr-bind-action")
		
		element.parents(".rdr-template").each ->
			path = $(this).attr("data-path")
			r.Log "Actions", "Fetching Path: #{path}"
			
			if path of r.Controllers && "actions" of r.Controllers[path] && action of r.Controllers[path]["actions"]
				found = true
				r.Controllers[path]["actions"][action] element
				r.Log "Actions", "Path Found: #{path}"
				false
		
		r.Log "Actions", "No Action Found: #{action}" unless found