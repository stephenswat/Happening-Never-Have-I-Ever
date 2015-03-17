Plugin = require 'plugin'
{tr} = require 'i18n'

questions = [
    ["stolen alcohol from my parents", true],
    ["cheated in a competition", false]
]

exports.indexToQuestion = (q) ->
    "Never have I ever " + questions[q][0]
