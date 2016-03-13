cronJob = require('cron').CronJob
request = require 'request'
client = require 'cheerio-httpcli'
URL = require 'url'

# 日経のニュースを取得する
getNikkeiNews = ($, url) ->
	newsList = []
	$('a[href^="/article"][target]').each ->
		# TODO:でかい画像のリンクを消す
		if /(.)*\?bu=(.*)/.test($(this).attr('href')) is false
			t = $(this).text()
			l = URL.resolve(url, $(this).attr('href'))
			if t.length isnt 0 and /^◇/.test(t) is false
				newsList.push {title: t, link : l}
	return(newsList)


# 天気予報を取得
getWeatherAichi = ($, url) ->
	weatherList = []
	$("item > title").each (idx) ->
		# 天気以外の情報を除く
		if /(.*)PR(.*)/.test($(this).text())
			return
		weatherList.push $(this).text()
	return(weatherList)


# yahoo newsを取得する
getYahooNews = ($, url) ->
	newsList = []
	$('#epTabTop .ttl a').each ->
		ttl = $(this).text()
		ln = URL.resolve(url, $(this).attr('href'))
		newsList.push {title: ttl, link: ln}
	return(newsList)
	

module.exports = (robot) ->
	
	# 取得URL先
	yahooUrl = "http://news.yahoo.co.jp/"
	nikkeiUrl = "http://www.nikkei.com/"
	aichiWeatherUrl = "http://weather.livedoor.com/forecast/rss/area/230010.xml"
	
	# レスポンス
	robot.respond /はいさい/i, (msg) ->
		msg.send "プロデューサー！はいさい！！"

	robot.hear /(.*)つらい(.*)/i, (msg) ->
		msg.send "よしよし"

	# ニュース
	robot.hear /(.*)にっけいニュース(.*)/i, (msg) ->
		msg.send "日経のニュースだぞ！"
		client.fetch(nikkeiUrl, {}, (err, $, res) ->
			list = getNikkeiNews($, nikkieiUrl)
			for n in list
				msg.send n.title
				msg.send n.link
		)
		
	robot.hear /(.*)ニュース(.*)/i, (msg) ->
		msg.send "やふーにゅーすだぞ"
		sayYahooNews(msg, yahooUrl)
		
	sayYahooNews = (msg, yahooUrl) ->
		client.fetch(yahooUrl, {}, (err, $, res) ->
			list = getYahooNews($, yahooUrl)
			for n in list
				msg.send n.title
				msg.send n.link
		)
		
	# 天気
	robot.hear /(.*)天気(.*)/i, (msg) ->
		msg.send "ふふーん今週の天気はこんな感じだぞ!"
		client.fetch(aichiWeatherUrl, {}, (err, $, res) ->
			list = getWeatherAichi($, aichiWeatherUrl)
			for n in list
				msg.send n
		)
		
	
	# 起きた時
	cid = setInterval ->
		return if typeof robot?.send isnt 'function'
		robot.send {room: "general"}, "おはようプロデューサー！ 今日も頑張ろうね"
		clearInterval cid
	, 1000


	# 寝るとき
	on_sigterm = ->
		robot.send {room: "general"}, "今日も疲れたぞ〜。おやすみプロデューサー！"
		setTimeout process.exit, 1000

	if process._events.SIGTERM?
		process._events.SIGTERM = on_sigterm
	else
		process.on 'SIGTERM', on_sigterm

	
	
	# 朝のあいさつと必要情報をつぶやく
	cronjob = new cronJob(
		cronTime : "0 0 7 * * *"
		start : true
		timeZone : "Asia/Tokyo"
		onTick : ->
			robot.send {room: "general"}, "起きてプロデューサー"
			# ニュース取得
			client.fetch(yahooUrl, {}, (err, $, res) ->
				list = getYahooNews($, yahooUrl)
				for n in list
					robot.send {room: "general"}, n.title
					robot.send {room: "general"}, n.link
			)
			# 天気
			client.fetch(aichiWeatherUrl, {}, (err, $, res) ->
				list = getWeatherAichi($, aichiWeatherUrl)
				for n in list
					robot.send {room: "general"}, n
			)

	)
	
	
	
