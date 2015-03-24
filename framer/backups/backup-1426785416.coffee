# Grab Data
articlesJSON = #http://10.51.218.159:8080/hackweek/articles" #/nytinder.framer/data/articles.json"
loadXMLDoc = (url, success, error = ->) ->
  xmlhttp = new window.XMLHttpRequest()
  xmlhttp.onload = ->
    if(xmlhttp.status == 200)
      success(xmlhttp)
    else
      error(xmlhttp)
  xmlhttp.open("GET", url, true);
  xmlhttp.send();

data = {};
loadXMLDoc articlesJSON, (xmlhttp) ->
  data = JSON.parse xmlhttp.responseText
  articles = data.articles
  console.log(data.articles.forEach)

# CREATE UI
stage = new BackgroundLayer()
###
###
# CREATE WEB VIEW
###

webView = new Layer
  width: stage.width
  height: stage.height
webView.y = stage.height
webView.shadowY = -10;
webView.shadowColor = "rgba(0,0,0,0.2)"
webView.shadowBlur = 30

closeBar = new Layer
  width: stage.width
  height: 100
  backgroundColor: '#ffffff'
closeBar.borderBottom = "1px solid #999"
closeBar.superLayer = webView
closeBar.html = document.getElementById('webview-closebar').innerHtml

iframeView = new Layer
  width: stage.width
  height: stage.height
  backgroundColor: '#ffffff'
iframe.y = closeBar.height;
iframeView.superLayer = webView
iframeView.html = document.getElementById('webview-iframe').innerHtml

# Events
closeBar.on Events.Click, ->
  webView.animate
    properties: 
      y: stage.height
    time: wvt
    curve: "ease-out"

iframeView.on Events.Click, ->


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
      y: 0
    time: wvt
    curve: "ease-out"


  
###