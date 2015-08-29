NavigationController = (require "navigationController").NavigationController

firstLayer = new Layer
	width: Screen.width
	height: Screen.height
	html: "1"
	backgroundColor: "white"
firstLayer.title = "First screen"
firstLayer.style =
	"font-size" : "600px",
	"color" : "orange",
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
	secondLayer.title = "Second screen"
	secondLayer.style = firstLayer.style
	secondLayer.backgroundColor = Framer.Utils.randomColor()
	secondLayer.color = "white"
	
	secondLayer.on Events.Click, ->
		navigationController.pop()
	navigationController.push(secondLayer)


