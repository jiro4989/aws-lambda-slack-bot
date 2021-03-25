# Package

version       = "0.1.0"
author        = "jiro4989"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["bootstrap"]


# Dependencies

requires "nim >= 1.4.4"

import strformat

let
  functionName = "random"

task createZip, "build bootstrap and create zip":
  selfExec "build -d:ssl -d:release"
  exec &"zip -r {functionName}.zip bootstrap"

task deploy, "deploy lambda script to aws":
  selfExec "createZip"
  exec "aws lambda update-function-code --function-name {functionName} --zip-file file://{functionName}.zip --publish"
