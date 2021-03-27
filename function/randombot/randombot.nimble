# Package

version       = "0.1.0"
author        = "jiro4989"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
bin           = @["randombot"]

# Dependencies

requires "nim >= 1.4.4"


task createZip, "create zip":
  #exec "nimble build -d:ssl -d:release --gcc.exe:musl-gcc --gcc.linkerexe:musl-gcc --passL:-static "
  exec "nimble build -d:ssl -d:release"
  exec "zip -r randombot.zip randombot"
