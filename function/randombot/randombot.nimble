# Package

version       = "0.1.0"
author        = "jiro4989"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["randombot"]

# Dependencies

requires "nim >= 1.4.4"


task muslBuild, "musl build":
  exec "nim musl -d:libressl src/randombot.nim"
  mvFile "src/randombot", "randombot"
