import os, httpclient, json, times, osproc
from strformat import `&`

const
  envKeyLambdaRuntimeApi = "AWS_LAMBDA_RUNTIME_API"
  envKeyHandler = "_HANDLER"

type
  LambdaClient = ref object
    client: HttpClient
    baseUrl: string

  Envs = ref object
    lambdaRuntimeApi: string
    handler: string

  Log = ref object
    timestamp: string
    level: string
    msg: string

proc info(msg: string) =
  echo(%* Log(timestamp: $now(), level: "info", msg: msg))

proc error(msg: string) =
  echo(%* Log(timestamp: $now(), level: "error", msg: msg))

proc newLambdaClient(url: string): LambdaClient =
  new result
  result.baseUrl = &"http://{url}/2018-06-01/runtime/invocation"

  var client = newHttpClient()
  client.headers = newHttpHeaders({ "Content-Type": "application/json"  })
  result.client = client

proc loadEnvs(): Envs =
  new result
  result.handler = getEnv(envKeyHandler)
  result.lambdaRuntimeApi = getEnv(envKeyLambdaRuntimeApi)

proc getNext(client: LambdaClient): (string, string) =
  let event = client.client.get(client.baseUrl & "/next")
  let reqId = event.headers["lambda-runtime-aws-request-id"]
  result = (event.body, $reqId)

proc postResponse(client: LambdaClient, reqId: string) =
  let body = %*{"msg":"ok"}
  discard client.client.postContent(&"{client.baseUrl}/{reqId}/response", body = $body)

proc postError(client: LambdaClient, reqId: string) =
  let body = %*{"msg":"lambda error"}
  discard client.client.postContent(&"{client.baseUrl}/{reqId}/error", body = $body)

proc main =
  let envs = loadEnvs()
  var client = newLambdaClient(envs.lambdaRuntimeApi)

  while true:
    let nextResp = client.getNext()
    let handler = envs.handler
    let eventData = nextResp[0]
    let requestId = nextResp[1]

    try:
      var p = startProcess("./" & handler, args = @[eventData], options = {poUsePath, poParentStreams})
      let exitCode = p.waitForExit(timeout = 3000)
      doAssert exitCode == 0, "function returns error"
      p.close()

      client.postResponse(requestId)
      info "正常終了"
    except:
      client.postError(requestId)
      error "異常終了"

when isMainModule:
  main()
