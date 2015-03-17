Db = require 'db'
Dom = require 'dom'
Modal = require 'modal'
Obs = require 'obs'
Plugin = require 'plugin'
Page = require 'page'
Server = require 'server'
Ui = require 'ui'
Form = require 'form'
{tr} = require 'i18n'
Util = require 'util'

exports.render = ->
	if Page.state.get(0) is 'advanced'
		renderAdvanded()

	Dom.div !->
		Dom.style fontSize: '150%', fontWeight: 'bold', textShadow: '0 1px 0 #fff', textAlign: 'center', padding: '4px 10px 10px 10px'
		Dom.text Util.indexToQuestion(0)

	Ui.bigButton 'I have!', ->
		{}.noSuchMethod()

	Ui.bigButton 'I have not!', ->
		{}.noSuchMethod()

	Ui.bigButton 'Go to advanced...', -> Page.nav ['advanced']

renderAdvanded = ->
	Dom.h2 "Hello, World!"

	Obs.observe ->
		# We're inside an additional observe scope here, such that our whole
		# exports.render function won't need to rerun when the counter changes
		# value.
		currentValue = Db.shared.get('counter') # a reactive read from the shared database
		Ui.bigButton "#{currentValue}++", ->
			Server.call 'incr'

	Ui.bigButton 'get server time', ->
		Server.call 'getTime', (time) ->
			Modal.show "it is now: #{time}"

	Ui.bigButton 'client error', ->
		{}.noSuchMethod()

	Ui.bigButton 'server error', ->
		Server.call 'error'

	Dom.div ->
		Dom.style
			padding: "10px"
			margin: "3%"
			color: Plugin.colors().barText
			backgroundColor: Plugin.colors().bar
			_userSelect: 'text' # the underscore gets replace by -webkit- or whatever else is applicable
		Dom.h2 Db.shared.get('http') || "HTTP end-point demo"
		Dom.code "curl --data-binary 'your text' " + Plugin.inboundUrl()

	Ui.list ->
		items =
			"Db.local": Db.local.get()
			"Db.personal": Db.personal.get()
			"Db.shared": Db.shared.get()
			"Plugin.agent": Plugin.agent()
			"Plugin.groupAvatar": Plugin.groupAvatar()
			"Plugin.groupCode": Plugin.groupCode()
			"Plugin.groupId": Plugin.groupId()
			"Plugin.groupName": Plugin.groupName()
			"Plugin.userAvatar": Plugin.userAvatar()
			"Plugin.userId": Plugin.userId()
			"Plugin.userIsAdmin": Plugin.userIsAdmin()
			"Plugin.userName": Plugin.userName()
			"Plugin.users": Plugin.users.get()
			"Page.state": Page.state.get()
			"Dom.viewport": Dom.viewport.get()
		for name,value of items
			text = "#{name} = " + JSON.stringify(value)
			Ui.item text.replace(/,/g, ', ') # ensure some proper json wrapping on small screens

exports.renderSettings = !->
	Dom.div !->
		Dom.style margin: '16px -8px'

		Form.sep()

		Form.check
			text: tr("Allow 18+ questions")
			name: 'adult'
			value: if Db.shared then Db.shared.func('adult')
		Form.sep()

		if Db.shared
			Ui.button !->
				Dom.style marginTop: '14px'
				Dom.text tr("Start new round now")
			, !-> Server.call 'newRound'
