###
# API
###
articlesJSON = "http://10.51.218.159:8080/hackweek/articles" 
#"/nytinder.framer/data/articles.json" #
relatedJSON = "http://10.51.218.159:8080/hackweek/related" 
#"/nytinder.framer/data/related.json" #

###
# USER DATA MANAGEMENT
###
userData = if localStorage["userData"] then JSON.parse localStorage["userData"] else {}
userData.articles = userData.articles || {}
userData.banned = userData.banned || {}
storeArticle = (article, storeAsBanned = false) ->
  unless storeAsBanned
    userData.articles[article.url] = article
    delete userData.banned[article.url]
  else
    userData.banned[article.url] = article
    delete userData.articles[article.url]
updateLocalStorage = ->
  localStorage["userData"] = JSON.stringify userData
clearData = ->
  userData = {}
  userData.articles = {}
  userData.banned = {}
  localStorage["userData"] = JSON.stringify userData
isEmpty = (o) ->
  for k, v of o 
    return false
  return true

###
# CREATE UI
###
stage = new BackgroundLayer()
stage.backgroundColor = "#eeeeee";

###
# CREATE WEB VIEW
###

webView = new Layer
  width: stage.width
  height: stage.height
  backgroundColor: "#eeeeee"
webView.y = stage.height
webView.shadowY = -10;
webView.shadowColor = "rgba(0,0,0,0.2)"
webView.shadowBlur = 30
webView.superLayer = stage

closeBar = new Layer
  width: stage.width
  height: 100
  backgroundColor: "#ffffff"
closeBar.style["border-bottom"] = "1px solid #999"
closeBar.superLayer = webView
closeBar.html = document.getElementById("webview-closebar").innerHTML

iframeView = new Layer
  width: stage.width
  height: stage.height - 100
  backgroundColor: "#ffffff"
iframeView.y = closeBar.height;
iframeView.superLayer = webView
iframeViewTPL = _.template document.getElementById("webview-iframe").innerHTML

# Events
closeBar.on Events.Click, ->
  webView.animate
    properties: 
      y: stage.height
    time: 0.3
    curve: "ease-out"

iframeView.on Events.Click, ->

###
# PREPARE CARD VIEW FACTORY
###
cardsView = new Layer
  width: stage.width
  height: stage.height
  backgroundColor: "#eeeeee"
cardsView.superLayer = stage
cardsView.placeBehind(webView)

# Refill view
refillView = new Layer
  width: stage.width
  height: stage.height
  backgroundColor : "#222"
refillView.style["box-shadow"] = "inset 0 0 200px black";
refillView.html = document.getElementById("refill-view").innerHTML
refillView.superLayer = cardsView
refillView.on Events.Click, ->
  unless refillView.classList.contains "empty"
    # Render cards if there's any more items
    renderCards(userData.articles)
  else
    # Reset storage and load from scratch
    clearData()
    loadArticles(articlesJSON, renderCards)

updateRefillView = ->
  if isEmpty userData.articles
    refillView.classList.add "empty" unless refillView.classList.contains "empty"
  else
    refillView.classList.remove "empty" if refillView.classList.contains "empty"

# Init single cards
cardTPL = _.template document.getElementById("article-card").innerHTML
cards = []
makeCard = (article) ->
  card = new Layer
    width: stage.width
    height: stage.height
    backgroundColor: "#ffffff"
  card.center()
  card.brightness = 70
  card.article = article
  card.x0 = card.x
  card.y0 = card.y
  card.html = cardTPL article
  card.superLayer = cardsView
  card.draggable.enable = true
  card.shadowColor = "rgba(0,0,0,0.3)"
  card.shadowBlur = 50
  card.draggable.speedY = 0

  # Add states
  card.states.add
    "front":
      brightness: 100
    "back":
      brightness: 70
    "yay": 
      rotationZ: 90
      x: card.width*2 
    "nay":
      rotationZ: -90
      x: -card.height
    "default":
      rotationZ: 0
      x: card.x0
  card.states.animationOptions = 
    curve: "spring(100, 10, 0)"

  # Add card events
  card.on Events.TouchMove, (event, card) ->
    card.rotationZ = (card.x - card.x0)*.1

  card.on Events.TouchEnd, (event, card) ->
    if(card.x == card.x0 && card.y == card.y0)
      onCardClick event, card
    else if(Math.abs(card.x - card.x0) > stage.width*.4)
      if(card.x > card.x0)
        card.states.switch("yay")
        loadArticles(relatedJSON + "?url=" + card.article.url)
      else
        card.states.switch("nay")
        storeArticle(article, true)
        updateLocalStorage()
      # Update back
      updateRefillView()
      # Highlight next
      cards.pop()
      if cards.length then cards[cards.length - 1].states.switch("front")
    else
      card.states.switch("default")

  card.on Events.AnimationEnd, (event, card) ->
    if card.rotationZ then card.destroy()

  # Return
  return card

onCardClick = (event, card) ->
  iframeView.html = iframeViewTPL card.article
  webView.animate
    properties: 
      y: 0
    time: 0.3
    curve: "ease-out"

###
# GET DATA
###

loadXMLDoc = (url, success, error = ->) ->
  xmlhttp = new XMLHttpRequest()
  xmlhttp.onload = ->
    if(xmlhttp.status == 200)
      success(xmlhttp)
    else
      error(xmlhttp)
  xmlhttp.open("GET", url, true);
  xmlhttp.send();

loadArticles = (url, success)->
  loadXMLDoc url, (xmlhttp) ->
    data = JSON.parse xmlhttp.responseText
    data.articles.forEach (article) ->
      unless userData.banned[article.url]
        article.width = stage.width
        article.height = stage.height
        storeArticle(article)
    updateLocalStorage()
    updateRefillView()
    if success? then success(userData.articles)

renderCards = (articles) ->
  i = 10
  Object.keys(articles).forEach (url) ->
    cards.push makeCard articles[url] if --i >= 0
  if cards.length then cards[cards.length - 1].states.switch("front")

###
# INIT
###
unless isEmpty userData.articles
  renderCards(userData.articles)
else
  loadArticles(articlesJSON, renderCards)