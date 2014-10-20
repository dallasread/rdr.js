RDR = class extends RDR
	pluralModel: (model) ->
		if "plural" of @Models[model]
			@Models[model].plural
		else
			"#{model}s"