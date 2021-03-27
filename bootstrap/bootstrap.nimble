# Package

version       = "0.1.0"
author        = "jiro4989"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["bootstrap"]

# Dependencies

requires "nim >= 1.4.4"

task createZip, "build bootstrap and create zip":
  exec "nimble build -d:ssl -d:release"
  exec "zip -r bootstrap.zip bootstrap"
