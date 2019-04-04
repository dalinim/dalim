import
  ast, idents, passes, lineinfos, tables, hashes

# debug 
import typetraits

from modulegraphs import ModuleGraph, PPassContext

type
  BModule = ref TDEXGen
  TDEXGen = object of PPassContext
    module: PSym
    graph: ModuleGraph

  PVar = ref object
    ## Info about a local variable
    reg0: int  # 1st Dalvik register used by var; for wide types, reg0+1 is implicitly also used

  PProc = ref TProc
  TProc = object
    # prc: PSym                # the Nim proc that this DEX proc belongs to
    nextReg: int               # index of the first register not matched to a variable yet
    locals: Table[string, PVar]  # local variables

proc getReg(p: PProc, v: PIdent): string =
  let id = v.s
  if not p.locals.contains(id):
    p.locals[id] = PVar(reg0: p.nextReg)
    inc(p.nextReg)
  let l = p.locals[id]
  return "v" & $l.reg0

# proc genVarInit(p: PProc, v: PSym, n: PNode) =
#   # TODO: super simplified for initial PoC
#   if n.kind == nkIntLit:
#     echo ".. const-wide/32 " & getReg(p, v) & ", " & $n.intVal

# proc genVarStmt(p: PProc, n: PNode) =
#   for i in countup(0, sonsLen(n) - 1):
#     var a = n.sons[i]
#     if a.kind != nkCommentStmt:
#       if a.kind == nkVarTuple:
#         discard
#       #   let unpacked = lowerTupleUnpacking(p.module.graph, a, p.prc)
#       #   genStmt(p, unpacked)
#       else:
#         assert(a.kind == nkIdentDefs)
#         assert(a.sons[0].kind == nkSym)
#         var v = a.sons[0].sym
#         # if lfNoDecl notin v.loc.flags and sfImportc notin v.flags:
#         #   genLineDir(p, a)
#         genVarInit(p, v, a.sons[2])

proc match(p: PProc, n: PNode, indent: string) =
  ## Main code generation "switch" procedure; inspired by gen() in jsgen.nim
  echo indent, n.kind
  case n.kind
  of nkStmtList, nkStmtListExpr, nkVarSection, nkEmpty, nkInfix:
    for i in countup(0, sonsLen(n) - 1):
      match(p, n.sons[i], indent & " ")
    # let isExpr = not isEmptyType(n.typ)
    # for i in countup(0, sonsLen(n) - 1 - isExpr.ord):
    #   # genStmt(p, n.sons[i])
    #   gen(p, n.sons[i])
    # # if isExpr:
    # #   gen(p, lastSon(n), r)
    # # echo repr(n)
  # of nkVarSection, nkLetSection: genVarStmt(p, n)
  of nkIdent:
    echo indent, " s=", repr(n.ident.s)
  of nkIntLit:
    echo indent, " intVal=", n.intVal
  of nkIdentDefs:
    if n.sons[0].kind == nkIdent and n.sons[2].kind == nkIntLit:
      echo ".. const-wide/32 " & getReg(p, n.sons[0].ident) & ", " & $n.sons[2].intVal
  else:
    discard

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
  # NOTES - various notes & discoveries made by reading the compiler code:
  # - hcr = Hot Code Reloading (most probably)
  # - PNode - type of Nim AST nodes
  # - helper command for faster compilation:
  #    $ compiler/nim0 c --nimcache:nimcache/d_linux_amd64 compiler/nim.nim
  #    $ compiler/nim1 dex --skipcfg arithm.nim
  #
  # jsgen.nim:
  # - entry point call path to gen(): myProcess() -> genModule() -> genStmt() -> gen()

#  echo n.kind
#  echo "@" & $n.info.line & ":" & $n.info.col

  procNode(n)

  result = n

  var p = PProc(
    locals: initTable[string, PVar](),
  )
  match(p, n, " ")


proc dexClose(graph: ModuleGraph; b: PPassContext, n: PNode): PNode =
  echo "STUB: close"

const DEXgenPass* = makePass(dexOpen, dexProcess, dexClose)
