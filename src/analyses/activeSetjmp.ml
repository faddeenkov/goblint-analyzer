(** Analysis tracking which setjmp(s) are currently active *)

open Prelude.Ana
open Analyses

module Spec =
struct
  include Analyses.DefaultSpec

  let name () = "activeSetjmp"

  module D = JmpBufDomain.JmpBufSet
  module C = JmpBufDomain.JmpBufSet

  (* transfer functions *)
  let assign ctx (lval:lval) (rval:exp) : D.t =
    ctx.local

  let branch ctx (exp:exp) (tv:bool) : D.t =
    ctx.local

  let body ctx (f:fundec) : D.t =
    ctx.local

  let return ctx (exp:exp option) (f:fundec) : D.t =
    ctx.local

  let enter ctx (lval: lval option) (f:fundec) (args:exp list) : (D.t * D.t) list =
    [ctx.local, ctx.local]

  let combine ctx (lval:lval option) fexp (f:fundec) (args:exp list) fc (au:D.t) (f_ask:Queries.ask): D.t =
    ctx.local

  let special ctx (lval: lval option) (f:varinfo) (arglist:exp list) : D.t =
    let desc = LibraryFunctions.find f in
    match desc.special arglist with
    | Setjmp _ ->
      let entry = (ctx.prev_node, ctx.control_context ()) in
      D.add (Target entry) ctx.local
    | Longjmp {env; value; sigrestore} -> ctx.local
    | _ -> ctx.local

  let startstate v = D.bot ()
  let threadenter ctx lval f args = [D.bot ()]
  let threadspawn ctx lval f args fctx = ctx.local
  let exitstate v = D.top ()
  let context fundec v = v
  let should_join a b = D.equal a b

  let query ctx (type a) (q: a Queries.t): a Queries.result =
    match q with
    | ValidLongJmp -> (ctx.local: D.t)
    | _ -> Queries.Result.top q
end

let _ =
  MCP.register_analysis (module Spec : MCPSpec)
