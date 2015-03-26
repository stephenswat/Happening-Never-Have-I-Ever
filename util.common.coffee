Plugin = require 'plugin'
{tr} = require 'i18n'

exports.questions = questions = -> [
    ["stolen alcohol from my parents", true],
    ["cheated in a competition", false],
    ["eaten cake", false]
]

# determines duration of the round started at 'currentTime'
exports.getRoundDuration = (currentTime) ->
    return false if !currentTime

    duration = 6*3600
    while 22 <= (hrs = (new Date((currentTime+duration)*1000)).getHours()) or hrs <= 9
        duration += 6*3600

    duration * 1000

exports.indexToQuestion = (q) ->
    stringToQuestion questions[q][0]

exports.stringToQuestion = stringToQuestion = (s) ->
    "Never have I ever " + s
