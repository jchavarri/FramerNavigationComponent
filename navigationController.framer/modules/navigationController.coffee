class exports.NavigationController extends Layer
	
	# Private "constants"
	_DEFAULT_ANIMATION_TIME = 0.4
	_DEFAULT_ANIMATION_CURVE = "cubic-bezier(.6, .1, .3, 1)"
	
	# Private variables
	_navigationControllersCounter = 1
	
	constructor: (@options={}) ->

		# Check required params
		if not @options.initialLayer
			throw new Error("Can't initialize NavigationController: parameter 'initialLayer' is required.")
			return

		@options.width           ?= Screen.width
		@options.height          ?= Screen.height
		@options.clip            ?= true
		@options.backgroundColor ?= "transparent"
		@options.name 			 ?= "NavigationController " + _navigationControllersCounter

		super @options
		
		# Increment the nav controllers counter after it's been created, for labelling purposes
		_navigationControllersCounter++

		@navigationLayers   = []
		@animationTime 		= @options.animationTime or _DEFAULT_ANIMATION_TIME
		@animationPush 		= @options.animationPush or @_defaultAnimationPush
		@animationPop		= @options.animationPop or @_defaultAnimationPop
		@currentLayerIndex = -1
		@lock = false
		
		if @options.headerLayer
			@headerLayer = @options.headerLayer
			@addSubLayer(@headerLayer)
		else # Default header
			@headerLayer = new Layer
				width: @width
				height: 88
				backgroundColor: "rgba(248, 248, 248, 0.9)"
			if Framer.Device.deviceType.indexOf("iphone-6plus") >= 0
				@headerLayer.height = 132

			@headerLayer.style =
				"font-size" : @headerLayer.height / 2.5 + "px"
				"color" : "black"
				"line-height" : @headerLayer.height + "px"
				"font-weight" : "500"
				"text-align" : "center"
				"font-family": "'Helvetica Neue', Helvetica, Arial, sans-serif"
	

		if @options.initialLayer
			@navigationLayers = [@options.initialLayer]
			@currentLayerIndex = 0
			@addSubLayer(@options.initialLayer)
			if @options.initialLayer.title
				@headerLayer.html = @options.initialLayer.title

	push: (layer) ->
		if not @lock
			@lock = true
			@navigationLayers.push(layer)
			@addSubLayer(layer)
			currentLayer = @navigationLayers[@currentLayerIndex]
			nextLayer = layer
			if typeof currentLayer.layerWillDisappear is "function"
				currentLayer.layerWillDisappear()
			if typeof nextLayer.layerWillAppear is "function"
				nextLayer.layerWillAppear()
			@currentLayerIndex++
			@animationPush(currentLayer, nextLayer)
			Utils.delay @animationTime, =>
				@lock = false
		else
			# If there was a transitioning going on, just remove the new layer
			layer.destroy()
		
	pop: ->
		if not @lock
			@lock = true
			if @currentLayerIndex > 0
				currentLayer = @navigationLayers[@currentLayerIndex]
				nextLayer = @navigationLayers[@currentLayerIndex - 1]
				if typeof currentLayer.layerWillDisappear is "function"
					currentLayer.layerWillDisappear()
				if typeof nextLayer.layerWillAppear is "function"
					nextLayer.layerWillAppear()
				@animationPop(currentLayer, nextLayer)
				Utils.delay @animationTime, =>
					@navigationLayers.pop(currentLayer)
					@currentLayerIndex--
					currentLayer.destroy()
					@lock = false
			else
				@lock = false

	_defaultAnimationPush: (fromLayer, toLayer) ->
		shadowLayer = new Layer
			superLayer: fromLayer
			width: fromLayer.width
			height: fromLayer.height
			name: "shadowLayer"
			backgroundColor: "black"
			opacity: 0
		shadowLayer.animate
			properties:
				opacity: 0.2
			curve: _DEFAULT_ANIMATION_CURVE
			time: _DEFAULT_ANIMATION_TIME
		fromLayer.animate
			properties:
				x: -@width * 0.25
			curve: _DEFAULT_ANIMATION_CURVE
			time: _DEFAULT_ANIMATION_TIME
		toLayer.shadowColor = "rgba(0,0,0,0.2)"
		toLayer.shadowX = -10
		toLayer.shadowBlur = 14
		toLayer.x = @width + (-toLayer.shadowX)
		toLayer.animate
			properties:
				x: 0
			curve: _DEFAULT_ANIMATION_CURVE
			time: _DEFAULT_ANIMATION_TIME
		if toLayer.title
			@headerLayer.html = toLayer.title

	_defaultAnimationPop: (fromLayer, toLayer) ->
		fromLayer.animate
			properties:
				x: @width + (-fromLayer.shadowX)
			curve: _DEFAULT_ANIMATION_CURVE
			time: _DEFAULT_ANIMATION_TIME
		toLayer.animate
			properties:
				x: 0
			curve: _DEFAULT_ANIMATION_CURVE
			time: _DEFAULT_ANIMATION_TIME
		shadowLayer = toLayer.subLayersByName("shadowLayer")[0]
		shadowLayerAnimation = new Animation
			layer: shadowLayer
			properties:
				opacity: 0
			curve: _DEFAULT_ANIMATION_CURVE
			time: _DEFAULT_ANIMATION_TIME
		shadowLayerAnimation.start()
		shadowLayerAnimation.on "end", ->
			shadowLayer.destroy()
		if toLayer.title
				@headerLayer.html = toLayer.title
		
