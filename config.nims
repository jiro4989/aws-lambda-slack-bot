task buildDist, "build bootstrap":
  mkdir "dist"
  withDir "bootstrap":
    exec "nimble createZip"
    mvFile "bootstrap.zip", "../dist/bootstrap.zip"
  withDir "function/randombot":
    exec "nimble createZip"
    mvFile "randombot.zip", "../../dist/randombot.zip"
