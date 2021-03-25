import os, httpclient, json, strutils, random, times
from strformat import `&`

const
  envKeyLambdaRuntimeApi = "AWS_LAMBDA_RUNTIME_API"
  envKeyHandler = "_HANDLER"
  envKeySlackToken = "SLACK_TOKEN"

type
  LambdaClient = ref object
    client: HttpClient
    baseUrl: string

  SlackRequest = object
    token: string
    text: string
    response_url: string

  SlackResponse = object
    text: string

  Envs = ref object
    lambdaRuntimeApi: string
    handler: string
    slackToken: string

  Log = ref object
    timestamp: string
    level: string
    msg: string

var
  envs: Envs

proc info(msg: string) =
  echo(%* Log(timestamp: $now(), level: "info", msg: msg))

proc error(msg: string) =
  echo(%* Log(timestamp: $now(), level: "error", msg: msg))

proc newLambdaClient(): LambdaClient =
  new result
  result.baseUrl = &"http://{envs.lambdaRuntimeApi}/2018-06-01/runtime/invocation"

  var client = newHttpClient()
  client.headers = newHttpHeaders({ "Content-Type": "application/json"  })
  result.client = client

proc loadEnvs(): Envs =
  new result
  result.handler = getEnv(envKeyHandler)
  result.lambdaRuntimeApi = getEnv(envKeyLambdaRuntimeApi)
  result.slackToken = getEnv(envKeySlackToken)
  if result.handler != "random":
    return nil

proc getNext(client: LambdaClient): (SlackRequest, string) =
  let event = client.client.get(client.baseUrl & "/next")
  let reqId = event.headers["lambda-runtime-aws-request-id"]
  let slackReq = event.body.parseJson.to(SlackRequest)
  result = (slackReq, $reqId)

proc postResponse(client: LambdaClient, reqId, body: string) =
  discard client.client.postContent(&"{client.baseUrl}/{reqId}/response", body = body)

proc postError(client: LambdaClient, reqId: string) =
  let body = %*{"msg":"lambda error"}
  discard client.client.postContent(&"{client.baseUrl}/{reqId}/error", body = $body)

proc main =
  envs = loadEnvs()
  if isNil(envs):
    # 環境変数不備
    error "環境変数が不足してます"
    return

  randomize()

  var client = newLambdaClient()
  let req = client.getNext()
  if envs.slackToken != req[0].token:
    # 知らないやつからのリクエストかも
    error "Slack tokenが不一致"
    return

  let selectedItem = req[0].text.split(" ").sample
  let resp = %* SlackResponse(text: selectedItem)
  try:
    client.postResponse(req[1], $resp)
    info "正常終了"
  except:
    client.postError(req[1])
    error "異常終了"

when isMainModule:
  main()
