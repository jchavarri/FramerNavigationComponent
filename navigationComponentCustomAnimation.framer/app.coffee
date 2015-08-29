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

# Custom configuration for Navigation Component
animationTime = 0.5
animationCurve = "spring(300,40,0)"
animationPush = (fromLayer, toLayer) ->
	fromLayer.animate
		properties:
			scale: 5
			opacity: 0
		time: animationTime
		curve: animationCurve
	toLayer.scale = 0.2
	toLayer.opacity = 0
	toLayer.animate
		properties:
			scale: 1
			opacity: 1
		time: animationTime
		curve: animationCurve
	if toLayer.title
		navigationComponent.headerLayer.html = toLayer.title
animationPop = (fromLayer, toLayer) ->
	fromLayer.animate
		properties:
			scale: 0
			opacity: 0
		time: animationTime
		curve: animationCurve
	toLayer.animate
		properties:
			scale: 1
			opacity: 1
		time: animationTime
		curve: animationCurve
	if toLayer.title
		navigationComponent.headerLayer.html = toLayer.title
	
navigationComponent = new NavigationComponent
	initialLayer: firstLayer
	animationTime: animationTime
	animationPush: animationPush
	animationPop: animationPop

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


