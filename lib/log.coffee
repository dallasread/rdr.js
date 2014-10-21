RDR = class extends RDR
	Logger: (log_level, a, b) ->
		if typeof @Config != "undefined" && @Config.debug
			class_length = 13
			c = new Array(class_length - a.length).join(" ")
			console[log_level] "#{c}#{a} # #{b}"
		
	Log: (a, b) ->
		@Logger "log", a, b
	
	Info: (a, b) ->
		@Logger "info", a, b
	
	Debug: (a, b) ->
		@Logger "debug", a, b
	
	Warn: (a, b) ->
		@Logger "warn", a, b
	
	Error: (a, b) ->
		@Logger "error", a, b
			