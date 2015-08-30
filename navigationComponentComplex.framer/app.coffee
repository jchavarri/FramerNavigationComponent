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

navigationComponent = new NavigationComponent
	rootLayer: firstLayer

firstLayer.on Events.Click, ->
	secondLayer = createFullScreenLayer("2", "Long title screen")
	secondLayer.name = "Second screen"
	secondLayer.on Events.Click, ->
		thirdLayer = createFullScreenLayer("3", "Notifications")
		thirdLayer.name = "Third screen"
		thirdLayer.on Events.Click, ->
			navigationComponent.popToRootLayer()
		navigationComponent.push(thirdLayer)
	navigationComponent.push(secondLayer)