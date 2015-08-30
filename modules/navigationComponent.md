# Navigation Component

A navigation component for Framer. It includes:

- Default transitions for pushing and popping views, based on iOS UINavigationController, that you can replace with your own ones.
- Default header style and animations to show the current and previous layer, also easily customizable.

## Get started

- Copy the `navigationComponent.coffee` file into your `modules` folder
- Add `NavigationComponent = (require "navigationComponent").NavigationComponent`
- Create the NavigationComponent: `navigationComponent = new NavigationComponent
	rootLayer: yourFirstLayer`

## Constructor params

- `firstLayer` *(required)* — The layer to initialize the navigation component with.
- `animationPush` — A function that is called when the push animation is needed. It expects two parameters: `fromLayer` -the layer that is on-screen and is going to be pushed- and `toLayer` -the layer that will be shown-. Use this parameter to implement custom animations.
- `animationPop` — You guessed it :) Same as `animationPush` but when popping.
- `animationTime` — A custom transition time. *This parameter is required when implementing custom animations*.

## Properties

- `navigationLayers` — The array of layers that are handled by the navigation component.
- `headerLayer` — The layer that is shown on top of the navigation layer. By default, this layer shows always a custom property `title` string that can be added to each layer on the navigation stack.
- `currentLayerIndex` — The index of the layer that is being shown.

## Functions

- `push()` — Push a new layer into the navigation component.
- `pop()` — Pop the latest added layer from the navigation component. NOTE: The layer popped is destroyed after being removed from the navigation component, so you might want to create a copy if you want to reuse it later.
- `popToRootLayer()` — Pops to the root layer.
- `popToLayerAtIndex(index)` — Pops layers until the specified index is at the top of the navigation stack

## Simple example

```coffee
	
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
	navigationComponent.push(secondLayer)

```