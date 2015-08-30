NavigationComponent = (require "navigationComponent").NavigationComponent

createFullScreenLayer = (text, title) ->
	newLayer = new Layer
		width: Screen.width
		height: Screen.height
		html: text
		backgroundColor: Framer.Utils.randomColor()
	newLayer.title = title
	newLayer.style =
		"font-size" : "600px"
		"color" : "white"
		"line-height" : Screen.height + "px"
		"font-weight" : "bold"
		"text-align" : "center"
	return newLayer
	
firstLayer = createFullScreenLayer("1", "Settings")
firstLayer.name = "First screen"
firstLayer.backgroundColor = "white"
firstLayer.style["color"] = "orange"

headerLayer = new Layer
	width: Screen.width
	height: 100
	backgroundColor: "#28affa"

circleLayers = []

addCircleLayer = (navigationLayersLength) ->
	circleLayer = new Layer
		superLayer: headerLayer
		x: Screen.width
		width: 50
		height: 50
		borderRadius: 25
		backgroundColor: "white"
	circleLayer.centerY()
	circleLayer.animate
		properties:
			x: (navigationLayersLength + 1) * 80 + 55
		curve: "spring(400, 20, 10)"
	circleLayers.push(circleLayer)

removeCircleLayer = (index) ->
	for circleIndex in [index+1...circleLayers.length]
		circleLayer = circleLayers[circleIndex]
		circleLayerAnimation = new Animation
			layer: circleLayer
			properties:
				x: Screen.width + 100
			curve: "spring(400, 20, 10)"
			delay: 0.3 * (circleLayers.length - 1 - circleIndex)
		circleLayerAnimation.start()
		circleLayerAnimation.on Events.AnimationEnd, ->
			circleLayers[circleLayers.length - 1].destroy()
			circleLayers.pop()
	
addCircleLayer(1)

navigationComponent = new NavigationComponent
	rootLayer: firstLayer
	headerLayer: headerLayer

navigationComponent.on Events.NavigationWillPush, (event) ->
	addCircleLayer(event.navigationLayer.navigationLayers.length + 1)
	
navigationComponent.on Events.NavigationWillPop, (event) ->
	removeCircleLayer(event.index)
	
firstLayer.on Events.Click, ->
	secondLayer = createFullScreenLayer("2", "User profile")
	secondLayer.name = "Second screen"
	secondLayer.on Events.Click, ->
		thirdLayer = createFullScreenLayer("3", "Notifications")
		thirdLayer.name = "Third screen"
		thirdLayer.on Events.Click, ->
			navigationComponent.popToRootLayer()
		navigationComponent.push(thirdLayer)
	navigationComponent.push(secondLayer)