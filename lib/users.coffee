RDR = class extends RDR
	createUserAndSignIn: (user, callback = false) ->
		r = @
		
		@DS.createUser user, (error) ->
			if typeof callback == "function"
				r.signInUser user, callback
			else
				r.signInUser user
	
	signInUser: (user, callback = false) ->
		r = @

		@DS.authWithPassword user, (error, authData) ->
			if typeof callback == "function"
				callback(error, authData)
			else if error
				alert "Email or Password was invalid."
	
	signOut: (callback = false) ->
		@DS.unauth()
		callback() if typeof callback == "function"