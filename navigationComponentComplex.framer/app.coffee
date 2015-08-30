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
	secondLayer = createFullScreenLayer("2", "User profile")
	secondLayer.name = "Second screen"
	secondLayer.on Events.Click, ->
		thirdLayer = createFullScreenLayer("3", "Notifications")
		thirdLayer.name = "Third screen"
		backButton = new Layer
			superLayer: thirdLayer
			y: 200
			width: 320
			height: 90
			shadowY: 1
			shadowBlur: 2
			backgroundColor: "white"
			html: "Back home"
		backButton.style =
			color: "black"
			lineHeight: backButton.height + "px"
			textAlign: "center"
			fontSize: "34px"
			fontWeight: 500
			fontFamily: "'Helvetica Neue', Helvetica, Arial, sans-serif"
			boxShadow: "0 1px 3px rgba(0,0,0,0.2)"
		backButton.centerX()
		backButton.on Events.Click, ->
			navigationComponent.popToRootLayer()
		navigationComponent.push(thirdLayer)
	navigationComponent.push(secondLayer)