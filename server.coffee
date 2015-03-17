Db = require 'db'

exports.onInstall = exports.onConfig = (config) ->
	Db.shared.set 'adult', config.adult if config?

	# if !Db.shared.get('rounds')
	# 	newRound()

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
