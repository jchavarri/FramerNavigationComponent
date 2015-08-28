# FramiOS

Reusable components for Framer, based on iOS

**NOTE:** FramiOS is a work in progress. Any suggestions or pull requests are more then welcomed.

## Components

### 1. Navigation Controller

Implements a navigation controller with a similar default configuration as the iOS one.

#### Constructor params

- `firstLayer`: The layer to initialize the navigation controller with
- `animationPush`: A function to be called when the push animation is needed. It expects two parameters: `fromLayer` -the layer that is on-screen and is going to be pushed- and `toLayer` -the layer that will be shown-.
- `animationPop`: Same as `animationPush` but when popping
- `animationTime`: A custom transition time. **This parameter is required when implementing custom animations

#### Methods

- `pushLayer`: Push a new layer into the navigation controller
- `popLayer`: Pop the latest added layer from the navigation controller

#### Simple example

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