# Welcome to Framer

# Learn how to prototype: http://framerjs.com/learn
# Drop an image on the device, or import a design from Sketch or Photoshop

# Data
url = "http://mobile.nytimes.com/2015/03/19/us/a-vineyard-dispute-800000-in-cash-and-two-dead-in-napa.html"
imgsrc = "http://static01.nyt.com/images/2015/03/19/us/19VINEYARDWEB1/19VINEYARDWEB1-master675.jpg"

stage = new BackgroundLayer()
card = new Layer 
	width: stage.width, 
	height: stage.height,
	backgroundColor: '#ffffff'
card.style['color'] = 'black';
card.html = """
	<img style="display:block;width:100%" src="#{imgsrc}"/>
	<h1 style='line-height:1.5; text-align:center'>This is a headline</h1>
"""
card.center()

# Define UIView
webView = new Layer
	width: stage.width
	height: stage.height
	backgroundColor: '#ffffff'
webView.y = stage.height
webView.shadowY = -10;
webView.shadowColor = "rgba(0,0,0,0.2)"
webView.shadowBlur = 30
webView.html = """
	<div>
	<iframe
	style="width:#{stage.width}px; height:#{stage.height}px" 
	src="#{url}"></iframe></div>
	"""

# Define close bar
closeBar = new Layer
	width: stage.width
	height: 100
	backgroundColor: 'rgba(255, 255, 255, 1)'
	opacity: 0
closeBar.style["z-index"] = 1000
closeBar.style["border-bottom"] = "1px solid #999"
closeBar.html = """
	<div style="color:#999; text-align:right; font-size:70px; margin:25px">&times;</div>"
"""
# Define a set of states with names (the original state is 'default')

card.states.add
	second: {y:100, scale:0.6, rotationZ:100}
	third:  {y:300, scale:1.3, blur:4}
	fourth: {y:200, scale:0.9, blur:2, rotationZ:200}

# Set the default animation options

card.states.animationOptions =
	curve: "spring(500,12,0)"

# On a click, go to the next state
card.draggable.enable = true;
#card.on Events.dragStart, ->
	
card.on Events.DragEnd, ->
	card.animate
		properties: 
			x: 0
			y: 0
		time: 0.2
		curve: "spring(500,12,0)"
	#card.states.next()

wvt = 0.5
card.on Events.Click, ->
	closeBar.animate
		properties:
			opacity: 1
		time: wvt
	webView.animate
		properties: 
			y: closeBar.height
		time: wvt
		curve: "ease-out"

webView.on Events.Click, ->
	
closeBar.on Events.Click, ->
	closeBar.animate
		properties:
			opacity: 0
		time: wvt
	webView.animate
		properties: 
			y: stage.height
		time: wvt
		curve: "ease-out"