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
	newsList


# 天気予報を取得
# TODO: リストで返すように
getWeatherAichi = (url, msg) ->
	client.fetch(url, {}, (err, $, res) ->
		if err
			console.log "error"
			return
		$("item > title").each (idx) ->
			if /(.*)PR(.*)/.test($(this).text())
				return
			msg.send $(this).text()
			
	)


module.exports = (robot) ->

	url = "http://www.nikkei.com/"
	aichiWeatherUrl = "http://weather.livedoor.com/forecast/rss/area/230010.xml"
	robot.respond /はいさい/i, (msg) ->
		msg.send "プロデューサー！はいさい！！"


	robot.hear /(.*)つらい(.*)/i, (msg) ->
		msg.send "よしよし"

	robot.hear /(.*)ニュース(.*)/i, (msg) ->
		msg.send "日経のニュースだぞ！"
		client.fetch(url, {}, (err, $, res) ->
			list = getNikkeiNews($, url)
			for n in list
				msg.send n.title
				msg.send n.link
		)
		
	# 天気
	robot.hear /天気/i, (msg) ->
		msg.send "ふふーん今週の天気はこんな感じだぞ!"
		getWeatherAichi(aichiWeatherUrl, msg)
		
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

	
	
	# 朝はニュースを全部出す
	cronjob2 = new cronJob(
		cronTime : "0 5 7 * * *"
		start : true
		timeZone : "Asia/Tokyo"
		onTick : ->
			msg.send "今日のニュースだぞ！"
			client.fetch(url, {}, (err, $, res) ->
				$('a[href^="/article"][target]').each ->
				msg.send $(this).text()
				msg.send URL.resolve(url, $(this).attr('href'))
			)
	)

	cronjob = new cronJob(
		cronTime : "0 0 7 * * *"
		start : true
		timeZone : "Asia/Tokyo"
		onTick : ->
			robot.send {room: "general"}, "起きてプロデューサー"
			return
	)
	
