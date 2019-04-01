import passes

# Open, Process and Close are used to create pass object
proc dexOpen(graph: ModuleGraph; module: PSym): PPassContext =
  echo "STUB: dexOpen"
#  result = newModule(graph,s)

proc myProcess(b: PPassContext, n: PNode): PNode =
  echo "STUB: myProcess"

proc dexClose(graph: ModuleGraph; b: PPassContext, n: PNode): PNode =
  echo "STUB: close"

const DEXgenPass = makePass(dexOpen, dexProcess, dexClose)
