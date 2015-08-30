# FramiOS

iOS based components for Framer. They have a default behavior and look, but can be easily customized.

**NOTE:** FramiOS is a work in progress and in a very early stage. Any suggestions or PRs are more then welcomed!

## Basic usage

- Download the repository
- Copy the components you want to use in the `modules` folder
- Add the `require` expressions to your files (you can check each module documentation for that)

## Components

### Navigation Component

Implements a navigation component with a similar default configuration as the iOS one. All its behavior and styles are easily customized, both for the animations between layers and the header layer.

[Documentation](doc/navigationComponent.md)

![Navigation component](navigationComponentComplex.framer/images/demo.gif)

## TODO

- Navigation component
	- Add slide right to pop
	- Replace header layers for state transitions
	- Add right button action

- Other components
	- Table View
	- Refresh control
	- Segmented control
	- Switch
	- Text Field
	- Picker
	- Date picker


### References

Thanks to the following creators for sharing their work:

- [framer-viewNavigationComponent](https://github.com/chriscamargo/framer-viewNavigationComponent) by Chris Camargo
- [Cloning the UI of iOS 7 with HTML, CSS and JavaScript](http://come.ninja/2013/cloning-the-ui-of-ios-7-with-html-css-and-javascript/) by Côme Courteault

Other references: 

- [iOS 8 Design Cheat Sheet for iPhone 6 and iPhone 6 Plus](http://click-labs.com/ios-8-design-cheat-sheet-and-free-iphone6plus-gui-psd/)
