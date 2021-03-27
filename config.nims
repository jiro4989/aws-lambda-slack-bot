task setup, "setup":
  exec "pip3 install --user awscli"

task buildDist, "build bootstrap":
  mkdir "dist"
  withDir "bootstrap":
    exec "nimble createZip"
    mvFile "bootstrap.zip", "../dist/bootstrap.zip"
  withDir "function/randombot":
    exec "nimble createZip"
    mvFile "randombot.zip", "../../dist/randombot.zip"

task deployFunction, "deploy aws lambda function":
  exec "~/.local/bin/aws lambda update-function-code --function-name randombot --zip-file fileb://dist/randombot.zip"
