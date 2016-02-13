# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md
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


module.exports = (robot) ->

	url = "http://www.nikkei.com/"
	
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
	new cronJob(
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
	
	
	
	###
	cronjob3 = new cronJob(
		cronTime : "0 30 * * * *"
		start : true
		timeZone : "Asia/Tokyo"
		onTick : ->
			robot.send {room: "general"}, "そのうち豆知識を披露しちゃうからな？ほんとだぞ！？"
			return
	)
	###

	# send HTTP request
	


  # robot.hear /badger/i, (res) ->
  #   res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
