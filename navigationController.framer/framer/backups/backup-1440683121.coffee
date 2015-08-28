NavigationController = (require "navigationController").NavigationController

firstLayer = new Layer
	width: Screen.width
	height: Screen.height
	html: "1"
	title: "My title"
	backgroundColor: Framer.Utils.randomColor()
	
firstLayer.style =
	"font-size" : "600px",
	"line-height" : Screen.height + "px",
	"font-weight" : "bold",
	"text-align" : "center",

navigationController = new NavigationController
	initialLayer: firstLayer


firstLayer.on Events.Click, ->
	secondLayer = new Layer
		width: Screen.width
		height: Screen.height
		html: "2"
	secondLayer.style = firstLayer.style
	secondLayer.backgroundColor = Framer.Utils.randomColor()

	secondLayer.on Events.Click, ->
		navigationController.popLayer()
	navigationController.pushLayer(secondLayer)


