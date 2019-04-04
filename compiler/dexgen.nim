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
    # TODO: store info about type of the variable

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

template dumpSons() {.dirty.} =
  for i in countup(0, sonsLen(n) - 1):
    match(p, n.sons[i], indent & " ")

proc match(p: PProc, n: PNode, indent: string) =
  ## Main code generation "switch" procedure; inspired by gen() in jsgen.nim
  echo indent, n.kind
  case n.kind
  of nkStmtList, nkStmtListExpr, nkVarSection, nkEmpty, nkInfix:
    dumpSons()
  of nkIdent:
    echo indent, " .ident.s=", repr(n.ident.s)
  of nkIntLit:
    echo indent, " .intVal=", n.intVal
  of nkIdentDefs:
    if n.sons[0].kind == nkIdent and n.sons[2].kind == nkIntLit:
      echo ".. const-wide/32 " & getReg(p, n.sons[0].ident) & ", " & $n.sons[2].intVal
    elif n.sons[0].kind == nkIdent and n.sons[2].kind == nkInfix:
      let op = n.sons[2]
      if op.sons[0].kind == nkIdent and op.sons[0].ident.s == "*" and op.sons[1].kind == nkIdent and op.sons[2].kind == nkIdent:
        echo ".. mul-int " & getReg(p, n.sons[0].ident) & ", " & getReg(p, op.sons[1].ident) & ", " & getReg(p, op.sons[2].ident)
      else:
        dumpSons()
    else:
      dumpSons()
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

  echo "----"
  var p = PProc(
    locals: initTable[string, PVar](),
  )
  match(p, n, " ")


proc dexClose(graph: ModuleGraph; b: PPassContext, n: PNode): PNode =
  echo "STUB: close"

const DEXgenPass* = makePass(dexOpen, dexProcess, dexClose)
