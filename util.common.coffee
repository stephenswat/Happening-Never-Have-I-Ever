Plugin = require 'plugin'
{tr} = require 'i18n'

exports.questions = questions = -> [
    ["stolen alcohol from my parents", true],
    ["cheated in a competition", false],
    ["eaten cake", false]
]

exports.indexToQuestion = (q) ->
    stringToQuestion questions[q][0]

exports.stringToQuestion = stringToQuestion = (s) ->
    "Never have I ever " + s
