import
  ast,passes,lineinfos

# debug 
import typetraits

from modulegraphs import ModuleGraph, PPassContext

type TDEXGen = object of PPassContext
  module: PSym
  graph: ModuleGraph

type BModule = ref TDEXGen

proc newModule(g: ModuleGraph; module: PSym): BModule =
  new(result)
  result.graph = g
  result.module = module

proc procNode(n: PNode) =
  case n.kind:
  of nkStmtList,nkStmtListExpr:
    echo "Statement list: "
    for i in countup(0,n.sonsLen-1):
      procNode(n.sons[i])
  else:
    echo n.kind
  
# Open, Process and Close are used to create pass object
proc dexOpen(graph: ModuleGraph; module: PSym): PPassContext =
  result = newModule(graph,module)

proc dexProcess(b: PPassContext, n: PNode): PNode =
#  echo n.kind
#  echo "@" & $n.info.line & ":" & $n.info.col

  procNode(n)

  result = n

proc dexClose(graph: ModuleGraph; b: PPassContext, n: PNode): PNode =
  echo "STUB: close"

const DEXgenPass* = makePass(dexOpen, dexProcess, dexClose)
