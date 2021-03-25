import json, os, httpclient, strutils, random

type
  Envs = ref object
    slackToken: string

  SlackRequest = object
    token: string
    text: string
    response_url: string

  SlackResponse = object
    text: string

proc loadEnvs(): Envs =
  new result
  let token = getEnv("SLACK_TOKEN")
  if token == "":
    return nil
  result.slackToken = token

proc main =
  let envs = loadEnvs()
  if isNil(envs):
    # 環境設定不備かも
    return

  let args = commandLineParams()
  let slack = args[0].parseJson.to(SlackRequest)
  if slack.token != envs.slackToken:
    # 不正なリクエストかも
    return

  randomize()
  let selectedItem = slack.text.split(" ").sample

  var client = newHttpClient()
  client.headers = newHttpHeaders({ "Content-Type": "application/json"  })

  let body = $(%* SlackResponse(text: selectedItem))
  discard client.postContent(slack.response_url, body = body)

when isMainModule:
  main()
