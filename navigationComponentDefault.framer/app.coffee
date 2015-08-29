NavigationComponent = (require "navigationComponent").NavigationComponent

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

navigationComponent = new NavigationComponent
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
		navigationComponent.pop()
	navigationComponent.push(secondLayer)


