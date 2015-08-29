# Navigation Controller

Implements a navigation controller with a similar default configuration as the iOS one.

## Constructor params

- `firstLayer` _(required)_ — The layer to initialize the navigation controller with.
- `animationPush` — A function that is called when the push animation is needed. It expects two parameters: `fromLayer` -the layer that is on-screen and is going to be pushed- and `toLayer` -the layer that will be shown-. Use this parameter to implement custom animations.
- `animationPop` — You guessed it :) Same as `animationPush` but when popping.
- `animationTime` — A custom transition time. **This parameter is required when implementing custom animations**.

## Properties

- `navigationLayers` — The array of layers that are handled by the navigation controller.
- `headerLayer` — The layer that is shown on top of the navigation layer. By default, this layer shows always a custom property `title` string that can be added to each layer added to the navigation controller.
- `currentLayerIndex` — The index of the layer that is being shown.

## Functions

- `push` — Push a new layer into the navigation controller.
- `pop` — Pop the latest added layer from the navigation controller. NOTE: The layer popped is destroyed after being removed from the navigation controller, so you might want to create a copy if you want to reuse it later.

## Simple example

```coffee
	
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

navigationController = new NavigationController({initialLayer: firstLayer})


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
```