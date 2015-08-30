class exports.NavigationComponent extends Layer
	
	#iOS animation constants
	_ANIMATION_TIME 			= 0.4
	_ANIMATION_CURVE 			= "cubic-bezier(.6, .1, .3, 1)"
	_LEFT_PADDING 				= if Framer.Device.deviceType.indexOf("iphone-6plus") is -1 then 46 else 69
	
	#Custom events
	Events.NavigationWillPush 	= "navigationWillPush"
	Events.NavigationDidPush 	= "navigationDidPush"
	Events.NavigationWillPop 	= "navigationWillPop"
	Events.NavigationDidPop 	= "navigationDidPop"
	
	# Shared class variables		
	navigationComponentsCounter = 1
	
	# Public constructor
	constructor: (@options={}) ->

		# Check required params
		if not @options.rootLayer
			throw new Error("Can't initialize NavigationComponent: parameter 'rootLayer' is required.")
			return

		@options.width           ?= Screen.width
		@options.height          ?= Screen.height
		@options.clip            ?= true
		@options.backgroundColor ?= "transparent"
		@options.name 			 ?= "Navigation Component " + navigationComponentsCounter

		super @options
		
		navigationComponentsCounter++

		@navigationLayers   = []
		@headerLayer 		= null
		@animationTime 		= @options.animationTime or _ANIMATION_TIME
		@animationCurve		= @options.animationCurve or _ANIMATION_CURVE
		@animationPush 		= @options.animationPush or @_defaultAnimationPush
		@animationPop		= @options.animationPop or @_defaultAnimationPop
		@currentLayerIndex 	= -1
		@lock 				= false
		@customHeader 		= false
		
		if @options.headerLayer
			@headerLayer = @options.headerLayer
			@addSubLayer(@headerLayer)
			@customHeader = true
		else # Default iOS7 header
			@headerLayer = new Layer
				superLayer: @
				name: "Header Layer"
				width: @width
				height: 88
				clip: false
				backgroundColor: "rgba(248, 248, 248, 0.9)"
			@headerLayer.style["background-image"] = "linear-gradient(0deg, rgb(200, 199, 204), rgb(200, 199, 204) 50%, transparent 50%)"
			@headerLayer.style["background-size"] = "100% 1px"
			@headerLayer.style["background-repeat"] = "no-repeat"
			@headerLayer.style["background-position"] = "bottom"
			
			titleLayer = new Layer
				superLayer: @headerLayer
				name: "Title Layer"
				width: @headerLayer.width / 2
				height: @headerLayer.height
				backgroundColor: ""
			titleLayer.centerX()
			titleLayer.style =
				"font-size" : "34px"
				"color" : "black"
				"line-height" : @headerLayer.height + "px"
				"font-weight" : "500"
				"text-align" : "center"
				"font-family": "'Helvetica Neue', Helvetica, Arial, sans-serif"
				"white-space": "nowrap"
				"height" : @headerLayer.height + "px"

			leftLayer = new Layer
				superLayer: @headerLayer
				name: "Left Layer"
				width: 140
				height: @headerLayer.height
				backgroundColor: ""
				opacity: 0
				x: _LEFT_PADDING
			leftLayer.style =
				"font-size" : "34px"
				"color" : "rgb(21, 125, 251)"
				"line-height" : @headerLayer.height + "px"
				"font-weight" : "300"
				"text-align" : "left"
				"font-family": "'Helvetica Neue', Helvetica, Arial, sans-serif"
				"white-space": "nowrap"
				"height" : @headerLayer.height + "px"
			leftLayer.on Events.Click, =>
				@pop()

			backArrow = new Layer
				superLayer: @headerLayer
				name: "Back Arrow"
				originX: 0
				originY: 0
				backgroundColor: ""
				opacity: 0
				html: "<svg version='1.1' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' x='0px' y='0px' width='46px' height='88px' viewBox='0 0 46 88' enable-background='new 0 0 46 88' xml:space='preserve'> <polygon fill='#157DFB' points='36.51,64.51 40.61,60.4 24.2,44 40.61,27.59 36.51,23.49 20.1,39.9 16,44 20.1,48.1 20.1,48.1 '/> </svg>"
			backArrow.on Events.Click, =>
				@pop()
			
			@headerLayer.titleLayer = titleLayer
			@headerLayer.backArrow = backArrow
			@headerLayer.leftLayer = leftLayer
			
			if Framer.Device.deviceType.indexOf("iphone-6plus") >= 0
				@headerLayer.height = 132
				titleLayer.height = 132
				titleLayer.style["font-size"] = "48px"
				titleLayer.style["line-height"] = titleLayer.height + "px"
				leftLayer.height = 132
				leftLayer.style["font-size"] = "48px"
				leftLayer.style["line-height"] = titleLayer.height + "px"
				leftLayer.width = leftLayer.width * 1.5
				backArrow.scale = 1.5
				
		if @options.rootLayer
			@navigationLayers = [@options.rootLayer]
			@currentLayerIndex = 0
			@addSubLayer(@options.rootLayer)
			@headerLayer.bringToFront()
			if @options.rootLayer.title and @headerLayer.titleLayer
				@headerLayer.titleLayer.html = "<div style=\"overflow: hidden; text-overflow: ellipsis\">" + @options.rootLayer.title + "</div>"

	# Public methods
	push: (layer) ->
		if not @lock
			@emit(Events.NavigationWillPush, {navigationLayer: @, currentLayer: currentLayer, nextLayer: nextLayer})
			@lock = true
			@navigationLayers.push(layer)
			@addSubLayer(layer)
			if @headerLayer
				@headerLayer.bringToFront()
			currentLayer = @navigationLayers[@currentLayerIndex]
			nextLayer = layer
			if typeof currentLayer.layerWillDisappear is "function"
				currentLayer.layerWillDisappear()
			if typeof nextLayer.layerWillAppear is "function"
				nextLayer.layerWillAppear()
			@currentLayerIndex++
			@animationPush(currentLayer, nextLayer)
			@_defaultHeaderAnimationPush(currentLayer, nextLayer)
			Utils.delay @animationTime, =>
				currentLayer.visible = false
				@lock = false
				@emit(Events.NavigationDidPush, {navigationLayer: @, currentLayer: currentLayer, nextLayer: nextLayer})
		else
			# If there was a transitioning going on, just remove the new layer
			layer.destroy()
		
	pop: ->
		@popToLayerAtIndex(@currentLayerIndex - 1)

	popToRootLayer: ->
		@popToLayerAtIndex(0)

	popToLayerAtIndex: (index) ->
		if not @lock
			@lock = true
			if @currentLayerIndex > 0 and (0 <= index <= @navigationLayers.length)
				@emit(Events.NavigationWillPop, {navigationLayer: @, index: index, currentLayer: currentLayer, nextLayer: nextLayer})
				currentLayer = @navigationLayers[@currentLayerIndex]
				nextLayer = @navigationLayers[index]
				nextLayer.visible = true
				if typeof currentLayer.layerWillDisappear is "function"
					currentLayer.layerWillDisappear()
				if typeof nextLayer.layerWillAppear is "function"
					nextLayer.layerWillAppear()
				@animationPop(currentLayer, nextLayer)
				@_defaultHeaderAnimationPop(currentLayer, nextLayer, index)
				Utils.delay @animationTime, =>
					for indexToBeDeleted in [@navigationLayers.length-1..index+1]
						layerToBeDeleted = @navigationLayers[indexToBeDeleted]
						layerToBeDeleted.destroy()
						@navigationLayers.pop()
					@currentLayerIndex = index
					@lock = false
					@emit(Events.NavigationDidPop, {navigationLayer: @, index: index, currentLayer: currentLayer, nextLayer: nextLayer})
			else
				@lock = false

	# Private methods

	_animateHeaderSubLayer: (subLayerName, fromLayer, toLayer, newTitle, currentToX, newFromX) ->
		if @headerLayer[subLayerName]
			headerSubLayer = @headerLayer[subLayerName]
			origSubLayerX = headerSubLayer.x
				
			# Animate current sublayer
			headerSubLayer.animate
				properties:
					opacity: 0
					x: currentToX
				curve: _ANIMATION_CURVE
				time: _ANIMATION_TIME
			
			#Create new layer to animate
			if newTitle isnt undefined
				newHeaderSubLayer = headerSubLayer.copy()
				newHeaderSubLayer.style = headerSubLayer.style
				@headerLayer.addSubLayer(newHeaderSubLayer)
				newHeaderSubLayer.name = "tmp " + subLayerName
				newHeaderSubLayer.x = newFromX
				newHeaderSubLayer.opacity = 0
				newHeaderSubLayer.html = "<div style=\"overflow: hidden; text-overflow: ellipsis\">" + newTitle + "</div>"
				newHeaderSubLayerAnimation = new Animation
					layer: newHeaderSubLayer
					properties:
						opacity: 1
						x: origSubLayerX
					curve: _ANIMATION_CURVE
					time: _ANIMATION_TIME
				newHeaderSubLayerAnimation.start()
				newHeaderSubLayerAnimation.on "end", ->
					headerSubLayer.html = newHeaderSubLayer.html
					headerSubLayer.opacity = 1
					headerSubLayer.x = origSubLayerX
					newHeaderSubLayer.destroy()

	_defaultHeaderAnimationPush: (fromLayer, toLayer)->
		if @headerLayer and not @customHeader
			
			@_animateHeaderSubLayer("titleLayer", fromLayer, toLayer, toLayer.title, -_LEFT_PADDING, @headerLayer.width)

			@_animateHeaderSubLayer("leftLayer", fromLayer, toLayer, fromLayer.title, - @headerLayer.width / 2, @headerLayer.width / 2)

			if @headerLayer.backArrow
				@headerLayer.backArrow.animate
					properties:
						opacity: 1
					curve: _ANIMATION_CURVE
					time: _ANIMATION_TIME

	_defaultHeaderAnimationPop: (fromLayer, toLayer, index)->
		#Animate header
		if @headerLayer and not @customHeader

			@_animateHeaderSubLayer("titleLayer", fromLayer, toLayer, toLayer.title, @headerLayer.width, 0)
			
			newLeftLayerTitle = ""
			if @navigationLayers[index - 1] and @navigationLayers[index - 1].title
				newLeftLayerTitle = @navigationLayers[index - 1].title
			else 
				if @headerLayer.backArrow
					@headerLayer.backArrow.animate
						properties:
							opacity: 0
						curve: _ANIMATION_CURVE
						time: _ANIMATION_TIME
			@_animateHeaderSubLayer("leftLayer", fromLayer, toLayer, newLeftLayerTitle, @headerLayer.width / 2, -@headerLayer.width / 2)
			

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
			curve: _ANIMATION_CURVE
			time: _ANIMATION_TIME
		fromLayer.animate
			properties:
				x: -@width * 0.25
			curve: _ANIMATION_CURVE
			time: _ANIMATION_TIME
		toLayer.shadowColor = "rgba(0,0,0,0.2)"
		toLayer.shadowX = -10
		toLayer.shadowBlur = 14
		toLayer.x = @width + (-toLayer.shadowX)
		toLayer.animate
			properties:
				x: 0
			curve: _ANIMATION_CURVE
			time: _ANIMATION_TIME

			
	_defaultAnimationPop: (fromLayer, toLayer) ->
		fromLayer.animate
			properties:
				x: @width + (-fromLayer.shadowX)
			curve: _ANIMATION_CURVE
			time: _ANIMATION_TIME
		toLayer.animate
			properties:
				x: 0
			curve: _ANIMATION_CURVE
			time: _ANIMATION_TIME
		shadowLayer = toLayer.subLayersByName("shadowLayer")[0]
		shadowLayerAnimation = new Animation
			layer: shadowLayer
			properties:
				opacity: 0
			curve: _ANIMATION_CURVE
			time: _ANIMATION_TIME
		shadowLayerAnimation.start()
		shadowLayerAnimation.on "end", ->
			shadowLayer.destroy()
		
