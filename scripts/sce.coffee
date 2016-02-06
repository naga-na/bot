
cronJob = require('cron').CronJob

module.exports = (robot) ->
	cronJob = new cronJob (
		cronTime: "0 0 16 * * *"
		start: true
		timeZone: "Asia/Tokyo"
		onTick: ->
		robot.send {room: "#ROOM_NAME"}, "時間だぞ！"
		)
	
