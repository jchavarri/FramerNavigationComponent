NavigationComponent = (require "navigationComponent").NavigationComponent

animationTime = 0.5
animationCurve = "spring(300,40,0)"

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
	newLayer.states.add
		pushed:
			scale: 5
			opacity: 0
		popped:
			scale: 0.2
			opacity: 0
	newLayer.states.animationOptions =
		curve: "spring(300,40,0)"
		time: 0.5
	return newLayer
	
firstLayer = createFullScreenLayer("1", "Settings")
firstLayer.name = "First screen"
firstLayer.backgroundColor = "white"
firstLayer.style["color"] = "orange"
firstLayer.on Events.Click, ->
	secondLayer = createFullScreenLayer("2", "User configuration")
	navigationComponent.push(secondLayer)

# Custom configuration for Navigation Component
animationPush = (fromLayer, toLayer) ->
	fromLayer.states.switch("pushed")
	toLayer.states.switchInstant("popped")
	toLayer.states.switch("default")
animationPop = (fromLayer, toLayer) ->
	fromLayer.states.switch("popped")
	toLayer.states.switchInstant("pushed")
	toLayer.states.switch("default")
	
navigationComponent = new NavigationComponent
	rootLayer: firstLayer
	animationTime: animationTime
	animationPush: animationPush
	animationPop: animationPop