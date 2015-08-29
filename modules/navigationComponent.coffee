class exports.NavigationComponent extends Layer
	
	_ANIMATION_TIME = 0.4
	_ANIMATION_CURVE = "cubic-bezier(.6, .1, .3, 1)"
	navigationComponentsCounter = 1
	
	constructor: (@options={}) ->

		# Check required params
		if not @options.initialLayer
			throw new Error("Can't initialize NavigationComponent: parameter 'initialLayer' is required.")
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
		@animationPush 		= @options.animationPush or @_defaultAnimationPush
		@animationPop		= @options.animationPop or @_defaultAnimationPop
		@currentLayerIndex = -1
		@lock = false
		
		if @options.headerLayer
			@headerLayer = @options.headerLayer
			@addSubLayer(@headerLayer)
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
				
		if @options.initialLayer
			@navigationLayers = [@options.initialLayer]
			@currentLayerIndex = 0
			@addSubLayer(@options.initialLayer)
			@headerLayer.bringToFront()
			if @options.initialLayer.title
				@headerLayer.titleLayer.html = "<div style=\"overflow: hidden; text-overflow: ellipsis\">" + @options.initialLayer.title + "</div>"

	push: (layer) ->
		if not @lock
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

		#Animate header
		if @headerLayer
			leftPadding = 46
			if Framer.Device.deviceType.indexOf("iphone-6plus") >= 0
				leftPadding = leftPadding * 1.5
			#New title
			if @headerLayer.titleLayer
				titleLayer = @headerLayer.titleLayer
				
				# Animate current title to go left
				titleLayer.animate
					properties:
						opacity: 0
						x: -leftPadding
					curve: _ANIMATION_CURVE
					time: _ANIMATION_TIME
				
				#Create new title to animate from the right side of the screen
				newTitleLayer = titleLayer.copy()
				newTitleLayer.style = titleLayer.style
				@headerLayer.addSubLayer(newTitleLayer)
				newTitleLayer.name = "Tmp Title"
				newTitleLayer.x = @headerLayer.width
				newTitleLayer.html = "<div style=\"overflow: hidden; text-overflow: ellipsis\">" + toLayer.title + "</div>"
				newTitleAnimation = new Animation
					layer: newTitleLayer
					properties:
						opacity: 1
						x: titleLayer.x
					curve: _ANIMATION_CURVE
					time: _ANIMATION_TIME
				newTitleAnimation.start()
				newTitleAnimation.on "end", ->
					titleLayer.html = newTitleLayer.html
					titleLayer.opacity = 1
					titleLayer.centerX()
					newTitleLayer.destroy()

			if @headerLayer.backArrow
				@headerLayer.backArrow.animate
					properties:
						opacity: 1
					curve: _ANIMATION_CURVE
					time: _ANIMATION_TIME
			
			#New left layer
			if @headerLayer.leftLayer
				leftLayer = @headerLayer.leftLayer
				
				# Animate current left layer to go left
				leftLayer.animate
					properties:
						opacity: 0
						x: - @headerLayer.width / 2
					curve: _ANIMATION_CURVE
					time: _ANIMATION_TIME
				
				#Create new left layer to animate from the left side of the screen
				newLeftLayer = leftLayer.copy()
				newLeftLayer.style = leftLayer.style
				@headerLayer.addSubLayer(newLeftLayer)
				newLeftLayer.name = "Tmp Left Layer"
				newLeftLayer.centerX()
				newLeftLayer.opacity = 0
				newLeftLayer.html = "<div style=\"overflow: hidden; text-overflow: ellipsis\">" + fromLayer.title + "</div>"
				newLeftLayerAnimation = new Animation
					layer: newLeftLayer
					properties:
						opacity: 1
						x: leftPadding
					curve: _ANIMATION_CURVE
					time: _ANIMATION_TIME
				newLeftLayerAnimation.start()
				newLeftLayerAnimation.on "end", ->
					leftLayer.html = newLeftLayer.html
					leftLayer.x = leftPadding
					leftLayer.opacity = 1
					newLeftLayer.destroy()


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
		
		#Animate header
		if @headerLayer
			#New title
			if @headerLayer.titleLayer
				titleLayer = @headerLayer.titleLayer
				
				# Animate current title to go right
				titleLayer.animate
					properties:
						opacity: 0
						x: @headerLayer.width
					curve: _ANIMATION_CURVE
					time: _ANIMATION_TIME
				
				#Create new title to animate from the right side of the screen
				newTitleLayer = titleLayer.copy()
				newTitleLayer.style = titleLayer.style
				@headerLayer.addSubLayer(newTitleLayer)
				newTitleLayer.name = "Tmp Title"
				newTitleLayer.x = 0
				newTitleLayer.opacity = 0
				newTitleLayer.html = "<div style=\"overflow: hidden; text-overflow: ellipsis\">" + toLayer.title + "</div>"
				newTitleAnimation = new Animation
					layer: newTitleLayer
					properties:
						opacity: 1
						x: titleLayer.x
					curve: _ANIMATION_CURVE
					time: _ANIMATION_TIME
				newTitleAnimation.start()
				newTitleAnimation.on "end", ->
					titleLayer.html = newTitleLayer.html
					titleLayer.opacity = 1
					titleLayer.centerX()
					newTitleLayer.destroy()

			#New left layer
			if @headerLayer.leftLayer
				leftLayer = @headerLayer.leftLayer
				
				# Animate current left layer to go right
				origLeftLayerX = leftLayer.x
				leftLayer.animate
					properties:
						opacity: 0
						x: @headerLayer.width / 2
					curve: _ANIMATION_CURVE
					time: _ANIMATION_TIME
				
				if @navigationLayers.length > 2 and @navigationLayers[@currentLayerIndex - 2] and @navigationLayers[@currentLayerIndex - 2].title
					#Create new left layer to animate from the left side of the screen
					newLeftLayer = leftLayer.copy()
					newLeftLayer.style = leftLayer.style
					@headerLayer.addSubLayer(newLeftLayer)
					newLeftLayer.name = "Tmp Left Layer"
					newLeftLayer.x = -newLeftLayer.width
					newLeftLayer.opacity = 0
					newLeftLayer.html = "<div style=\"overflow: hidden; text-overflow: ellipsis\">" + @navigationLayers[@currentLayerIndex - 2].title + "</div>"
					newLeftLayerAnimation = new Animation
						layer: newLeftLayer
						properties:
							opacity: 1
							x: leftLayer.x
						curve: _ANIMATION_CURVE
						time: _ANIMATION_TIME
					newLeftLayerAnimation.start()
					newLeftLayerAnimation.on "end", ->
						leftLayer.html = newLeftLayer.html
						leftLayer.x = origLeftLayerX
						leftLayer.opacity = 1
						newLeftLayer.destroy()

		if @navigationLayers.length is 2
			if @headerLayer.backArrow
				@headerLayer.backArrow.animate
					properties:
						opacity: 0
					curve: _ANIMATION_CURVE
					time: _ANIMATION_TIME
