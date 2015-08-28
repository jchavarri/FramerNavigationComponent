class exports.NavigationController
	
	_ANIMATION_TIME = 0.4
	_ANIMATION_CURVE = "cubic-bezier(.6, .1, .3, 1)"
	
	constructor: (@options={}) ->

		@options.width           ?= Screen.width
		@options.height          ?= Screen.height
		@options.clip            ?= true
		@options.backgroundColor ?= "transparent"

		@navigationContainer = new Layer @options
		@navigationLayers   = []
		@animationTime 		= @options.animationTime or _ANIMATION_TIME
		@animationPush 		= @options.animationPush or @_defaultAnimationPush
		@animationPop		= @options.animationPop or @_defaultAnimationPop
		@currentLayerIndex = -1
		@lock = false
		
		if @options.initialLayer
			@navigationLayers = [@options.initialLayer]
			@currentLayerIndex = 0
			@navigationContainer.addSubLayer(@options.initialLayer)

		if @options.headerLayer
			@headerLayer = @options.headerLayer
			@navigationContainer.addSubLayer(@headerLayer)
			that = this
			@headerLayer.on Events.Click, ->
				that.popLayer()


	pushLayer: (layer) ->
		if not @lock
			@lock = true
			layer.x = @navigationContainer.width
			@navigationLayers.push(layer)
			@navigationContainer.addSubLayer(layer)
			currentLayer = @navigationLayers[@currentLayerIndex]
			nextLayer = layer
			if typeof currentLayer.layerWillDisappear is "function"
				currentLayer.layerWillDisappear()
			if typeof nextLayer.layerWillAppear is "function"
				nextLayer.layerWillAppear()
			@currentLayerIndex++
			animationContext = 
				fromLayer: currentLayer
				toLayer: nextLayer
			@animationPush(animationContext)
			Utils.delay @animationTime, =>
				@lock = false
		else
			# If there was a transitioning going on, just remove the new layer
			layer.destroy()
		
	popLayer: ->
		if not @lock
			@lock = true
			if @currentLayerIndex > 0
				currentLayer = @navigationLayers[@currentLayerIndex]
				nextLayer = @navigationLayers[@currentLayerIndex - 1]
				if typeof currentLayer.layerWillDisappear is "function"
					currentLayer.layerWillDisappear()
				if typeof nextLayer.layerWillAppear is "function"
					nextLayer.layerWillAppear()
				animationContext = 
					fromLayer: currentLayer
					toLayer: nextLayer
				@animationPop(animationContext)
				Utils.delay @animationTime, =>
					@navigationLayers.pop(currentLayer)
					@currentLayerIndex--
					currentLayer.destroy()
					@lock = false
			else
				@lock = false

	_defaultAnimationPush: (animationContext) ->
		animationContext.fromLayer.animate
			properties:
				x: -@navigationContainer.width * 0.25
			curve: _ANIMATION_CURVE
			time: _ANIMATION_TIME
		animationContext.toLayer.animate
			properties:
				x: 0
			curve: _ANIMATION_CURVE
			time: _ANIMATION_TIME

	_defaultAnimationPop: (animationContext) ->
		animationContext.fromLayer.animate
			properties:
				x: @navigationContainer.width
			curve: _ANIMATION_CURVE
			time: _ANIMATION_TIME
		animationContext.toLayer.animate
			properties:
				x: 0
			curve: _ANIMATION_CURVE
			time: _ANIMATION_TIME
