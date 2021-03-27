import json, os, httpclient, strutils, random, base64, sequtils, uri

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
  # if token == "":
  #   return nil
  result.slackToken = token

proc getParam(s, key: string): string =
  result = s.split("&").mapIt(it.split("=")).filterIt(it[0] == key)[0][1].decodeUrl(true)

proc main =
  let envs = loadEnvs()
  if isNil(envs):
    # 環境設定不備かも
    return

  let args = commandLineParams()
  let text = args[0].parseJson["body"].getStr.decode.getParam("text")
  let respUrl = args[0].parseJson["body"].getStr.decode.getParam("response_url")
  if respUrl == "":
    # 不正アクセスかも
    return

  randomize()
  let selectedItem = text.split(" ").sample

  var client = newHttpClient()
  client.headers = newHttpHeaders({ "Content-Type": "application/json"  })

  let body = $(%* SlackResponse(text: selectedItem))
  discard client.postContent(respUrl, body = body)

when isMainModule:
  main()
