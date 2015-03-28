Db = require 'db'
Dom = require 'dom'
Modal = require 'modal'
Obs = require 'obs'
Plugin = require 'plugin'
Page = require 'page'
Server = require 'server'
Timer = require 'timer'
Ui = require 'ui'
Icon = require 'icon'
Form = require 'form'
{tr} = require 'i18n'
Util = require 'util'
Social = require 'social'
Event = require 'event'
Time = require 'time'

exports.render = ->
	if Page.state.get(0) is 'round'
		renderRound(Page.state.get(1))
	else
		renderRoundList()

getRoundList = ->
	round_list = []

	Db.shared.ref('rounds').observeEach (round) !->
		round_list.push round

	round_list

renderRound = (round_no) ->
	round = Db.shared.ref 'rounds', round_no

	Dom.div ->
		Dom.style fontSize: '300%', fontWeight: 'bold', textShadow: '0 1px 0 #fff', textAlign: 'center', padding: '4px 10px 10px 10px'
		Dom.text Util.stringToQuestion(round.get('question'))

	if !round.get('finished')
		ranking = Db.personal.ref('rounds', round_no)
		my_vote = Db.shared.get('votes', Plugin.userId()) || null

		if my_vote
			Ui.button ->
				Dom.style marginTop: '14px', marginLeft: '0px', backgroundColor: (if my_vote == 2 then "#aaa" else ""), textAlign: 'center', fontSize: '120%', width: '45%'
				Dom.text 'I have!'
			, -> Server.call 'registerVote', Plugin.userId(), 1

			Ui.button ->
				Dom.style marginTop: '14px', marginRight: '0px', backgroundColor: (if my_vote == 1 then "#aaa" else ""), textAlign: 'center', fontSize: '120%', width: '45%'
				Dom.text 'I have not!'
			, -> Server.call 'registerVote', Plugin.userId(), 2
		else
			Ui.bigButton ->
				Dom.style marginTop: '14px', marginLeft: '0px', height: '90px', textAlign: 'center', fontSize: '250%', paddingTop: '50px'
				Dom.text 'I have!'
			, -> Server.call 'registerVote', Plugin.userId(), 1

			Ui.bigButton ->
				Dom.style marginTop: '14px', marginRight: '0px', height: '90px', textAlign: 'center', fontSize: '250%', paddingTop: '50px'
				Dom.text 'I have not!'
			, -> Server.call 'registerVote', Plugin.userId(), 2

	if round.get('finished') or Db.shared.get('votes', Plugin.userId())
		did = []
		didnt = []

		Plugin.users.observeEach (user) ->
			if round.get('finished')
				if round.get('result', user.key()) == 1
					did.push user.key()
				if round.get('result', user.key()) == 2
					didnt.push user.key()
			else
				if Db.shared.get('votes', user.key()) == 1
					did.push user.key()
				if Db.shared.get('votes', user.key()) == 2
					didnt.push user.key()

		if did.length > 0
			Dom.h1 (if did.length == 1 then 'One person has.' else did.length + ' people have.')

			Ui.list ->
				for i in did
					Ui.item ->
						Ui.avatar Plugin.userAvatar(i)
						Dom.text Plugin.userName(i)

		if didnt.length > 0
			Dom.h1 (if didnt.length == 1 then 'One person hasn\'t.' else didnt.length + ' people haven\'t.')

			Ui.list ->
				for i in didnt
					Ui.item ->
						Ui.avatar Plugin.userAvatar(i)
						Dom.text Plugin.userName(i)

	Social.renderComments round_no

renderRoundList = ->
	renderRoundItem = (round) ->
		Ui.item ->
			if !round.get('finished') and !Db.shared.get('votes', Plugin.userId())
				Icon.render data: 'new', style: { display: 'block', margin: '0 10 0 0' }, size: 34

			Event.renderBubble [round.key()], style: marginLeft: '4px'

			# if unread = Social.newComments(round.key())
			# 	Dom.div !->
			# 	Ui.unread unread, null, {marginLeft: '4px'}

			Dom.div !->
				Dom.style Flex: 1

				Dom.b !->
					Dom.text Util.stringToQuestion(round.get('question'))

				if !round.get('finished')
					Dom.div ->
						Dom.text "Next round "
						Time.deltaText(Db.shared.get('next'))

			Dom.onTap -> Page.nav ['round', round.key()]

	Ui.list ->
		for i in getRoundList() by -1
			renderRoundItem(i)

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
			, !-> Server.call 'nextRound'
