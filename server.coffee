Db = require 'db'
Util = require 'util'

questions = Util.questions()

exports.onInstall = exports.onConfig = exports.onUpgrade = exports.onJoin = (config) ->
	Db.shared.set 'adult', config.adult if config?

	if !Db.shared.get('rounds')
		newRound()

newRound = ->
	eligable = []
	adult = Db.shared.get 'adult'
	previous = Db.shared.get('rounds', 'previous') || 0

	for s, a in questions
		if a >= adult
			eligable.push s

	if eligable.length
		index = Math.floor(Math.random() * eligable.length)
		question = question[index][0]
		time = 0|(Date.now()*.001)

		Db.shared.set 'rounds', maxId,
			qid: newQid
			question: questions[newQid][0]
			time: time

		roundDuration = Util.getRoundDuration(time)

		Timer.cancel()
		Timer.set roundDuration*1000, 'newRound'
		
		Db.shared.set 'next', time+roundDuration

# exported functions prefixed with 'client_' are callable by our client code using `require('plugin').rpc`
exports.client_incr = ->
	log 'hello world!' # write to the plugin origin's log
	Db.shared.modify 'counter', (v) -> v+1

exports.client_getTime = (cb) ->
	cb.reply new Date()

exports.client_error = ->
	{}.noSuchMethod()

exports.onHttp = (request) ->
	if (data = request.data)?
		Db.shared.set 'http', data
	else
		data = Db.shared.get('http')
	request.respond 200, data || "no data"
