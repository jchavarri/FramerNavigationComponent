NavigationComponent = (require "navigationComponent").NavigationComponent

firstLayer = new Layer
	width: Screen.width
	height: Screen.height
	html: "1"
	backgroundColor: "white"
firstLayer.title = "Settings"
firstLayer.style =
	"font-size" : "600px",
	"color" : "orange",
	"line-height" : Screen.height + "px",
	"font-weight" : "bold",
	"text-align" : "center",

navigationComponent = new NavigationComponent
	initialLayer: firstLayer

firstLayer.on Events.Click, ->
	secondLayer = new Layer
		width: Screen.width
		height: Screen.height
		html: "2"
	secondLayer.title = "General"
	secondLayer.style = firstLayer.style
	secondLayer.backgroundColor = Framer.Utils.randomColor()
	secondLayer.color = "white"
	secondLayer.on Events.Click, ->
		thirdLayer = new Layer
			width: Screen.width
			height: Screen.height
			html: "3"
		thirdLayer.title = "Notifications"
		thirdLayer.style = firstLayer.style
		thirdLayer.backgroundColor = Framer.Utils.randomColor()
		thirdLayer.color = "white"
		navigationComponent.push(thirdLayer)
	
	navigationComponent.push(secondLayer)


