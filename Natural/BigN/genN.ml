(************************************************************************)
(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)
(* <O___,, * CNRS-Ecole Polytechnique-INRIA Futurs-Universite Paris Sud *)
(*   \VV/  **************************************************************)
(*    //   *      This file is distributed under the terms of the       *)
(*         *       GNU Lesser General Public License Version 2.1        *)
(************************************************************************)

(*i $Id$ i*)

(*S genN.ml : this file generates NMake.v *)


(*s The two parameters that control the generation: *)

let size = 6 (* how many times should we repeat the Z/nZ --> Z/2nZ 
                process before relying on a generic construct *)
let gen_proof = true  (* should we generate proofs ? *)


(*s Some utilities *)

let t = "t"
let c = "N"
let pz n = if n == 0 then "w_0" else "W0"
let rec gen2 n = if n == 0 then "1" else if n == 1 then "2"
                 else "2 * " ^ (gen2 (n - 1))
let rec genxO n s = 
  if n == 0 then s else " (xO" ^ (genxO (n - 1) s) ^ ")"

(* Standard printer, with a final newline *)
let pr s = Printf.printf (s^^"\n")
(* /dev/null printer *)
let pn s = Printf.ifprintf stdout s
(* Proof printer : prints iff gen_proof is true *)
let pp = if gen_proof then pr else pn
(* Printer for admitted parts : prints iff gen_proof is false *)
let pa = if gen_proof then pn else pr
(* Same as before, but without the final newline *)
let pr0 = Printf.printf
let pp0 = if gen_proof then pr0 else pn


(*s The actual printing *)

let _ = 

  pr "(************************************************************************)";
  pr "(*  v      *   The Coq Proof Assistant  /  The Coq Development Team     *)";
  pr "(* <O___,, * CNRS-Ecole Polytechnique-INRIA Futurs-Universite Paris Sud *)";
  pr "(*   \\VV/  **************************************************************)";
  pr "(*    //   *      This file is distributed under the terms of the       *)";
  pr "(*         *       GNU Lesser General Public License Version 2.1        *)";
  pr "(************************************************************************)";
  pr "";
  pr "(**";
  pr "- Authors: Benjamin Grégoire, Laurent Théry";
  pr "- Institution: INRIA";
  pr "- Date: 2007";
  pr "- Remark: File automatically generated, DO NOT EDIT, see genN.ml instead";
  pr "*)";
  pr "";
  pr "Require Import BigNumPrelude.";
  pr "Require Import ZArith.";
  pr "Require Import Basic_type.";
  pr "Require Import ZnZ.";
  pr "Require Import Zn2Z.";
  pr "Require Import Nbasic.";
  pr "Require Import GenMul.";
  pr "Require Import GenDivn1.";
  pr "Require Import Wf_nat.";
  pr "Require Import StreamMemo.";
  pr "";
  pr "Module Type W0Type.";
  pr " Parameter w : Set.";
  pr " Parameter w_op : znz_op w.";
  pr " Parameter w_spec : znz_spec w_op.";
  pr "End W0Type.";
  pr "";
  pr "Module Make (W0:W0Type).";
  pr " Import W0.";
  pr "";

  pr " Definition w0 := W0.w.";
  for i = 1 to size do
    pr " Definition w%i := zn2z w%i." i (i-1)
  done;
  pr "";

  pr " Definition w0_op := W0.w_op.";
  for i = 1 to 3 do
    pr " Definition w%i_op := mk_zn2z_op w%i_op." i (i-1)
  done;
  for i = 4 to size + 3 do
    pr " Definition w%i_op := mk_zn2z_op_karatsuba w%i_op." i (i-1)
  done;
  pr "";

  pr " Section Make_op.";
  pr "  Variable mk : forall w', znz_op w' -> znz_op (zn2z w').";
  pr "";
  pr "  Fixpoint make_op_aux (n:nat) : znz_op (word w%i (S n)):=" size;
  pr "   match n return znz_op (word w%i (S n)) with" size;
  pr "   | O => w%i_op" (size+1);
  pr "   | S n1 =>";
  pr "     match n1 return znz_op (word w%i (S (S n1))) with" size;
  pr "     | O => w%i_op" (size+2);
  pr "     | S n2 =>";
  pr "       match n2 return znz_op (word w%i (S (S (S n2)))) with" size;
  pr "       | O => w%i_op" (size+3);
  pr "       | S n3 => mk _ (mk _ (mk _ (make_op_aux n3)))";
  pr "       end";
  pr "     end";
  pr "   end.";
  pr "";
  pr " End Make_op.";
  pr "";
  pr " Definition omake_op := make_op_aux mk_zn2z_op_karatsuba.";
  pr "";
  pr "";
  pr " Definition make_op_list := dmemo_list _ omake_op.";
  pr "";
  pr " Definition make_op n := dmemo_get _ omake_op n make_op_list.";
  pr "";
  pr " Lemma make_op_omake: forall n, make_op n = omake_op n.";
  pr " intros n; unfold make_op, make_op_list.";
  pr " refine (dmemo_get_correct _ _ _).";
  pr " Qed.";
  pr "";

  pr " Inductive %s_ : Set :=" t;
  for i = 0 to size do 
    pr "  | %s%i : w%i -> %s_" c i i t
  done;
  pr "  | %sn : forall n, word w%i (S n) -> %s_." c size t;
  pr "";
  pr " Definition %s := %s_." t t;
  pr "";

  pr " Definition w_0 := w0_op.(znz_0).";
  pr "";

  for i = 0 to size do
    pr " Definition one%i := w%i_op.(znz_1)." i i
  done;
  pr "";


  pr " Definition zero := %s0 w_0." c;
  pr " Definition one := %s0 one0." c;
  pr "";

  pr " Definition to_Z x :=";
  pr "  match x with";
  for i = 0 to size do
    pr "  | %s%i wx => w%i_op.(znz_to_Z) wx" c i i
  done;
  pr "  | %sn n wx => (make_op n).(znz_to_Z) wx" c;
  pr "  end.";
  pr "";

  pr " Open Scope Z_scope.";
  pr " Notation \"[ x ]\" := (to_Z x).";
  pr " ";


  pp " (* Regular make op (no karatsuba) *)";
  pp " Fixpoint nmake_op (ww:Set) (ww_op: znz_op ww) (n: nat) : ";
  pp "       znz_op (word ww n) :=";
  pp "  match n return znz_op (word ww n) with ";
  pp "   O => ww_op";
  pp "  | S n1 => mk_zn2z_op (nmake_op ww ww_op n1) ";
  pp "  end.";
  pp "";
  pp " (* Simplification by rewriting for nmake_op *)";
  pp " Theorem nmake_op_S: forall ww (w_op: znz_op ww) x, ";
  pp "   nmake_op _ w_op (S x) = mk_zn2z_op (nmake_op _ w_op x).";
  pp " auto.";
  pp " Qed.";
  pp "";


  pr " (* Eval and extend functions for each level *)";
  for i = 0 to size do
    pp " Let nmake_op%i := nmake_op _ w%i_op." i i;
    pp " Let eval%in n := znz_to_Z  (nmake_op%i n)." i i;
    if i == 0 then 
      pr " Let extend%i := GenBase.extend  (WW w_0)." i
    else
      pr " Let extend%i := GenBase.extend  (WW (W0: w%i))." i i;
  done;
  pr "";


  pp " Theorem digits_gend:forall n ww (w_op: znz_op ww), ";
  pp "    znz_digits (nmake_op _ w_op n) = ";
  pp "    GenBase.gen_digits (znz_digits w_op) n.";
  pp " Proof.";
  pp " intros n; elim n; auto; clear n.";
  pp " intros n Hrec ww ww_op; simpl GenBase.gen_digits.";
  pp " rewrite <- Hrec; auto.";
  pp " Qed.";
  pp "";
  pp " Theorem nmake_gen: forall n ww (w_op: znz_op ww), ";
  pp "    znz_to_Z (nmake_op _ w_op n) =";
  pp "    @GenBase.gen_to_Z _ (znz_digits w_op) (znz_to_Z w_op) n.";
  pp " Proof.";
  pp " intros n; elim n; auto; clear n.";
  pp " intros n Hrec ww ww_op; simpl GenBase.gen_to_Z; unfold zn2z_to_Z.";
  pp " rewrite <- Hrec; auto.";
  pp " unfold GenBase.gen_wB; rewrite <- digits_gend; auto.";
  pp " Qed.";
  pp "";


  pp " Theorem digits_nmake:forall n ww (w_op: znz_op ww), ";
  pp "    znz_digits (nmake_op _ w_op (S n)) = ";
  pp "    xO (znz_digits (nmake_op _ w_op n)).";
  pp " Proof.";
  pp " auto.";
  pp " Qed.";
  pp "";


  pp " Theorem znz_nmake_op: forall ww ww_op n xh xl,";
  pp "  znz_to_Z (nmake_op ww ww_op (S n)) (WW xh xl) =";
  pp "   znz_to_Z (nmake_op ww ww_op n) xh *";
  pp "    base (znz_digits (nmake_op ww ww_op n)) +";
  pp "   znz_to_Z (nmake_op ww ww_op n) xl.";
  pp " Proof.";
  pp " auto.";
  pp " Qed.";
  pp "";

  pp " Theorem make_op_S: forall n,";
  pp "   make_op (S n) = mk_zn2z_op_karatsuba (make_op n).";
  pp " intro n.";
  pp " do 2 rewrite make_op_omake.";
  pp " pattern n; apply lt_wf_ind; clear n.";
  pp " intros n; case n; clear n.";
  pp "   intros _; unfold omake_op, make_op_aux, w%i_op; apply refl_equal." (size + 2);
  pp " intros n; case n; clear n.";
  pp "   intros _; unfold omake_op, make_op_aux, w%i_op; apply refl_equal." (size + 3);
  pp " intros n; case n; clear n.";
  pp "   intros _; unfold omake_op, make_op_aux, w%i_op, w%i_op; apply refl_equal." (size + 3) (size + 2);
  pp " intros n Hrec.";
  pp "   change (omake_op (S (S (S (S n))))) with";
  pp "          (mk_zn2z_op_karatsuba (mk_zn2z_op_karatsuba (mk_zn2z_op_karatsuba (omake_op (S n))))).";
  pp "   change (omake_op (S (S (S n)))) with";
  pp "         (mk_zn2z_op_karatsuba (mk_zn2z_op_karatsuba (mk_zn2z_op_karatsuba (omake_op n)))).";
  pp "   rewrite Hrec; auto with arith.";
  pp " Qed.";
  pp " ";


  for i = 1 to size + 2 do
    pp " Let znz_to_Z_%i: forall x y," i;
    pp "   znz_to_Z w%i_op (WW x y) = " i;
    pp "    znz_to_Z w%i_op x * base (znz_digits w%i_op) + znz_to_Z w%i_op y." (i-1) (i-1) (i-1);
    pp " Proof.";
    pp " auto.";
    pp " Qed. ";
    pp "";
  done;

  pp " Let znz_to_Z_n: forall n x y,";
  pp "   znz_to_Z (make_op (S n)) (WW x y) = ";
  pp "    znz_to_Z (make_op n) x * base (znz_digits (make_op n)) + znz_to_Z (make_op n) y.";
  pp " Proof.";
  pp " intros n x y; rewrite make_op_S; auto.";
  pp " Qed. ";
  pp "";

  pp " Let w0_spec: znz_spec w0_op := W0.w_spec.";
  for i = 1 to 3 do
    pp " Let w%i_spec: znz_spec w%i_op := mk_znz2_spec w%i_spec." i i (i-1) 
  done;
  for i = 4 to size + 3 do
    pp " Let w%i_spec : znz_spec w%i_op := mk_znz2_karatsuba_spec w%i_spec." i i (i-1)
  done;
  pp "";

  pp " Let wn_spec: forall n, znz_spec (make_op n).";
  pp "  intros n; elim n; clear n.";
  pp "    exact w%i_spec." (size + 1);
  pp "  intros n Hrec; rewrite make_op_S.";
  pp "  exact (mk_znz2_karatsuba_spec Hrec).";
  pp " Qed.";
  pp "";

  for i = 0 to size do
    pr " Definition w%i_eq0 := w%i_op.(znz_eq0)." i i;
    pr " Let spec_w%i_eq0: forall x, if w%i_eq0 x then [%s%i x] = 0 else True." i i c i;
    pa " Admitted.";
    pp " Proof.";
    pp " intros x; unfold w%i_eq0, to_Z; generalize (spec_eq0 w%i_spec x);" i i;
    pp "    case znz_eq0; auto.";
    pp " Qed.";
    pr "";
  done;
  pr "";


  for i = 0 to size do
    pp " Theorem digits_w%i:  znz_digits w%i_op = znz_digits (nmake_op _ w0_op %i)." i i i; 
    if i == 0 then
      pp " auto."
    else
      pp " rewrite digits_nmake; rewrite <- digits_w%i; auto." (i - 1);
    pp " Qed.";
    pp "";
    pp " Let spec_gen_eval%in: forall n, eval%in n = GenBase.gen_to_Z (znz_digits w%i_op) (znz_to_Z w%i_op) n." i i i i; 
    pp " Proof.";
    pp "  intros n; exact (nmake_gen n w%i w%i_op)." i i;
    pp " Qed.";
    pp "";
  done;

  for i = 0 to size do
    for j = 0 to (size - i) do
      pp " Theorem digits_w%in%i: znz_digits w%i_op = znz_digits (nmake_op _ w%i_op %i)." i j (i + j) i j; 
      pp " Proof.";
      if j == 0 then
        if i == 0 then
          pp " auto."
        else
          begin
            pp " apply trans_equal with (xO (znz_digits w%i_op))." (i + j -1);
            pp "  auto.";
            pp "  unfold nmake_op; auto.";
          end
      else
        begin
          pp " apply trans_equal with (xO (znz_digits w%i_op))." (i + j -1);
          pp "  auto.";
          pp " rewrite digits_nmake.";
          pp " rewrite digits_w%in%i." i (j - 1);
          pp " auto.";
        end;
      pp " Qed.";
      pp "";
      pp " Let spec_eval%in%i: forall x, [%s%i x] = eval%in %i x." i j c (i + j) i j; 
      pp " Proof.";
      if j == 0 then
        pp " intros x; rewrite spec_gen_eval%in; unfold GenBase.gen_to_Z, to_Z; auto." i
      else
        begin
          pp " intros x; case x.";
          pp "   auto.";
          pp " intros xh xl; unfold to_Z; rewrite znz_to_Z_%i." (i + j);
          pp " rewrite digits_w%in%i." i (j - 1);
          pp " generalize (spec_eval%in%i); unfold to_Z; intros HH; repeat rewrite HH." i (j - 1);
          pp " unfold eval%in, nmake_op%i." i i;
          pp " rewrite (znz_nmake_op _ w%i_op %i); auto." i (j - 1);
        end;
      pp " Qed.";
      if i + j <> size  then
        begin
          pp " Let spec_extend%in%i: forall x, [%s%i x] = [%s%i (extend%i %i x)]." i (i + j + 1) c i c (i + j + 1) i j; 
          if j == 0 then
            begin
              pp " intros x; change (extend%i 0 x) with (WW (znz_0 w%i_op) x)." i (i + j);
              pp " unfold to_Z; rewrite znz_to_Z_%i." (i + j + 1);
              pp " rewrite (spec_0 w%i_spec); auto." (i + j);
            end
          else
            begin
              pp " intros x; change (extend%i %i x) with (WW (znz_0 w%i_op) (extend%i %i x))." i j (i + j) i (j - 1);
              pp " unfold to_Z; rewrite znz_to_Z_%i." (i + j + 1);
              pp " rewrite (spec_0 w%i_spec)." (i + j);
              pp " generalize (spec_extend%in%i x); unfold to_Z." i (i + j);
              pp " intros HH; rewrite <- HH; auto.";
            end;
          pp " Qed.";
          pp "";
        end;
    done;

    pp " Theorem digits_w%in%i: znz_digits w%i_op = znz_digits (nmake_op _ w%i_op %i)." i (size - i + 1) (size + 1) i (size - i + 1);
    pp " Proof.";
    pp " apply trans_equal with (xO (znz_digits w%i_op))." size;
    pp "  auto.";
    pp " rewrite digits_nmake.";
    pp " rewrite digits_w%in%i." i (size - i);
    pp " auto.";
    pp " Qed.";
    pp "";

    pp " Let spec_eval%in%i: forall x, [%sn 0  x] = eval%in %i x." i (size - i + 1) c i (size - i + 1); 
    pp " Proof.";
    pp " intros x; case x.";
    pp "   auto.";
    pp " intros xh xl; unfold to_Z; rewrite znz_to_Z_%i." (size + 1);
    pp " rewrite digits_w%in%i." i (size - i);
    pp " generalize (spec_eval%in%i); unfold to_Z; intros HH; repeat rewrite HH." i (size - i);
    pp " unfold eval%in, nmake_op%i." i i;
    pp " rewrite (znz_nmake_op _ w%i_op %i); auto." i (size - i);
    pp " Qed.";
    pp "";

    pp " Let spec_eval%in%i: forall x, [%sn 1  x] = eval%in %i x." i (size - i + 2) c i (size - i + 2); 
    pp " intros x; case x.";
    pp "   auto.";
    pp " intros xh xl; unfold to_Z; rewrite znz_to_Z_%i." (size + 2);
    pp " rewrite digits_w%in%i." i (size + 1 - i);
    pp " generalize (spec_eval%in%i); unfold to_Z; change (make_op 0) with (w%i_op); intros HH; repeat rewrite HH." i (size + 1 - i) (size + 1);
    pp " unfold eval%in, nmake_op%i." i i;
    pp " rewrite (znz_nmake_op _ w%i_op %i); auto." i (size + 1 - i);
    pp " Qed.";
    pp "";
  done;

  pp " Let digits_w%in: forall n," size;
  pp "   znz_digits (make_op n) = znz_digits (nmake_op _ w%i_op (S n))." size;
  pp " intros n; elim n; clear n.";
  pp "  change (znz_digits (make_op 0)) with (xO (znz_digits w%i_op))." size;
  pp "  rewrite nmake_op_S; apply sym_equal; auto.";
  pp "  intros  n Hrec.";
  pp "  replace (znz_digits (make_op (S n))) with (xO (znz_digits (make_op n))).";
  pp "  rewrite Hrec.";
  pp "  rewrite nmake_op_S; apply sym_equal; auto.";
  pp "  rewrite make_op_S; apply sym_equal; auto.";
  pp " Qed.";
  pp "";

  pp " Let spec_eval%in: forall n x, [%sn n x] = eval%in (S n) x." size c size; 
  pp " intros n; elim n; clear n.";
  pp "   exact spec_eval%in1." size;
  pp " intros n Hrec x; case x; clear x.";
  pp "  unfold to_Z, eval%in, nmake_op%i." size size;
  pp "    rewrite make_op_S; rewrite nmake_op_S; auto.";
  pp " intros xh xl.";
  pp "  unfold to_Z in Hrec |- *.";
  pp "  rewrite znz_to_Z_n.";
  pp "  rewrite digits_w%in." size;
  pp "  repeat rewrite Hrec.";
  pp "  unfold eval%in, nmake_op%i." size size;
  pp "  apply sym_equal; rewrite nmake_op_S; auto.";
  pp " Qed.";
  pp "";

  pp " Let spec_extend%in: forall n x, [%s%i x] = [%sn n (extend%i n x)]." size c size c size ; 
  pp " intros n; elim n; clear n.";
  pp "   intros x; change (extend%i 0 x) with (WW (znz_0 w%i_op) x)." size size;
  pp "   unfold to_Z.";
  pp "   change (make_op 0) with w%i_op." (size + 1);
  pp "   rewrite znz_to_Z_%i; rewrite (spec_0 w%i_spec); auto." (size + 1) size;
  pp " intros n Hrec x.";
  pp "   change (extend%i (S n) x) with (WW W0 (extend%i n x))." size size;
  pp "   unfold to_Z in Hrec |- *; rewrite znz_to_Z_n; auto.";
  pp "   rewrite <- Hrec.";
  pp "  replace (znz_to_Z (make_op n) W0) with 0; auto.";
  pp "  case n; auto; intros; rewrite make_op_S; auto.";
  pp " Qed.";
  pp "";

  pr " Theorem spec_pos: forall x, 0 <= [x].";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x; case x; clear x.";
  for i = 0 to size do
    pp " intros x; case (spec_to_Z w%i_spec x); auto." i;
  done;
  pp " intros n x; case (spec_to_Z (wn_spec n) x); auto.";
  pp " Qed.";
  pr "";

  pp " Let spec_extendn_0: forall n wx, [%sn n (extend n _ wx)] = [%sn 0 wx]." c c;
  pp " intros n; elim n; auto.";
  pp " intros n1 Hrec wx; simpl extend; rewrite <- Hrec; auto.";
  pp " unfold to_Z.";
  pp " case n1; auto; intros n2; repeat rewrite make_op_S; auto.";
  pp " Qed.";
  pp " Hint Rewrite spec_extendn_0: extr.";
  pp "";
  pp " Let spec_extendn0_0: forall n wx, [%sn (S n) (WW W0 wx)] = [%sn n wx]." c c;
  pp " Proof.";
  pp " intros n x; unfold to_Z.";
  pp " rewrite znz_to_Z_n.";
  pp " rewrite <- (Zplus_0_l (znz_to_Z (make_op n) x)).";
  pp " apply (f_equal2 Zplus); auto.";
  pp " case n; auto.";
  pp " intros n1; rewrite make_op_S; auto.";
  pp " Qed.";
  pp " Hint Rewrite spec_extendn_0: extr.";
  pp "";
  pp " Let spec_extend_tr: forall m n (w: word _ (S n)),";
  pp " [%sn (m + n) (extend_tr w m)] = [%sn n w]." c c;
  pp " Proof.";
  pp " induction m; auto.";
  pp " intros n x; simpl extend_tr.";
  pp " simpl plus; rewrite spec_extendn0_0; auto.";
  pp " Qed.";
  pp " Hint Rewrite spec_extend_tr: extr.";
  pp "";
  pp " Let spec_cast_l: forall n m x1,";
  pp " [%sn (Max.max n m)" c;
  pp " (castm (diff_r n m) (extend_tr x1 (snd (diff n m))))] =";
  pp " [%sn n x1]." c;
  pp " Proof.";
  pp " intros n m x1; case (diff_r n m); simpl castm.";
  pp " rewrite spec_extend_tr; auto.";
  pp " Qed.";
  pp " Hint Rewrite spec_cast_l: extr.";
  pp "";
  pp " Let spec_cast_r: forall n m x1,";
  pp " [%sn (Max.max n m)" c;
  pp "  (castm (diff_l n m) (extend_tr x1 (fst (diff n m))))] =";
  pp " [%sn m x1]." c;
  pp " Proof.";
  pp " intros n m x1; case (diff_l n m); simpl castm.";
  pp " rewrite spec_extend_tr; auto.";
  pp " Qed.";
  pp " Hint Rewrite spec_cast_r: extr.";
  pp "";


  pr " Section LevelAndIter.";
  pr "";
  pr "  Variable res: Set.";
  pr "  Variable xxx: res.";
  pr "  Variable P: Z -> Z -> res -> Prop.";
  pr "  (* Abstraction function for each level *)";
  for i = 0 to size do
    pr "  Variable f%i: w%i -> w%i -> res." i i i;
    pr "  Variable f%in: forall n, w%i -> word w%i (S n) -> res." i i i;
    pr "  Variable fn%i: forall n, word w%i (S n) -> w%i -> res." i i i;
    pp "  Variable Pf%i: forall x y, P [%s%i x] [%s%i y] (f%i x y)." i c i c i i;
    if i == size then
      begin
        pp "  Variable Pf%in: forall n x y, P [%s%i x] (eval%in (S n) y) (f%in n x y)." i c i i i;
        pp "  Variable Pfn%i: forall n x y, P (eval%in (S n) x) [%s%i y] (fn%i n x y)." i i c i i;
      end
    else
      begin
        pp "  Variable Pf%in: forall n x y, Z_of_nat n <= %i -> P [%s%i x] (eval%in (S n) y) (f%in n x y)." i (size - i) c i i i;
        pp "  Variable Pfn%i: forall n x y, Z_of_nat n <= %i -> P (eval%in (S n) x) [%s%i y] (fn%i n x y)." i (size - i) i c i i;
      end;
    pr "";
  done;
  pr "  Variable fnn: forall n, word w%i (S n) -> word w%i (S n) -> res." size size;
  pp "  Variable Pfnn: forall n x y, P [%sn n x] [%sn n y] (fnn n x y)." c c;
  pr "  Variable fnm: forall n m, word w%i (S n) -> word w%i (S m) -> res." size size;
  pp "  Variable Pfnm: forall n m x y, P [%sn n x] [%sn m y] (fnm n m x y)." c c;
  pr "";
  pr "  (* Special zero functions *)";
  pr "  Variable f0t:  t_ -> res.";
  pp "  Variable Pf0t: forall x, P 0 [x] (f0t x).";
  pr "  Variable ft0:  t_ -> res.";
  pp "  Variable Pft0: forall x, P [x] 0 (ft0 x).";
  pr "";


  pr "  (* We level the two arguments before applying *)";
  pr "  (* the functions at each leval                *)";
  pr "  Definition same_level (x y: t_): res :=";
  pr0 "    Eval lazy zeta beta iota delta [";
  for i = 0 to size do
    pr0 "extend%i " i;
  done;
  pr "";
  pr "                                         GenBase.extend GenBase.extend_aux";
  pr "                                         ] in";
  pr "  match x, y with";
  for i = 0 to size do
    for j = 0 to i - 1 do
      pr "  | %s%i wx, %s%i wy => f%i wx (extend%i %i wy)" c i c j i j (i - j -1);
    done;
    pr "  | %s%i wx, %s%i wy => f%i wx wy" c i c i i;
    for j = i + 1 to size do
      pr "  | %s%i wx, %s%i wy => f%i (extend%i %i wx) wy" c i c j j i (j - i - 1);
    done;
    if i == size then
      pr "  | %s%i wx, %sn m wy => fnn m (extend%i m wx) wy" c size c size 
    else 
      pr "  | %s%i wx, %sn m wy => fnn m (extend%i m (extend%i %i wx)) wy" c i c size i (size - i - 1);
  done;
  for i = 0 to size do
    if i == size then
      pr "  | %sn n wx, %s%i wy => fnn n wx (extend%i n wy)" c c size size 
    else 
      pr "  | %sn n wx, %s%i wy => fnn n wx (extend%i n (extend%i %i wy))" c c i size i (size - i - 1);
  done;
  pr "  | %sn n wx, Nn m wy =>" c;
  pr "    let mn := Max.max n m in";
  pr "    let d := diff n m in";
  pr "     fnn mn";
  pr "       (castm (diff_r n m) (extend_tr wx (snd d)))";
  pr "       (castm (diff_l n m) (extend_tr wy (fst d)))";
  pr "  end.";
  pr "";

  pp "  Lemma spec_same_level: forall x y, P [x] [y] (same_level x y).";
  pp "  Proof.";
  pp "  intros x; case x; clear x; unfold same_level.";
  for i = 0 to size do
    pp "    intros x y; case y; clear y.";
    for j = 0 to i - 1 do
      pp "     intros y; rewrite spec_extend%in%i; apply Pf%i." j i i;
    done;
    pp "     intros y; apply Pf%i." i;
    for j = i + 1 to size do
      pp "     intros y; rewrite spec_extend%in%i; apply Pf%i." i j j;
    done;
    if i == size then
      pp "     intros m y; rewrite (spec_extend%in m); apply Pfnn." size
    else 
      pp "     intros m y; rewrite spec_extend%in%i; rewrite (spec_extend%in m); apply Pfnn." i size size;
  done;
  pp "    intros n x y; case y; clear y.";
  for i = 0 to size do
    if i == size then
      pp "    intros y; rewrite (spec_extend%in n); apply Pfnn." size
    else 
      pp "    intros y; rewrite spec_extend%in%i; rewrite (spec_extend%in n); apply Pfnn." i size size;
  done;
  pp "    intros m y; rewrite <- (spec_cast_l n m x); ";
  pp "          rewrite <- (spec_cast_r n m y); apply Pfnn.";
  pp "  Qed.";
  pp "";

  pr "  (* We level the two arguments before applying      *)";
  pr "  (* the functions at each level (special zero case) *)";
  pr "  Definition same_level0 (x y: t_): res :=";
  pr0 "    Eval lazy zeta beta iota delta [";
  for i = 0 to size do
    pr0 "extend%i " i;
  done;
  pr "";
  pr "                                         GenBase.extend GenBase.extend_aux";
  pr "                                         ] in";
  pr "  match x with";
  for i = 0 to size do
    pr "  | %s%i wx =>" c i;
    if i == 0 then
      pr "    if w0_eq0 wx then f0t y else";
    pr "    match y with";
    for j = 0 to i - 1 do
      pr "    | %s%i wy =>" c j;
      if j == 0 then 
        pr "       if w0_eq0 wy then ft0 x else";
      pr "       f%i wx (extend%i %i wy)" i j (i - j -1);
    done;
    pr "    | %s%i wy => f%i wx wy" c i i;
    for j = i + 1 to size do
      pr "    | %s%i wy => f%i (extend%i %i wx) wy" c j j i (j - i - 1);
    done;
    if i == size then
      pr "    | %sn m wy => fnn m (extend%i m wx) wy" c size 
    else 
      pr "    | %sn m wy => fnn m (extend%i m (extend%i %i wx)) wy" c size i (size - i - 1);
    pr"    end";
  done;
  pr "  |  %sn n wx =>" c;
  pr "     match y with";
  for i = 0 to size do
    pr "     | %s%i wy =>" c i;
    if i == 0 then
      pr "      if w0_eq0 wy then ft0 x else";
    if i == size then
      pr "      fnn n wx (extend%i n wy)" size 
    else 
      pr "      fnn n wx (extend%i n (extend%i %i wy))" size i (size - i - 1);
  done;
  pr "        | %sn m wy =>" c;
  pr "            let mn := Max.max n m in";
  pr "            let d := diff n m in";
  pr "              fnn mn";
  pr "              (castm (diff_r n m) (extend_tr wx (snd d)))";
  pr "              (castm (diff_l n m) (extend_tr wy (fst d)))";
  pr "    end";
  pr "  end.";
  pr "";

  pp "  Lemma spec_same_level0: forall x y, P [x] [y] (same_level0 x y).";
  pp "  Proof.";
  pp "  intros x; case x; clear x; unfold same_level0.";
  for i = 0 to size do
    pp "    intros x.";
    if i == 0 then
      begin
        pp "    generalize (spec_w0_eq0 x); case w0_eq0; intros H.";
        pp "      intros y; rewrite H; apply Pf0t.";
        pp "    clear H.";
      end;
    pp "    intros y; case y; clear y.";
    for j = 0 to i - 1 do
      pp "     intros y.";
      if j == 0 then
        begin
          pp "     generalize (spec_w0_eq0 y); case w0_eq0; intros H.";
          pp "       rewrite H; apply Pft0.";
          pp "     clear H.";
        end;
      pp "     rewrite spec_extend%in%i; apply Pf%i." j i i;
    done;
    pp "     intros y; apply Pf%i." i;
    for j = i + 1 to size do
      pp "     intros y; rewrite spec_extend%in%i; apply Pf%i." i j j;
    done;
    if i == size then
      pp "     intros m y; rewrite (spec_extend%in m); apply Pfnn." size
    else 
      pp "     intros m y; rewrite spec_extend%in%i; rewrite (spec_extend%in m); apply Pfnn." i size size;
  done;
  pp "    intros n x y; case y; clear y.";
  for i = 0 to size do
    pp "    intros y.";
    if i = 0 then
      begin
        pp "     generalize (spec_w0_eq0 y); case w0_eq0; intros H.";
        pp "       rewrite H; apply Pft0.";
        pp "     clear H.";
      end;
    if i == size then
      pp "    rewrite (spec_extend%in n); apply Pfnn." size
    else 
      pp "    rewrite spec_extend%in%i; rewrite (spec_extend%in n); apply Pfnn." i size size;
  done;
  pp "  intros m y; rewrite <- (spec_cast_l n m x); ";
  pp "          rewrite <- (spec_cast_r n m y); apply Pfnn.";
  pp "  Qed.";
  pp "";

  pr "  (* We iter the smaller argument with the bigger  *)";
  pr "  Definition iter (x y: t_): res := ";
  pr0 "    Eval lazy zeta beta iota delta [";
  for i = 0 to size do
    pr0 "extend%i " i;
  done;
  pr "";
  pr "                                         GenBase.extend GenBase.extend_aux";
  pr "                                         ] in";
  pr "  match x, y with";
  for i = 0 to size do
    for j = 0 to i - 1 do
      pr "  | %s%i wx, %s%i wy => fn%i %i wx wy" c i c j j (i - j - 1);
    done;
    pr "  | %s%i wx, %s%i wy => f%i wx wy" c i c i i;
    for j = i + 1 to size do
      pr "  | %s%i wx, %s%i wy => f%in %i wx wy" c i c j i (j - i - 1);
    done;
    if i == size then
      pr "  | %s%i wx, %sn m wy => f%in m wx wy" c size c size 
    else 
      pr "  | %s%i wx, %sn m wy => f%in m (extend%i %i wx) wy" c i c size i (size - i - 1);
  done;
  for i = 0 to size do
    if i == size then
      pr "  | %sn n wx, %s%i wy => fn%i n wx wy" c c size size 
    else 
      pr "  | %sn n wx, %s%i wy => fn%i n wx (extend%i %i wy)" c c i size i (size - i - 1);
  done;
  pr "  | %sn n wx, %sn m wy => fnm n m wx wy" c c;
  pr "  end.";
  pr "";

  pp "  Ltac zg_tac := try";
  pp "    (red; simpl Zcompare; auto;";
  pp "     let t := fresh \"H\" in (intros t; discriminate H)).";
  pp "  Lemma spec_iter: forall x y, P [x] [y] (iter x y).";
  pp "  Proof.";
  pp "  intros x; case x; clear x; unfold iter.";
  for i = 0 to size do
    pp "    intros x y; case y; clear y.";
    for j = 0 to i - 1 do
      pp "     intros y; rewrite spec_eval%in%i;  apply (Pfn%i %i); zg_tac." j (i - j) j (i - j - 1);
    done;
    pp "     intros y; apply Pf%i." i;
    for j = i + 1 to size do
      pp "     intros y; rewrite spec_eval%in%i; apply (Pf%in %i); zg_tac." i (j - i) i (j - i - 1);
    done;
    if i == size then
      pp "     intros m y; rewrite spec_eval%in; apply Pf%in." size size
    else 
      pp "     intros m y; rewrite spec_extend%in%i; rewrite spec_eval%in; apply Pf%in." i size size size;
  done;
  pp "    intros n x y; case y; clear y.";
  for i = 0 to size do
    if i == size then
      pp "     intros y; rewrite spec_eval%in; apply Pfn%i." size size
    else 
      pp "      intros y; rewrite spec_extend%in%i; rewrite spec_eval%in; apply Pfn%i." i size size size;
  done;
  pp "  intros m y; apply Pfnm.";
  pp "  Qed.";
  pp "";


  pr "  (* We iter the smaller argument with the bigger  (zero case) *)";
  pr "  Definition iter0 (x y: t_): res :=";
  pr0 "    Eval lazy zeta beta iota delta [";
  for i = 0 to size do
    pr0 "extend%i " i;
  done;
  pr "";
  pr "                                         GenBase.extend GenBase.extend_aux";
  pr "                                         ] in";
  pr "  match x with";
  for i = 0 to size do
    pr "  | %s%i wx =>" c i;
    if i == 0 then
      pr "    if w0_eq0 wx then f0t y else";
    pr "    match y with";
    for j = 0 to i - 1 do
      pr "    | %s%i wy =>" c j;
      if j == 0 then
        pr "       if w0_eq0 wy then ft0 x else";
      pr "       fn%i %i wx wy" j (i - j - 1);
    done;
    pr "    | %s%i wy => f%i wx wy" c i i;
    for j = i + 1 to size do
      pr "    | %s%i wy => f%in %i wx wy" c j i (j - i - 1);
    done;
    if i == size then
      pr "    | %sn m wy => f%in m wx wy" c size 
    else 
      pr "    | %sn m wy => f%in m (extend%i %i wx) wy" c size i (size - i - 1);
    pr "    end";
  done;
  pr "  | %sn n wx =>" c;
  pr "    match y with";
  for i = 0 to size do
    pr "    | %s%i wy =>" c i;
    if i == 0 then
      pr "      if w0_eq0 wy then ft0 x else";
    if i == size then
      pr "      fn%i n wx wy" size 
    else 
      pr "      fn%i n wx (extend%i %i wy)" size i (size - i - 1);
  done;
  pr "    | %sn m wy => fnm n m wx wy" c;
  pr "    end";
  pr "  end.";
  pr "";

  pp "  Lemma spec_iter0: forall x y, P [x] [y] (iter0 x y).";
  pp "  Proof.";
  pp "  intros x; case x; clear x; unfold iter0.";
  for i = 0 to size do
    pp "    intros x.";
    if i == 0 then
      begin
        pp "    generalize (spec_w0_eq0 x); case w0_eq0; intros H.";
        pp "      intros y; rewrite H; apply Pf0t.";
        pp "    clear H.";
      end;
    pp "    intros y; case y; clear y.";
    for j = 0 to i - 1 do
      pp "     intros y.";
      if j == 0 then
        begin
          pp "     generalize (spec_w0_eq0 y); case w0_eq0; intros H.";
          pp "       rewrite H; apply Pft0.";
          pp "     clear H.";
        end;
      pp "     rewrite spec_eval%in%i;  apply (Pfn%i %i); zg_tac." j (i - j) j (i - j - 1);
    done;
    pp "     intros y; apply Pf%i." i;
    for j = i + 1 to size do
      pp "     intros y; rewrite spec_eval%in%i; apply (Pf%in %i); zg_tac." i (j - i) i (j - i - 1);
    done;
    if i == size then
      pp "     intros m y; rewrite spec_eval%in; apply Pf%in." size size
    else 
      pp "     intros m y; rewrite spec_extend%in%i; rewrite spec_eval%in; apply Pf%in." i size size size;
  done;
  pp "    intros n x y; case y; clear y.";
  for i = 0 to size do
    pp "    intros y.";
    if i = 0 then
      begin
        pp "     generalize (spec_w0_eq0 y); case w0_eq0; intros H.";
        pp "       rewrite H; apply Pft0.";
        pp "     clear H.";
      end;
    if i == size then
      pp "     rewrite spec_eval%in; apply Pfn%i." size size
    else 
      pp "      rewrite spec_extend%in%i; rewrite spec_eval%in; apply Pfn%i." i size size size;
  done;
  pp "  intros m y; apply Pfnm.";
  pp "  Qed.";
  pp "";


  pr "  End LevelAndIter.";
  pr "";


  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Reduction                         *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr "";

  pr " Definition reduce_0 (x:w) := %s0 x." c; 
  pr " Definition reduce_1 :=";
  pr "  Eval lazy beta iota delta[reduce_n1] in";
  pr "   reduce_n1 _ _ zero w0_eq0 %s0 %s1." c c;
  for i = 2 to size do
    pr " Definition reduce_%i :=" i;
    pr "  Eval lazy beta iota delta[reduce_n1] in";
    pr "   reduce_n1 _ _ zero w%i_eq0 reduce_%i %s%i." 
      (i-1) (i-1)  c i
  done;
  pr " Definition reduce_%i :=" (size+1);
  pr "  Eval lazy beta iota delta[reduce_n1] in";
  pr "   reduce_n1 _ _ zero w%i_eq0 reduce_%i (%sn 0)." 
    size size c; 

  pr " Definition reduce_n n := ";
  pr "  Eval lazy beta iota delta[reduce_n] in";
  pr "   reduce_n _ _ zero reduce_%i %sn n." (size + 1) c;
  pr "";

  pp " Let spec_reduce_0: forall x, [reduce_0 x] = [%s0 x]." c;
  pp " Proof.";
  pp " intros x; unfold to_Z, reduce_0.";
  pp " auto.";
  pp " Qed.";
  pp " ";

  for i = 1 to size + 1 do
    if i == size + 1 then
      pp " Let spec_reduce_%i: forall x, [reduce_%i x] = [%sn 0 x]." i i c
    else
      pp " Let spec_reduce_%i: forall x, [reduce_%i x] = [%s%i x]." i i c i;
    pp " Proof.";
    pp " intros x; case x; unfold reduce_%i." i;
    pp " exact (spec_0 w0_spec).";
    pp " intros x1 y1.";
    pp " generalize (spec_w%i_eq0 x1); " (i - 1);
    pp "   case w%i_eq0; intros H1; auto." (i - 1);
    if i <> 1 then 
      pp " rewrite spec_reduce_%i." (i - 1);
    pp " unfold to_Z; rewrite znz_to_Z_%i." i;
    pp " unfold to_Z in H1; rewrite H1; auto.";
    pp " Qed.";
    pp " ";
  done;

  pp " Let spec_reduce_n: forall n x, [reduce_n n x] = [%sn n x]." c;
  pp " Proof.";
  pp " intros n; elim n; simpl reduce_n.";
  pp "   intros x; rewrite <- spec_reduce_%i; auto." (size + 1);
  pp " intros n1 Hrec x; case x.";
  pp " unfold to_Z; rewrite make_op_S; auto.";
  pp " exact (spec_0 w0_spec).";
  pp " intros x1 y1; case x1; auto.";
  pp " rewrite Hrec.";
  pp " rewrite spec_extendn0_0; auto.";
  pp " Qed.";
  pp " ";

  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Successor                         *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr "";

  for i = 0 to size do
    pr " Definition w%i_succ_c := w%i_op.(znz_succ_c)." i i
  done;
  pr "";

  for i = 0 to size do
    pr " Definition w%i_succ := w%i_op.(znz_succ)." i i
  done;
  pr "";

  pr " Definition succ x :=";
  pr "  match x with";
  for i = 0 to size-1 do
    pr "  | %s%i wx =>" c i;
    pr "    match w%i_succ_c wx with" i;
    pr "    | C0 r => %s%i r" c i; 
    pr "    | C1 r => %s%i (WW one%i r)" c (i+1) i;
    pr "    end";
  done;
  pr "  | %s%i wx =>" c size;
  pr "    match w%i_succ_c wx with" size;
  pr "    | C0 r => %s%i r" c size; 
  pr "    | C1 r => %sn 0 (WW one%i r)" c size ;
  pr "    end";
  pr "  | %sn n wx =>" c;
  pr "    let op := make_op n in";
  pr "    match op.(znz_succ_c) wx with";
  pr "    | C0 r => %sn n r" c; 
  pr "    | C1 r => %sn (S n) (WW op.(znz_1) r)" c;
  pr "    end";
  pr "  end.";
  pr "";

  pr " Theorem spec_succ: forall n, [succ n] = [n] + 1.";
  pa " Admitted.";
  pp " Proof.";
  pp "  intros n; case n; unfold succ, to_Z.";
  for i = 0 to size do
    pp  "  intros n1; generalize (spec_succ_c w%i_spec n1);" i;
    pp  "  unfold succ, to_Z, w%i_succ_c; case znz_succ_c; auto." i;
    pp  "     intros ww H; rewrite <- H.";
    pp "     (rewrite znz_to_Z_%i; unfold interp_carry;" (i + 1);
    pp "           apply f_equal2 with (f := Zplus); auto;";
    pp "           apply f_equal2 with (f := Zmult); auto;";
    pp "           exact (spec_1 w%i_spec))." i;
  done;
  pp "  intros k n1; generalize (spec_succ_c (wn_spec k) n1).";
  pp "  unfold succ, to_Z; case znz_succ_c; auto.";
  pp "  intros ww H; rewrite <- H.";
  pp "     (rewrite (znz_to_Z_n k); unfold interp_carry;";
  pp "           apply f_equal2 with (f := Zplus); auto;";
  pp "           apply f_equal2 with (f := Zmult); auto;";
  pp "           exact (spec_1 (wn_spec k))).";
  pp " Qed.";
  pr "";


  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Adddition                         *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr "";

  for i = 0 to size do
    pr " Definition w%i_add_c := znz_add_c w%i_op." i i; 
    pr " Definition w%i_add x y :=" i;
    pr "  match w%i_add_c x y with" i;
    pr "  | C0 r => %s%i r" c i;
    if i == size then
      pr "  | C1 r => %sn 0 (WW one%i r)" c size
    else
      pr "  | C1 r => %s%i (WW one%i r)" c (i + 1) i;
    pr "  end.";
    pr "";
  done ;
  pr " Definition addn n (x y : word w%i (S n)) :=" size;
  pr "  let op := make_op n in";
  pr "  match op.(znz_add_c) x y with";
  pr "  | C0 r => %sn n r" c;
  pr "  | C1 r => %sn (S n) (WW op.(znz_1) r)  end." c;
  pr "";


  for i = 0 to size do
    pp " Let spec_w%i_add: forall x y, [w%i_add x y] = [%s%i x] + [%s%i y]." i i c i c i;
    pp " Proof.";
    pp " intros n m; unfold to_Z, w%i_add, w%i_add_c." i i;
    pp "  generalize (spec_add_c w%i_spec n m); case znz_add_c; auto." i;
    pp " intros ww H; rewrite <- H."; 
    pp "    rewrite znz_to_Z_%i; unfold interp_carry;" (i + 1);
    pp "    apply f_equal2 with (f := Zplus); auto;";
    pp "    apply f_equal2 with (f := Zmult); auto;";
    pp "    exact (spec_1 w%i_spec)." i;
    pp " Qed.";
    pp " Hint Rewrite spec_w%i_add: addr." i;
    pp "";
  done;
  pp " Let spec_wn_add: forall n x y, [addn n x y] = [%sn n x] + [%sn n y]." c c;
  pp " Proof.";
  pp " intros k n m; unfold to_Z, addn.";
  pp "  generalize (spec_add_c (wn_spec k) n m); case znz_add_c; auto.";
  pp " intros ww H; rewrite <- H."; 
  pp " rewrite (znz_to_Z_n k); unfold interp_carry;";
  pp "        apply f_equal2 with (f := Zplus); auto;";
  pp "        apply f_equal2 with (f := Zmult); auto;";
  pp "        exact (spec_1 (wn_spec k)).";
  pp " Qed.";
  pp " Hint Rewrite spec_wn_add: addr.";

  pr " Definition add := Eval lazy beta delta [same_level] in";
  pr0 "   (same_level t_ ";
  for i = 0 to size do
    pr0 "w%i_add " i;
  done;
  pr "addn).";
  pr "";

  pr " Theorem spec_add: forall x y, [add x y] = [x] + [y].";
  pa " Admitted.";
  pp " Proof.";
  pp " unfold add.";
  pp " generalize (spec_same_level t_ (fun x y res => [res] = x + y)).";
  pp " unfold same_level; intros HH; apply HH; clear HH.";
  for i = 0 to size do
    pp " exact spec_w%i_add." i;
  done;
  pp " exact spec_wn_add.";
  pp " Qed.";
  pr "";

  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Predecessor                       *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr "";

  for i = 0 to size do
    pr " Definition w%i_pred_c := w%i_op.(znz_pred_c)." i i
  done;
  pr "";

  pr " Definition pred x :=";
  pr "  match x with";
  for i = 0 to size do
    pr "  | %s%i wx =>" c i;
    pr "    match w%i_pred_c wx with" i;
    pr "    | C0 r => reduce_%i r" i; 
    pr "    | C1 r => zero";
    pr "    end";
  done;
  pr "  | %sn n wx =>" c;
  pr "    let op := make_op n in";
  pr "    match op.(znz_pred_c) wx with";
  pr "    | C0 r => reduce_n n r"; 
  pr "    | C1 r => zero";
  pr "    end";
  pr "  end.";
  pr "";

  pr " Theorem spec_pred: forall x, 0 < [x] -> [pred x] = [x] - 1.";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x; case x; unfold pred.";
  for i = 0 to size do
    pp " intros x1 H1; unfold w%i_pred_c; " i;
    pp " generalize (spec_pred_c w%i_spec x1); case znz_pred_c; intros y1." i;
    pp " rewrite spec_reduce_%i; auto." i;
    pp " unfold interp_carry; unfold to_Z.";
    pp " case (spec_to_Z w%i_spec x1); intros HH1 HH2." i;
    pp " case (spec_to_Z w%i_spec y1); intros HH3 HH4 HH5." i;
    pp " assert (znz_to_Z w%i_op x1 - 1 < 0); auto with zarith." i;
    pp " unfold to_Z in H1; auto with zarith.";
  done;
  pp " intros n x1 H1;  ";
  pp "   generalize (spec_pred_c (wn_spec n) x1); case znz_pred_c; intros y1.";
  pp "   rewrite spec_reduce_n; auto.";
  pp " unfold interp_carry; unfold to_Z.";
  pp " case (spec_to_Z (wn_spec n) x1); intros HH1 HH2.";
  pp " case (spec_to_Z (wn_spec n) y1); intros HH3 HH4 HH5.";
  pp " assert (znz_to_Z (make_op n) x1 - 1 < 0); auto with zarith.";
  pp " unfold to_Z in H1; auto with zarith.";
  pp " Qed.";
  pp " ";
  
  pp " Let spec_pred0: forall x, [x] = 0 -> [pred x] = 0.";
  pp " Proof.";
  pp " intros x; case x; unfold pred.";
  for i = 0 to size do
    pp " intros x1 H1; unfold w%i_pred_c; " i;
    pp "   generalize (spec_pred_c w%i_spec x1); case znz_pred_c; intros y1." i;
    pp " unfold interp_carry; unfold to_Z.";
    pp " unfold to_Z in H1; auto with zarith.";
    pp " case (spec_to_Z w%i_spec y1); intros HH3 HH4; auto with zarith." i;
    pp " intros; exact (spec_0 w0_spec).";
  done;
  pp " intros n x1 H1; ";
  pp "   generalize (spec_pred_c (wn_spec n) x1); case znz_pred_c; intros y1.";
  pp " unfold interp_carry; unfold to_Z.";
  pp " unfold to_Z in H1; auto with zarith.";
  pp " case (spec_to_Z (wn_spec n) y1); intros HH3 HH4; auto with zarith.";
  pp " intros; exact (spec_0 w0_spec).";
  pp " Qed.";
  pr " ";


  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Subtraction                       *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr "";

  for i = 0 to size do
    pr " Definition w%i_sub_c := w%i_op.(znz_sub_c)." i i
  done;
  pr "";

  for i = 0 to size do 
    pr " Definition w%i_sub x y :=" i;
    pr "  match w%i_sub_c x y with" i;
    pr "  | C0 r => reduce_%i r" i;
    pr "  | C1 r => zero";
    pr "  end."
  done;
  pr "";

  pr " Definition subn n (x y : word w%i (S n)) :=" size;
  pr "  let op := make_op n in";
  pr "  match op.(znz_sub_c) x y with";
  pr "  | C0 r => %sn n r" c;
  pr "  | C1 r => N0 w_0";
  pr "  end.";
  pr "";

  for i = 0 to size do
    pp " Let spec_w%i_sub: forall x y, [%s%i y] <= [%s%i x] -> [w%i_sub x y] = [%s%i x] - [%s%i y]." i c i c i i c i c i;
    pp " Proof.";
    pp " intros n m; unfold w%i_sub, w%i_sub_c." i i;
    pp "  generalize (spec_sub_c w%i_spec n m); case znz_sub_c; " i;
    if i == 0 then 
      pp "    intros x; auto."
    else
      pp "   intros x; try rewrite spec_reduce_%i; auto." i;
    pp " unfold interp_carry; unfold zero, w_0, to_Z.";
    pp " rewrite (spec_0 w0_spec).";
    pp " case (spec_to_Z w%i_spec x); intros; auto with zarith." i;
    pp " Qed.";
    pp "";
  done;
  
  pp " Let spec_wn_sub: forall n x y, [%sn n y] <= [%sn n x] -> [subn n x y] = [%sn n x] - [%sn n y]." c c c c;
  pp " Proof.";
  pp " intros k n m; unfold subn.";
  pp " generalize (spec_sub_c (wn_spec k) n m); case znz_sub_c; ";
  pp "   intros x; auto.";
  pp " unfold interp_carry, to_Z.";
  pp " case (spec_to_Z (wn_spec k) x); intros; auto with zarith.";
  pp " Qed.";
  pp "";

  pr " Definition sub := Eval lazy beta delta [same_level] in";
  pr0 "   (same_level t_ ";
  for i = 0 to size do
    pr0 "w%i_sub " i;
  done;
  pr "subn).";
  pr "";

  pr " Theorem spec_sub: forall x y, [y] <= [x] -> [sub x y] = [x] - [y].";
  pa " Admitted.";
  pp " Proof.";
  pp " unfold sub.";
  pp " generalize (spec_same_level t_ (fun x y res => y <= x -> [res] = x - y)).";
  pp " unfold same_level; intros HH; apply HH; clear HH.";
  for i = 0 to size do
    pp " exact spec_w%i_sub." i;
  done;
  pp " exact spec_wn_sub.";
  pp " Qed.";
  pr "";

  for i = 0 to size do
    pp " Let spec_w%i_sub0: forall x y, [%s%i x] < [%s%i y] -> [w%i_sub x y] = 0." i c i c i i;
    pp " Proof.";
    pp " intros n m; unfold w%i_sub, w%i_sub_c." i i;
    pp "  generalize (spec_sub_c w%i_spec n m); case znz_sub_c; " i;
    pp "   intros x; unfold interp_carry.";
    pp "   unfold to_Z; case (spec_to_Z w%i_spec x); intros; auto with zarith." i;
    pp " intros; unfold to_Z, zero, w_0; rewrite (spec_0 w0_spec); auto.";
    pp " Qed.";
    pp "";
  done;

  pp " Let spec_wn_sub0: forall n x y, [%sn n x] < [%sn n y] -> [subn n x y] = 0." c c;
  pp " Proof.";
  pp " intros k n m; unfold subn.";
  pp " generalize (spec_sub_c (wn_spec k) n m); case znz_sub_c; ";
  pp "   intros x; unfold interp_carry.";
  pp "   unfold to_Z; case (spec_to_Z (wn_spec k) x); intros; auto with zarith.";
  pp " intros; unfold to_Z, w_0; rewrite (spec_0 (w0_spec)); auto.";
  pp " Qed.";
  pp "";

  pr " Theorem spec_sub0: forall x y, [x] < [y] -> [sub x y] = 0.";
  pa " Admitted.";
  pp " Proof.";
  pp " unfold sub.";
  pp " generalize (spec_same_level t_ (fun x y res => x < y -> [res] = 0)).";
  pp " unfold same_level; intros HH; apply HH; clear HH.";
  for i = 0 to size do
    pp " exact spec_w%i_sub0." i;
  done;
  pp " exact spec_wn_sub0.";
  pp " Qed.";
  pr "";


  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Comparison                        *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr "";

  for i = 0 to size do
    pr " Definition compare_%i := w%i_op.(znz_compare)." i i;
    pr " Definition comparen_%i :=" i;
    pr "  compare_mn_1 w%i w%i %s compare_%i (compare_%i %s) compare_%i." i i (pz i) i i (pz i) i
  done;
  pr ""; 

  pr " Definition comparenm n m wx wy :=";
  pr "    let mn := Max.max n m in";
  pr "    let d := diff n m in";
  pr "    let op := make_op mn in";
  pr "     op.(znz_compare)";
  pr "       (castm (diff_r n m) (extend_tr wx (snd d)))";
  pr "       (castm (diff_l n m) (extend_tr wy (fst d))).";
  pr "";

  pr " Definition compare := Eval lazy beta delta [iter] in ";
  pr "   (iter _ ";
  for i = 0 to size do
    pr "      compare_%i" i;
    pr "      (fun n x y => opp_compare (comparen_%i (S n) y x))" i;
    pr "      (fun n => comparen_%i (S n))" i;
  done;
  pr "      comparenm).";
  pr "";

  for i = 0 to size do
    pp " Let spec_compare_%i: forall x y," i;
    pp "    match compare_%i x y with " i;
    pp "      Eq => [%s%i x] = [%s%i y]" c i c i;
    pp "    | Lt => [%s%i x] < [%s%i y]" c i c i;
    pp "    | Gt => [%s%i x] > [%s%i y]" c i c i;
    pp "    end.";
    pp "  Proof.";
    pp "  unfold compare_%i, to_Z; exact (spec_compare w%i_spec)." i i;
    pp "  Qed.";
    pp "";
    
    pp "  Let spec_comparen_%i:" i;
    pp "  forall (n : nat) (x : word w%i n) (y : w%i)," i i;
    pp "  match comparen_%i n x y with" i;
    pp "  | Eq => eval%in n x = [%s%i y]" i c i;
    pp "  | Lt => eval%in n x < [%s%i y]" i c i;
    pp "  | Gt => eval%in n x > [%s%i y]" i c i;
    pp "  end.";
    pp "  intros n x y.";
    pp "  unfold comparen_%i, to_Z; rewrite spec_gen_eval%in." i i;
    pp "  apply spec_compare_mn_1.";
    pp "  exact (spec_0 w%i_spec)." i;
    pp "  intros x1; exact (spec_compare w%i_spec %s x1)." i (pz i);
    pp "  exact (spec_to_Z w%i_spec)." i;
    pp "  exact (spec_compare w%i_spec)." i;
    pp "  exact (spec_compare w%i_spec)." i;
    pp "  exact (spec_to_Z w%i_spec)." i;
    pp "  Qed.";
    pp "";
  done;

  pp " Let spec_opp_compare: forall c (u v: Z),";
  pp "  match c with Eq => u = v | Lt => u < v | Gt => u > v end ->";
  pp "  match opp_compare c with Eq => v = u | Lt => v < u | Gt => v > u end.";
  pp " Proof.";
  pp " intros c u v; case c; unfold opp_compare; auto with zarith.";
  pp " Qed.";
  pp "";


  pr " Theorem spec_compare: forall x y,";
  pr "    match compare x y with ";
  pr "      Eq => [x] = [y]";
  pr "    | Lt => [x] < [y]";
  pr "    | Gt => [x] > [y]";
  pr "    end.";
  pa " Admitted.";
  pp " Proof.";
  pp " refine (spec_iter _ (fun x y res => ";
  pp "                       match res with ";
  pp "                        Eq => x = y";
  pp "                      | Lt => x < y";
  pp "                      | Gt => x > y";
  pp "                      end)";
  for i = 0 to size do
    pp "      compare_%i" i;
    pp "      (fun n x y => opp_compare (comparen_%i (S n) y x))" i;
    pp "      (fun n => comparen_%i (S n)) _ _ _" i;
  done;
  pp "      comparenm _).";
  
  for i = 0 to size - 1 do
    pp "  exact spec_compare_%i." i;
    pp "  intros n x y H;apply spec_opp_compare; apply spec_comparen_%i." i;
    pp "  intros n x y H; exact (spec_comparen_%i (S n) x y)." i;
  done; 
  pp "  exact spec_compare_%i." size;
  pp "  intros n x y;apply spec_opp_compare; apply spec_comparen_%i." size;
  pp "  intros n; exact (spec_comparen_%i (S n))." size;
  pp "  intros n m x y; unfold comparenm.";
  pp "  rewrite <- (spec_cast_l n m x); rewrite <- (spec_cast_r n m y).";
  pp "  unfold to_Z; apply (spec_compare  (wn_spec (Max.max n m))).";
  pp "  Qed.";
  pr "";

  pr " Definition eq_bool x y :=";
  pr "  match compare x y with";
  pr "  | Eq => true";
  pr "  | _  => false";
  pr "  end.";
  pr "";


  pr " Theorem spec_eq_bool: forall x y,";
  pr "    if eq_bool x y then [x] = [y] else [x] <> [y].";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x y; unfold eq_bool.";
  pp " generalize (spec_compare x y); case compare; auto with zarith.";
  pp "  Qed.";
  pr "";



  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Multiplication                    *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr "";

  for i = 0 to size do
    pr " Definition w%i_mul_c := w%i_op.(znz_mul_c)." i i
  done;
  pr "";

  for i = 0 to size do
    pr " Definition w%i_mul_add :=" i;
    pr "   Eval lazy beta delta [w_mul_add] in";
    pr "     @w_mul_add w%i %s w%i_succ w%i_add_c w%i_mul_c." i (pz i) i i i
  done;
  pr "";

  for i = 0 to size do
    pr " Definition w%i_0W := w%i_op.(znz_0W)." i i
  done;
  pr "";

  for i = 0 to size do
    pr " Definition w%i_mul_add_n1 :=" i;
    pr "  @gen_mul_add_n1 w%i %s w%i_op.(znz_WW) w%i_0W w%i_mul_add."  i (pz i) i i i
  done;
  pr "";

  for i = 0 to size - 1 do
    pr "  Let to_Z%i n :=" i;
    pr "  match n return word w%i (S n) -> t_ with" i;
    for j = 0 to size - i do
      if (i + j) == size then
        begin 
          pr "  | %i%s => fun x => %sn 0 x" j "%nat" c;
          pr "  | %i%s => fun x => %sn 1 x" (j + 1) "%nat" c
        end
      else
        pr "  | %i%s => fun x => %s%i x" j "%nat" c (i + j + 1)
    done;
    pr   "  | _   => fun _ => N0 w_0";
    pr "  end.";
    pr "";
  done; 


  for i = 0 to size - 1 do
    pp "Theorem to_Z%i_spec:" i;
    pp "  forall n x, Z_of_nat n <= %i -> [to_Z%i n x] = znz_to_Z (nmake_op _ w%i_op (S n)) x." (size + 1 - i) i i;
    for j = 1 to size + 2 - i do
      pp " intros n; case n; clear n.";
      pp "   unfold to_Z%i." i;
      pp "   intros x H; rewrite spec_eval%in%i; auto." i j;
    done;
    pp " intros n x.";
    pp " repeat rewrite inj_S; unfold Zsucc; auto with zarith.";
    pp " Qed.";
    pp "";
  done; 


  for i = 0 to size do
    pr " Definition w%i_mul n x y :=" i;
    pr " let (w,r) := w%i_mul_add_n1 (S n) x y %s in" i (pz i);
    if i == size then
      begin
        pr " if w%i_eq0 w then %sn n r" i c;
        pr " else %sn (S n) (WW (extend%i n w) r)." c i;
      end
    else 
      begin 
        pr " if w%i_eq0 w then to_Z%i n r" i i;
        pr " else to_Z%i (S n) (WW (extend%i n w) r)." i i;
      end;
    pr "";
  done;

  pr " Definition mulnm n m x y :=";
  pr "    let mn := Max.max n m in";
  pr "    let d := diff n m in";
  pr "    let op := make_op mn in";
  pr "     reduce_n (S mn) (op.(znz_mul_c)";
  pr "       (castm (diff_r n m) (extend_tr x (snd d)))";
  pr "       (castm (diff_l n m) (extend_tr y (fst d)))).";
  pr "";

  pr " Definition mul := Eval lazy beta delta [iter0] in ";
  pr "  (iter0 t_ ";
  for i = 0 to size do
    pr "    (fun x y => reduce_%i (w%i_mul_c x y)) " (i + 1) i;
    pr "    (fun n x y => w%i_mul n y x)" i;
    pr "    w%i_mul" i;
  done;
  pr "    mulnm";
  pr "    (fun _ => N0 w_0)";
  pr "    (fun _ => N0 w_0)";
  pr "  ).";
  pr "";
  for i = 0 to size do
    pp " Let spec_w%i_mul_add: forall x y z," i;
    pp "  let (q,r) := w%i_mul_add x y z in" i;
    pp "  znz_to_Z w%i_op q * (base (znz_digits w%i_op))  +  znz_to_Z w%i_op r =" i i i;
    pp "  znz_to_Z w%i_op x * znz_to_Z w%i_op y + znz_to_Z w%i_op z :=" i i i ;
    pp "   (spec_mul_add w%i_spec)." i;
    pp "";
  done;

  for i = 0 to size do
    pp " Theorem spec_w%i_mul_add_n1: forall n x y z," i;
    pp "  let (q,r) := w%i_mul_add_n1 n x y z in" i;
    pp "  znz_to_Z w%i_op q * (base (znz_digits (nmake_op _ w%i_op n)))  +" i i;
    pp "  znz_to_Z (nmake_op _ w%i_op n) r =" i;
    pp "  znz_to_Z (nmake_op _ w%i_op n) x * znz_to_Z w%i_op y +" i i;
    pp "  znz_to_Z w%i_op z." i;
    pp " Proof.";
    pp " intros n x y z; unfold w%i_mul_add_n1." i;
    pp " rewrite nmake_gen.";
    pp " rewrite digits_gend.";
    pp " change (base (GenBase.gen_digits (znz_digits w%i_op) n)) with" i;
    pp "        (GenBase.gen_wB (znz_digits w%i_op) n)." i;
    pp " apply spec_gen_mul_add_n1; auto.";
    if i == 0 then pp " exact (spec_0 w%i_spec)." i;
    pp " exact (spec_WW w%i_spec)." i;
    pp " exact (spec_0W w%i_spec)." i;
    pp " exact (spec_mul_add w%i_spec)." i;
    pp " Qed.";
    pp "";
  done;
  
  pp "  Lemma nmake_op_WW: forall ww ww1 n x y,";
  pp "    znz_to_Z (nmake_op ww ww1 (S n)) (WW x y) =";
  pp "    znz_to_Z (nmake_op ww ww1 n) x * base (znz_digits (nmake_op ww ww1 n)) +";
  pp "    znz_to_Z (nmake_op ww ww1 n) y.";
  pp "    auto.";
  pp "  Qed.";
  pp "";
  
  for i = 0 to size do
    pp "  Lemma extend%in_spec: forall n x1," i;
    pp "  znz_to_Z (nmake_op _ w%i_op (S n)) (extend%i n x1) = " i i;
    pp "  znz_to_Z w%i_op x1." i;
    pp "  Proof.";
    pp "    intros n1 x2; rewrite nmake_gen.";
    pp "    unfold extend%i." i;
    pp "    rewrite GenBase.spec_extend; auto.";
    if i == 0 then 
      pp "    intros l; simpl; unfold w_0; rewrite (spec_0 w0_spec); ring.";
    pp "  Qed.";
    pp "";
  done;
  
  pp "  Lemma spec_muln:";
  pp "    forall n (x: word _ (S n)) y,";
  pp "     [%sn (S n) (znz_mul_c (make_op n) x y)] = [%sn n x] * [%sn n y]." c c c;
  pp "  Proof.";
  pp "    intros n x y; unfold to_Z.";
  pp "    rewrite <- (spec_mul_c (wn_spec n)).";
  pp "    rewrite make_op_S.";
  pp "    case znz_mul_c; auto.";
  pp "  Qed.";

  pr "  Theorem spec_mul: forall x y, [mul x y] = [x] * [y].";
  pa "  Admitted.";
  pp "  Proof.";
  for i = 0 to size do
    pp "    assert(F%i: " i;
    pp "    forall n x y,";
    if i <> size then
      pp0 "    Z_of_nat n <= %i -> "   (size - i);
    pp "    [w%i_mul n x y] = eval%in (S n) x * [%s%i y])." i i c i;
    if i == size then
      pp "    intros n x y; unfold w%i_mul." i
    else
      pp "    intros n x y H; unfold w%i_mul." i;
    pp "    generalize (spec_w%i_mul_add_n1 (S n) x y %s)." i (pz i);
    pp "    case w%i_mul_add_n1; intros x1 y1." i;
    pp "    change (znz_to_Z (nmake_op _ w%i_op (S n)) x) with (eval%in (S n) x)." i i;
    pp "    change (znz_to_Z w%i_op y) with ([%s%i y])." i c i;
    if i == 0 then
      pp "    unfold w_0; rewrite (spec_0 w0_spec); rewrite Zplus_0_r."
    else
      pp "    change (znz_to_Z w%i_op W0) with 0; rewrite Zplus_0_r." i;
    pp "    intros H1; rewrite <- H1; clear H1.";
    pp "    generalize (spec_w%i_eq0 x1); case w%i_eq0; intros HH." i i;
    pp "    unfold to_Z in HH; rewrite HH.";
    if i == size then
      begin 
        pp "    rewrite spec_eval%in; unfold eval%in, nmake_op%i; auto." i i i;
        pp "    rewrite spec_eval%in; unfold eval%in, nmake_op%i." i i i
      end
    else
      begin
        pp "    rewrite to_Z%i_spec; auto with zarith." i;
        pp "    rewrite to_Z%i_spec; try (rewrite inj_S; auto with zarith)." i
      end;
    pp "    rewrite nmake_op_WW; rewrite extend%in_spec; auto." i;
  done;
  pp "    refine (spec_iter0 t_ (fun x y res => [res] = x * y)";
  for i = 0 to size do
    pp "    (fun x y => reduce_%i (w%i_mul_c x y)) " (i + 1) i;
    pp "    (fun n x y => w%i_mul n y x)" i;
    pp "    w%i_mul _ _ _" i;
  done;
  pp "    mulnm _";
  pp "    (fun _ => N0 w_0) _";
  pp "    (fun _ => N0 w_0) _";
  pp "  ).";
  for i = 0 to size do
    pp "    intros x y; rewrite spec_reduce_%i." (i + 1);
    pp "    unfold w%i_mul_c, to_Z." i;
    pp "    generalize (spec_mul_c w%i_spec x y)." i;
    pp "    intros HH; rewrite <- HH; clear HH; auto.";
    if i == size then
      begin
        pp "    intros n x y; rewrite F%i; auto with zarith." i;
        pp "    intros n x y; rewrite F%i; auto with zarith. " i;
      end
    else
      begin
        pp "    intros n x y H; rewrite F%i; auto with zarith." i;
        pp "    intros n x y H; rewrite F%i; auto with zarith. " i;
      end;
  done;
  pp "    intros n m x y; unfold mulnm.";
  pp "    rewrite spec_reduce_n.";
  pp "    rewrite <- (spec_cast_l n m x).";
  pp "    rewrite <- (spec_cast_r n m y).";
  pp "    rewrite spec_muln; rewrite spec_cast_l; rewrite spec_cast_r; auto.";
  pp "    intros x; unfold to_Z, w_0; rewrite (spec_0 w0_spec); ring.";
  pp "    intros x; unfold to_Z, w_0; rewrite (spec_0 w0_spec); ring.";
  pp "  Qed.";
  pr "";

  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Square                            *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr "";

  for i = 0 to size do
    pr " Definition w%i_square_c := w%i_op.(znz_square_c)." i i
  done;
  pr "";

  pr " Definition square x :=";
  pr "  match x with";
  pr "  | %s0 wx => reduce_1 (w0_square_c wx)" c;
  for i = 1 to size - 1 do
    pr "  | %s%i wx => %s%i (w%i_square_c wx)" c i c (i+1) i
  done;
  pr "  | %s%i wx => %sn 0 (w%i_square_c wx)" c size c size;
  pr "  | %sn n wx =>" c;
  pr "    let op := make_op n in";
  pr "    %sn (S n) (op.(znz_square_c) wx)" c;
  pr "  end.";
  pr "";

  pr " Theorem spec_square: forall x, [square x] = [x] * [x].";
  pa " Admitted.";
  pp " Proof.";
  pp "  intros x; case x; unfold square; clear x.";
  pp "  intros x; rewrite spec_reduce_1; unfold to_Z.";
  pp "   exact (spec_square_c w%i_spec x)." 0;
  for i = 1 to size do
    pp "  intros x; unfold to_Z.";
    pp "    exact (spec_square_c w%i_spec x)." i;
  done;
  pp "  intros n x; unfold to_Z.";
  pp "    rewrite make_op_S.";
  pp "    exact (spec_square_c (wn_spec n) x).";
  pp "Qed.";
  pr "";


  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Power                             *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr ""; 

  pr " Fixpoint power_pos (x:%s) (p:positive) {struct p} : %s :=" t t;
  pr "  match p with";
  pr "  | xH => x";
  pr "  | xO p => square (power_pos x p)";
  pr "  | xI p => mul (square (power_pos x p)) x";
  pr "  end.";
  pr "";

  pr " Theorem spec_power_pos: forall x n, [power_pos x n] = [x] ^ Zpos n.";
  pa " Admitted.";  
  pp " Proof.";
  pp " intros x n; generalize x; elim n; clear n x; simpl power_pos.";
  pp " intros; rewrite spec_mul; rewrite spec_square; rewrite H.";
  pp " rewrite Zpos_xI; rewrite Zpower_exp; auto with zarith.";
  pp " rewrite (Zmult_comm 2); rewrite Zpower_mult; auto with zarith.";
  pp " rewrite Zpower_2; rewrite Zpower_1_r; auto.";
  pp " intros; rewrite spec_square; rewrite H.";
  pp " rewrite Zpos_xO; auto with zarith.";
  pp " rewrite (Zmult_comm 2); rewrite Zpower_mult; auto with zarith.";
  pp " rewrite Zpower_2; auto.";
  pp " intros; rewrite Zpower_1_r; auto.";
  pp " Qed.";
  pp "";
  pr "";

  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Square root                       *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr "";

  for i = 0 to size do
    pr " Definition w%i_sqrt := w%i_op.(znz_sqrt)." i i
  done;
  pr "";

  pr " Definition sqrt x :=";
  pr "  match x with";
  for i = 0 to size do
    pr "  | %s%i wx => reduce_%i (w%i_sqrt wx)" c i i i;
  done;
  pr "  | %sn n wx =>" c;
  pr "    let op := make_op n in";
  pr "    reduce_n n (op.(znz_sqrt) wx)";
  pr "  end.";
  pr "";

  pr " Theorem spec_sqrt: forall x, [sqrt x] ^ 2 <= [x] < ([sqrt x] + 1) ^ 2.";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x; unfold sqrt; case x; clear x.";
  for i = 0 to size do
    pp " intros x; rewrite spec_reduce_%i; exact (spec_sqrt w%i_spec x)." i i;
  done;
  pp " intros n x; rewrite spec_reduce_n; exact (spec_sqrt (wn_spec n) x).";
  pp " Qed.";
  pr "";


  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Division                          *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr ""; 

  for i = 0 to size do
    pr " Definition w%i_div_gt := w%i_op.(znz_div_gt)." i i
  done;
  pr "";

  pp " Let spec_divn1 ww (ww_op: znz_op ww) (ww_spec: znz_spec ww_op) := ";
  pp "   (spec_gen_divn1 ";
  pp "    ww_op.(znz_zdigits) ww_op.(znz_0)";
  pp "    ww_op.(znz_WW) ww_op.(znz_head0)";
  pp "    ww_op.(znz_add_mul_div) ww_op.(znz_div21)";
  pp "    ww_op.(znz_compare) ww_op.(znz_sub) (znz_to_Z ww_op)";
  pp "    (spec_to_Z ww_spec) ";
  pp "    (spec_zdigits ww_spec)";
  pp "   (spec_0 ww_spec) (spec_WW ww_spec) (spec_head0 ww_spec)";
  pp "   (spec_add_mul_div ww_spec) (spec_div21 ww_spec) ";
  pp "    (ZnZ.spec_compare ww_spec) (ZnZ.spec_sub ww_spec)).";
  pp "";

  for i = 0 to size do
    pr " Definition w%i_divn1 n x y :="  i;
    pr "  let (u, v) :=";
    pr "  gen_divn1 w%i_op.(znz_zdigits) w%i_op.(znz_0)" i i;
    pr "    w%i_op.(znz_WW) w%i_op.(znz_head0)" i i;
    pr "    w%i_op.(znz_add_mul_div) w%i_op.(znz_div21)" i i;
    pr "    w%i_op.(znz_compare) w%i_op.(znz_sub) (S n) x y in" i i;
    if i == size then
      pr "   (%sn _ u, %s%i v)." c c i
    else
      pr "   (to_Z%i _ u, %s%i v)." i c i;
  done;
  pr "";

  for i = 0 to size do
    pp " Lemma spec_get_end%i: forall n x y," i;
    pp "    eval%in n x  <= [%s%i y] -> " i c i;
    pp "     [%s%i (GenBase.get_low %s n x)] = eval%in n x." c i (pz i) i;
    pp " Proof.";
    pp " intros n x y H.";
    pp " rewrite spec_gen_eval%in; unfold to_Z." i;
    pp " apply GenBase.spec_get_low.";
    pp " exact (spec_0 w%i_spec)." i;
    pp " exact (spec_to_Z w%i_spec)." i;
    pp " apply Zle_lt_trans with [%s%i y]; auto." c i;
    pp "   rewrite <- spec_gen_eval%in; auto." i;
    pp " unfold to_Z; case (spec_to_Z w%i_spec y); auto." i;
    pp " Qed.";
    pp "";
  done;

  for i = 0 to size do
    pr " Let div_gt%i x y := let (u,v) := (w%i_div_gt x y) in (reduce_%i u, reduce_%i v)." i i i i;
  done;
  pr "";


  pr " Let div_gtnm n m wx wy :=";
  pr "    let mn := Max.max n m in";
  pr "    let d := diff n m in";
  pr "    let op := make_op mn in";
  pr "    let (q, r):= op.(znz_div_gt)";
  pr "         (castm (diff_r n m) (extend_tr wx (snd d)))";
  pr "         (castm (diff_l n m) (extend_tr wy (fst d))) in";
  pr "    (reduce_n mn q, reduce_n mn r).";
  pr "";

  pr " Definition div_gt := Eval lazy beta delta [iter] in";
  pr "   (iter _ ";
  for i = 0 to size do 
    pr "      div_gt%i" i;
    pr "      (fun n x y => div_gt%i x (GenBase.get_low %s (S n) y))" i (pz i);
    pr "      w%i_divn1" i;
  done;
  pr "      div_gtnm).";
  pr "";

  pr " Theorem spec_div_gt: forall x y,";
  pr "       [x] > [y] -> 0 < [y] ->";
  pr "      let (q,r) := div_gt x y in";
  pr "      [q] = [x] / [y] /\\ [r] = [x] mod [y].";
  pa " Admitted.";
  pp " Proof.";
  pp " assert (FO:";
  pp "   forall x y, [x] > [y] -> 0 < [y] ->";
  pp "      let (q,r) := div_gt x y in";
  pp "      [x] = [q] * [y] + [r] /\\ 0 <= [r] < [y]).";
  pp "  refine (spec_iter (t_*t_) (fun x y res => x > y -> 0 < y ->";  
  pp "      let (q,r) := res in";
  pp "      x = [q] * y + [r] /\\ 0 <= [r] < y)";
  for i = 0 to size do 
    pp "      div_gt%i" i;
    pp "      (fun n x y => div_gt%i x (GenBase.get_low %s (S n) y))" i (pz i);
    pp "      w%i_divn1 _ _ _" i;
  done;
  pp "      div_gtnm _).";
  for i = 0 to size do
    pp "  intros x y H1 H2; unfold div_gt%i, w%i_div_gt." i i;
    pp "    generalize (spec_div_gt w%i_spec x y H1 H2); case znz_div_gt." i;
    pp "    intros xx yy; repeat rewrite spec_reduce_%i; auto." i;
    if i == size then
      pp "  intros n x y H2 H3; unfold div_gt%i, w%i_div_gt." i i
    else
      pp "  intros n x y H1 H2 H3; unfold div_gt%i, w%i_div_gt." i i;
    pp "    generalize (spec_div_gt w%i_spec x " i;
    pp "                (GenBase.get_low %s (S n) y))." (pz i);
    pp0 "    ";
    for j = 0 to i do
      pp0 "unfold w%i; " (i-j); 
    done;
    pp "case znz_div_gt.";
    pp "    intros xx yy H4; repeat rewrite spec_reduce_%i." i;
    pp "    generalize (spec_get_end%i (S n) y x); unfold to_Z; intros H5." i;
    pp "    unfold to_Z in H2; rewrite H5 in H4; auto with zarith.";
    if i == size then
      pp "  intros n x y H2 H3."
    else
      pp "  intros n x y H1 H2 H3.";
    pp "    generalize";
    pp "     (spec_divn1 w%i w%i_op w%i_spec (S n) x y H3)." i i i;
    pp0 "    unfold w%i_divn1; " i;
    for j = 0 to i do
      pp0 "unfold w%i; " (i-j); 
    done;
    pp "case gen_divn1.";
    pp "    intros xx yy H4.";
    if i == size then
      begin
        pp "    repeat rewrite <- spec_gen_eval%in in H4; auto." i;
        pp "    rewrite spec_eval%in; auto." i;
      end
    else
      begin
        pp "    rewrite to_Z%i_spec; auto with zarith." i;
        pp "    repeat rewrite <- spec_gen_eval%in in H4; auto." i;
      end;
  done;
  pp "  intros n m x y H1 H2; unfold div_gtnm.";
  pp "    generalize (spec_div_gt (wn_spec (Max.max n m))";
  pp "                   (castm (diff_r n m)";
  pp "                     (extend_tr x (snd (diff n m))))";
  pp "                   (castm (diff_l n m)";
  pp "                     (extend_tr y (fst (diff n m))))).";
  pp "    case znz_div_gt.";
  pp "    intros xx yy HH.";
  pp "    repeat rewrite spec_reduce_n.";
  pp "    rewrite <- (spec_cast_l n m x).";
  pp "    rewrite <- (spec_cast_r n m y).";
  pp "    unfold to_Z; apply HH.";
  pp "    rewrite <- (spec_cast_l n m x) in H1; auto.";
  pp "    rewrite <- (spec_cast_r n m y) in H1; auto.";
  pp "    rewrite <- (spec_cast_r n m y) in H2; auto.";
  pp "  intros x y H1 H2; generalize (FO x y H1 H2); case div_gt.";
  pp "  intros q r (H3, H4); split.";
  pp "  apply (Zdiv_unique [x] [y] [q] [r]); auto.";
  pp "  rewrite Zmult_comm; auto.";
  pp "  apply (Zmod_unique [x] [y] [q] [r]); auto.";
  pp "  rewrite Zmult_comm; auto.";
  pp "  Qed.";
  pr "";

  pr " Definition div_eucl x y :=";
  pr "  match compare x y with";
  pr "  | Eq => (one, zero)";
  pr "  | Lt => (zero, x)";
  pr "  | Gt => div_gt x y";
  pr "  end.";
  pr "";

  pr " Theorem spec_div_eucl: forall x y,";
  pr "      0 < [y] ->";
  pr "      let (q,r) := div_eucl x y in";
  pr "      ([q], [r]) = Zdiv_eucl [x] [y].";
  pa " Admitted.";
  pp " Proof.";
  pp " assert (F0: [zero] = 0).";
  pp "   exact (spec_0 w0_spec).";
  pp " assert (F1: [one] = 1).";
  pp "   exact (spec_1 w0_spec).";
  pp " intros x y H; generalize (spec_compare x y);";
  pp "   unfold div_eucl; case compare; try rewrite F0;";
  pp "   try rewrite F1; intros; auto with zarith.";
  pp " rewrite H0; generalize (Z_div_same [y] (Zlt_gt _ _ H))";
  pp "                        (Z_mod_same [y] (Zlt_gt _ _ H));";
  pp "  unfold Zdiv, Zmod; case Zdiv_eucl; intros; subst; auto.";
  pp " assert (F2: 0 <= [x] < [y]).";
  pp "   generalize (spec_pos x); auto.";
  pp " generalize (Zdiv_small _ _ F2)";
  pp "            (Zmod_small _ _ F2);";
  pp "  unfold Zdiv, Zmod; case Zdiv_eucl; intros; subst; auto.";
  pp " generalize (spec_div_gt _ _ H0 H); auto.";
  pp " unfold Zdiv, Zmod; case Zdiv_eucl; case div_gt.";
  pp " intros a b c d (H1, H2); subst; auto.";
  pp " Qed.";
  pr "";

  pr " Definition div x y := fst (div_eucl x y).";
  pr "";

  pr " Theorem spec_div:";
  pr "   forall x y, 0 < [y] -> [div x y] = [x] / [y].";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x y H1; unfold div; generalize (spec_div_eucl x y H1);";
  pp "   case div_eucl; simpl fst.";
  pp " intros xx yy; unfold Zdiv; case Zdiv_eucl; intros qq rr H; ";
  pp "  injection H; auto.";
  pp " Qed.";
  pr "";

  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Modulo                            *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr ""; 

  for i = 0 to size do
    pr " Definition w%i_mod_gt := w%i_op.(znz_mod_gt)." i i
  done;
  pr "";

  for i = 0 to size do
    pr " Definition w%i_modn1 :=" i;
    pr "  gen_modn1 w%i_op.(znz_zdigits) w%i_op.(znz_0)" i i;
    pr "    w%i_op.(znz_head0) w%i_op.(znz_add_mul_div) w%i_op.(znz_div21)" i i i;
    pr "    w%i_op.(znz_compare) w%i_op.(znz_sub)." i i;
  done;
  pr "";

  pr " Let mod_gtnm n m wx wy :=";
  pr "    let mn := Max.max n m in";
  pr "    let d := diff n m in";
  pr "    let op := make_op mn in";
  pr "    reduce_n mn (op.(znz_mod_gt)";
  pr "         (castm (diff_r n m) (extend_tr wx (snd d)))";
  pr "         (castm (diff_l n m) (extend_tr wy (fst d)))).";
  pr "";

  pr " Definition mod_gt := Eval lazy beta delta[iter] in";
  pr "   (iter _ ";
  for i = 0 to size do
    pr "      (fun x y => reduce_%i (w%i_mod_gt x y))" i i;
    pr "      (fun n x y => reduce_%i (w%i_mod_gt x (GenBase.get_low %s (S n) y)))" i i (pz i);
    pr "      (fun n x y => reduce_%i (w%i_modn1 (S n) x y))" i i;
  done;
  pr "      mod_gtnm).";
  pr "";

  pp " Let spec_modn1 ww (ww_op: znz_op ww) (ww_spec: znz_spec ww_op) := ";
  pp "   (spec_gen_modn1 ";
  pp "    ww_op.(znz_zdigits) ww_op.(znz_0)";
  pp "    ww_op.(znz_WW) ww_op.(znz_head0)";
  pp "    ww_op.(znz_add_mul_div) ww_op.(znz_div21)";
  pp "    ww_op.(znz_compare) ww_op.(znz_sub) (znz_to_Z ww_op)";
  pp "    (spec_to_Z ww_spec) ";
  pp "    (spec_zdigits ww_spec)";
  pp "   (spec_0 ww_spec) (spec_WW ww_spec) (spec_head0 ww_spec)";
  pp "   (spec_add_mul_div ww_spec) (spec_div21 ww_spec) ";
  pp "    (ZnZ.spec_compare ww_spec) (ZnZ.spec_sub ww_spec)).";
  pp "";

  pr " Theorem spec_mod_gt:";
  pr "   forall x y, [x] > [y] -> 0 < [y] -> [mod_gt x y] = [x] mod [y].";
  pa " Admitted.";
  pp " Proof.";
  pp " refine (spec_iter _ (fun x y res => x > y -> 0 < y ->";
  pp "      [res] = x mod y)";
  for i = 0 to size do
    pp "      (fun x y => reduce_%i (w%i_mod_gt x y))" i i;
    pp "      (fun n x y => reduce_%i (w%i_mod_gt x (GenBase.get_low %s (S n) y)))" i i (pz i);
    pp "      (fun n x y => reduce_%i (w%i_modn1 (S n) x y)) _ _ _" i i;
  done;
  pp "      mod_gtnm _).";
  for i = 0 to size do
    pp " intros x y H1 H2; rewrite spec_reduce_%i." i;
    pp "   exact (spec_mod_gt w%i_spec x y H1 H2)." i;
    if i == size then
      pp " intros n x y H2 H3; rewrite spec_reduce_%i." i
    else
      pp " intros n x y H1 H2 H3; rewrite spec_reduce_%i." i;
    pp " unfold w%i_mod_gt." i;
    pp " rewrite <- (spec_get_end%i (S n) y x); auto with zarith." i;
    pp " unfold to_Z; apply (spec_mod_gt w%i_spec); auto." i;
    pp " rewrite <- (spec_get_end%i (S n) y x) in H2; auto with zarith." i;
    pp " rewrite <- (spec_get_end%i (S n) y x) in H3; auto with zarith." i;
    if i == size then
      pp " intros n x y H2 H3; rewrite spec_reduce_%i." i
    else 
      pp " intros n x y H1 H2 H3; rewrite spec_reduce_%i." i;
    pp " unfold w%i_modn1, to_Z; rewrite spec_gen_eval%in." i i;
    pp " apply (spec_modn1 _ _ w%i_spec); auto." i;
  done;
  pp " intros n m x y H1 H2; unfold mod_gtnm.";
  pp "    repeat rewrite spec_reduce_n.";
  pp "    rewrite <- (spec_cast_l n m x).";
  pp "    rewrite <- (spec_cast_r n m y).";
  pp "    unfold to_Z; apply (spec_mod_gt (wn_spec (Max.max n m))).";
  pp "    rewrite <- (spec_cast_l n m x) in H1; auto.";
  pp "    rewrite <- (spec_cast_r n m y) in H1; auto.";
  pp "    rewrite <- (spec_cast_r n m y) in H2; auto.";
  pp " Qed.";
  pr "";

  pr " Definition modulo x y := ";
  pr "  match compare x y with";
  pr "  | Eq => zero";
  pr "  | Lt => x";
  pr "  | Gt => mod_gt x y";
  pr "  end.";
  pr "";

  pr " Theorem spec_modulo:";
  pr "   forall x y, 0 < [y] -> [modulo x y] = [x] mod [y].";
  pa " Admitted.";
  pp " Proof.";
  pp " assert (F0: [zero] = 0).";
  pp "   exact (spec_0 w0_spec).";
  pp " assert (F1: [one] = 1).";
  pp "   exact (spec_1 w0_spec).";
  pp " intros x y H; generalize (spec_compare x y);";
  pp "   unfold modulo; case compare; try rewrite F0;";
  pp "   try rewrite F1; intros; try split; auto with zarith.";
  pp " rewrite H0; apply sym_equal; apply Z_mod_same; auto with zarith.";
  pp " apply sym_equal; apply Zmod_small; auto with zarith.";
  pp " generalize (spec_pos x); auto with zarith.";
  pp " apply spec_mod_gt; auto.";
  pp " Qed.";
  pr "";

  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                           Gcd                               *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr ""; 

  pr " Definition digits x :=";
  pr "  match x with";
  for i = 0 to size do
    pr "  | %s%i _ => w%i_op.(znz_digits)" c i i;
  done;
  pr "  | %sn n _ => (make_op n).(znz_digits)" c;
  pr "  end.";
  pr "";

  pr " Theorem spec_digits: forall x, 0 <= [x] < 2 ^  Zpos (digits x).";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x; case x; clear x.";
  for i = 0 to size do
    pp "  intros x; unfold to_Z, digits;";
    pp "   generalize (spec_to_Z w%i_spec x); unfold base; intros H; exact H." i;
  done;
  pp "  intros n x; unfold to_Z, digits;";
  pp "   generalize (spec_to_Z (wn_spec n) x); unfold base; intros H; exact H.";
  pp " Qed.";
  pr "";

  pr " Definition gcd_gt_body a b cont :=";
  pr "  match compare b zero with";
  pr "  | Gt =>";
  pr "    let r := mod_gt a b in";
  pr "    match compare r zero with";
  pr "    | Gt => cont r (mod_gt b r)";
  pr "    | _ => b";
  pr "    end";
  pr "  | _ => a";
  pr "  end.";
  pr "";

  pp " Theorem Zspec_gcd_gt_body: forall a b cont p,";
  pp "    [a] > [b] -> [a] < 2 ^ p ->";
  pp "      (forall a1 b1, [a1] < 2 ^ (p - 1) -> [a1] > [b1] ->";
  pp "         Zis_gcd  [a1] [b1] [cont a1 b1]) ->                   ";
  pp "      Zis_gcd [a] [b] [gcd_gt_body a b cont].";
  pp " Proof.";
  pp " assert (F1: [zero] = 0).";
  pp "   unfold zero, w_0, to_Z; rewrite (spec_0 w0_spec); auto.";
  pp " intros a b cont p H2 H3 H4; unfold gcd_gt_body.";
  pp " generalize (spec_compare b zero); case compare; try rewrite F1.";
  pp "   intros HH; rewrite HH; apply Zis_gcd_0.";
  pp " intros HH; absurd (0 <= [b]); auto with zarith.";
  pp " case (spec_digits b); auto with zarith.";
  pp " intros H5; generalize (spec_compare (mod_gt a b) zero); ";
  pp "   case compare; try rewrite F1.";
  pp " intros H6; rewrite <- (Zmult_1_r [b]).";
  pp " rewrite (Z_div_mod_eq [a] [b]); auto with zarith.";
  pp " rewrite <- spec_mod_gt; auto with zarith.";
  pp " rewrite H6; rewrite Zplus_0_r.";
  pp " apply Zis_gcd_mult; apply Zis_gcd_1.";
  pp " intros; apply False_ind.";
  pp " case (spec_digits (mod_gt a b)); auto with zarith.";
  pp " intros H6; apply GenDiv.Zis_gcd_mod; auto with zarith.";
  pp " apply GenDiv.Zis_gcd_mod; auto with zarith.";
  pp " rewrite <- spec_mod_gt; auto with zarith.";
  pp " assert (F2: [b] > [mod_gt a b]).";
  pp "   case (Z_mod_lt [a] [b]); auto with zarith.";
  pp "   repeat rewrite <- spec_mod_gt; auto with zarith.";
  pp " assert (F3: [mod_gt a b] > [mod_gt b  (mod_gt a b)]).";
  pp "   case (Z_mod_lt [b] [mod_gt a b]); auto with zarith.";
  pp "   rewrite <- spec_mod_gt; auto with zarith.";
  pp " repeat rewrite <- spec_mod_gt; auto with zarith.";
  pp " apply H4; auto with zarith.";
  pp " apply Zmult_lt_reg_r with 2; auto with zarith.";
  pp " apply Zle_lt_trans with ([b] + [mod_gt a b]); auto with zarith.";
  pp " apply Zle_lt_trans with (([a]/[b]) * [b] + [mod_gt a b]); auto with zarith.";
  pp "   apply Zplus_le_compat_r.";
  pp " pattern [b] at 1; rewrite <- (Zmult_1_l [b]).";
  pp " apply Zmult_le_compat_r; auto with zarith.";
  pp " case (Zle_lt_or_eq 0 ([a]/[b])); auto with zarith.";
  pp " intros HH; rewrite (Z_div_mod_eq [a] [b]) in H2;";
  pp "   try rewrite <- HH in H2; auto with zarith.";
  pp " case (Z_mod_lt [a] [b]); auto with zarith.";
  pp " rewrite Zmult_comm; rewrite spec_mod_gt; auto with zarith.";
  pp " rewrite <- Z_div_mod_eq; auto with zarith.";
  pp " pattern 2 at 2; rewrite <- (Zpower_1_r 2).";
  pp " rewrite <- Zpower_exp; auto with zarith.";
  pp " ring_simplify (p - 1 + 1); auto.";
  pp " case (Zle_lt_or_eq 0 p); auto with zarith.";
  pp " generalize H3; case p; simpl Zpower; auto with zarith.";
  pp " intros HH; generalize H3; rewrite <- HH; simpl Zpower; auto with zarith.";
  pp " Qed.";
  pp "";

  pr " Fixpoint gcd_gt_aux (p:positive) (cont:t->t->t) (a b:t) {struct p} : t :=";
  pr "  gcd_gt_body a b";
  pr "    (fun a b =>";
  pr "       match p with";
  pr "       | xH => cont a b";
  pr "       | xO p => gcd_gt_aux p (gcd_gt_aux p cont) a b";
  pr "       | xI p => gcd_gt_aux p (gcd_gt_aux p cont) a b";
  pr "       end).";
  pr "";

  pp " Theorem Zspec_gcd_gt_aux: forall p n a b cont,";
  pp "    [a] > [b] -> [a] < 2 ^ (Zpos p + n) ->";
  pp "      (forall a1 b1, [a1] < 2 ^ n -> [a1] > [b1] ->";
  pp "            Zis_gcd [a1] [b1] [cont a1 b1]) ->";
  pp "          Zis_gcd [a] [b] [gcd_gt_aux p cont a b].";
  pp " intros p; elim p; clear p.";
  pp " intros p Hrec n a b cont H2 H3 H4.";
  pp "   unfold gcd_gt_aux; apply Zspec_gcd_gt_body with (Zpos (xI p) + n); auto.";
  pp "   intros a1 b1 H6 H7.";
  pp "     apply Hrec with (Zpos p + n); auto.";
  pp "       replace (Zpos p + (Zpos p + n)) with";
  pp "         (Zpos (xI p) + n  - 1); auto.";
  pp "       rewrite Zpos_xI; ring.";
  pp "   intros a2 b2 H9 H10.";
  pp "     apply Hrec with n; auto.";
  pp " intros p Hrec n a b cont H2 H3 H4.";
  pp "   unfold gcd_gt_aux; apply Zspec_gcd_gt_body with (Zpos (xO p) + n); auto.";
  pp "   intros a1 b1 H6 H7.";
  pp "     apply Hrec with (Zpos p + n - 1); auto.";
  pp "       replace (Zpos p + (Zpos p + n - 1)) with";
  pp "         (Zpos (xO p) + n  - 1); auto.";
  pp "       rewrite Zpos_xO; ring.";
  pp "   intros a2 b2 H9 H10.";
  pp "     apply Hrec with (n - 1); auto.";
  pp "       replace (Zpos p + (n - 1)) with";
  pp "         (Zpos p + n  - 1); auto with zarith.";
  pp "   intros a3 b3 H12 H13; apply H4; auto with zarith.";
  pp "    apply Zlt_le_trans with (1 := H12).";
  pp "    case (Zle_or_lt 1 n); intros HH.";
  pp "    apply Zpower_le_monotone; auto with zarith.";
  pp "    apply Zle_trans with 0; auto with zarith.";
  pp "    assert (HH1: n - 1 < 0); auto with zarith.";
  pp "    generalize HH1; case (n - 1); auto with zarith.";
  pp "    intros p1 HH2; discriminate.";
  pp " intros n a b cont H H2 H3.";
  pp "  simpl gcd_gt_aux.";
  pp "  apply Zspec_gcd_gt_body with (n + 1); auto with zarith.";
  pp "  rewrite Zplus_comm; auto.";
  pp "  intros a1 b1 H5 H6; apply H3; auto.";
  pp "  replace n with (n + 1 - 1); auto; try ring.";
  pp " Qed.";
  pp "";

  pr " Definition gcd_cont a b :=";
  pr "  match compare one b with";
  pr "  | Eq => one";
  pr "  | _ => a";
  pr "  end.";
  pr "";

  pr " Definition gcd_gt a b := gcd_gt_aux (digits a) gcd_cont a b.";
  pr "";

  pr " Theorem spec_gcd_gt: forall a b,";
  pr "   [a] > [b] -> [gcd_gt a b] = Zgcd [a] [b].";
  pa " Admitted.";
  pp " Proof.";
  pp " intros a b H2.";
  pp " case (spec_digits (gcd_gt a b)); intros H3 H4.";
  pp " case (spec_digits a); intros H5 H6.";
  pp " apply sym_equal; apply Zis_gcd_gcd; auto with zarith.";
  pp " unfold gcd_gt; apply Zspec_gcd_gt_aux with 0; auto with zarith.";
  pp " intros a1 a2; rewrite Zpower_0_r.";
  pp " case (spec_digits a2); intros H7 H8;";
  pp "   intros; apply False_ind; auto with zarith.";
  pp " Qed.";
  pr "";

  pr " Definition gcd a b :=";
  pr "  match compare a b with";
  pr "  | Eq => a";
  pr "  | Lt => gcd_gt b a";
  pr "  | Gt => gcd_gt a b";
  pr "  end.";
  pr "";

  pr " Theorem spec_gcd: forall a b, [gcd a b] = Zgcd [a] [b].";
  pa " Admitted.";
  pp " Proof.";
  pp " intros a b.";
  pp " case (spec_digits a); intros H1 H2.";
  pp " case (spec_digits b); intros H3 H4.";
  pp " unfold gcd; generalize (spec_compare a b); case compare.";
  pp " intros HH; rewrite HH; apply sym_equal; apply Zis_gcd_gcd; auto.";
  pp "   apply Zis_gcd_refl.";
  pp " intros; apply trans_equal with (Zgcd [b] [a]).";
  pp "   apply spec_gcd_gt; auto with zarith.";
  pp " apply Zis_gcd_gcd; auto with zarith.";
  pp " apply Zgcd_is_pos.";
  pp " apply Zis_gcd_sym; apply Zgcd_is_gcd.";
  pp " intros; apply spec_gcd_gt; auto.";
  pp " Qed.";
  pr "";


  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                          Conversion                         *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr "";

  pr " Definition pheight p := ";
  pr "   Peano.pred (nat_of_P (get_height w0_op.(znz_digits) (plength p))).";
  pr "";

  pr " Theorem pheight_correct: forall p, ";
  pr "    Zpos p < 2 ^ (Zpos (znz_digits w0_op) * 2 ^ (Z_of_nat (pheight p))).";
  pr " Proof.";
  pr " intros p; unfold pheight.";
  pr " assert (F1: forall x, Z_of_nat (Peano.pred (nat_of_P x)) = Zpos x - 1).";
  pr "  intros x.";
  pr "  assert (Zsucc (Z_of_nat (Peano.pred (nat_of_P x))) = Zpos x); auto with zarith.";
  pr "    rewrite <- inj_S.";
  pr "    rewrite <- (fun x => S_pred x 0); auto with zarith.";
  pr "    rewrite Zpos_eq_Z_of_nat_o_nat_of_P; auto.";
  pr "    apply lt_le_trans with 1%snat; auto with zarith." "%";
  pr "    exact (le_Pmult_nat x 1).";
  pr "  rewrite F1; clear F1.";
  pr " assert (F2:= (get_height_correct (znz_digits w0_op) (plength p))).";
  pr " apply Zlt_le_trans with (Zpos (Psucc p)).";
  pr "   rewrite Zpos_succ_morphism; auto with zarith.";
  pr "  apply Zle_trans with (1 := plength_pred_correct (Psucc p)).";
  pr " rewrite Ppred_succ.";
  pr " apply Zpower_le_monotone; auto with zarith.";
  pr " Qed.";
  pr "";

  pr " Definition of_pos x :=";
  pr "  let h := pheight x in";
  pr "  match h with";
  for i = 0 to size do
    pr "  | %i%snat => reduce_%i (snd (w%i_op.(znz_of_pos) x))" i "%" i i;
  done;
  pr "  | _ =>";
  pr "    let n := minus h %i in" (size + 1);
  pr "    reduce_n n (snd ((make_op n).(znz_of_pos) x))";
  pr "  end.";
  pr "";

  pr " Theorem spec_of_pos: forall x,";
  pr "   [of_pos x] = Zpos x.";
  pa " Admitted.";
  pp " Proof.";
  pp " assert (F := spec_more_than_1_digit w0_spec).";
  pp " intros x; unfold of_pos; case_eq (pheight x).";
  for i = 0 to size do
    if i <> 0 then
      pp " intros n; case n; clear n.";
    pp " intros H1; rewrite spec_reduce_%i; unfold to_Z." i;
    pp " apply (znz_of_pos_correct w%i_spec)." i;
    pp " apply Zlt_le_trans with (1 := pheight_correct x).";
    pp "   rewrite H1; simpl Z_of_nat; change (2^%i) with (%s)." i (gen2 i);
    pp "   unfold base.";
    pp "   apply Zpower_le_monotone; split; auto with zarith.";
    if i <> 0 then
      begin
        pp "   rewrite Zmult_comm; repeat rewrite <- Zmult_assoc.";
        pp "     repeat rewrite <- Zpos_xO.";
        pp "   refine (Zle_refl _).";
      end;
  done;
  pp " intros n.";
  pp " intros H1; rewrite spec_reduce_n; unfold to_Z.";
  pp " simpl minus; rewrite <- minus_n_O.";
  pp " apply (znz_of_pos_correct (wn_spec n)).";
  pp " apply Zlt_le_trans with (1 := pheight_correct x).";
  pp "   unfold base.";
  pp "   apply Zpower_le_monotone; auto with zarith.";
  pp "   split; auto with zarith.";
  pp "   rewrite H1.";
  pp "  elim n; clear n H1.";
  pp "   simpl Z_of_nat; change (2^%i) with (%s)." (size + 1) (gen2 (size + 1));
  pp "   rewrite Zmult_comm; repeat rewrite <- Zmult_assoc.";
  pp "     repeat rewrite <- Zpos_xO.";
  pp "   refine (Zle_refl _).";
  pp "  intros n Hrec.";
  pp "  rewrite make_op_S.";
  pp "  change (@znz_digits (word _ (S (S n))) (mk_zn2z_op_karatsuba (make_op n))) with";
  pp "    (xO (znz_digits (make_op n))).";
  pp "  rewrite (fun x y => (Zpos_xO (@znz_digits x y))).";
  pp "  rewrite inj_S; unfold Zsucc.";
  pp "  rewrite Zplus_comm; rewrite Zpower_exp; auto with zarith.";
  pp "  rewrite Zpower_1_r.";
  pp "  assert (tmp: forall x y z, x * (y * z) = y * (x * z));";
  pp "   [intros; ring | rewrite tmp; clear tmp].";
  pp "  apply Zmult_le_compat_l; auto with zarith.";
  pp "  Qed.";
  pr "";

  pr " Definition of_N x :=";
  pr "  match x with";
  pr "  | BinNat.N0 => zero";
  pr "  | Npos p => of_pos p";
  pr "  end.";
  pr "";


  pr " Theorem spec_of_N: forall x,";
  pr "   [of_N x] = Z_of_N x.";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x; case x.";
  pp "  simpl of_N.";
  pp "  unfold zero, w_0, to_Z; rewrite (spec_0 w0_spec); auto.";
  pp " intros p; exact (spec_of_pos p).";
  pp " Qed.";
  pr "";

  pr " (***************************************************************)";
  pr " (*                                                             *)";
  pr " (*                          Shift                              *)";
  pr " (*                                                             *)";
  pr " (***************************************************************)";
  pr ""; 

  (* Head0 *)
  pr " Definition head0 w := match w with";
  for i = 0 to size do
    pr " | %s%i w=> reduce_%i (w%i_op.(znz_head0) w)"  c i i i;
  done;
  pr " | %sn n w=> reduce_n n ((make_op n).(znz_head0) w)" c;
  pr " end.";
  pr "";

  pr " Theorem spec_head00: forall x, [x] = 0 ->[head0 x] = Zpos (digits x).";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x; case x; unfold head0; clear x.";
  for i = 0 to size do
    pp "   intros x; rewrite spec_reduce_%i; exact (spec_head00 w%i_spec x)." i i;
  done;
  pp " intros n x; rewrite spec_reduce_n; exact (spec_head00 (wn_spec n) x).";
  pp " Qed.";
  pr "  ";

  pr " Theorem spec_head0: forall x, 0 < [x] ->";
  pr "   2 ^ (Zpos (digits x) - 1) <= 2 ^ [head0 x] * [x] < 2 ^ Zpos (digits x).";
  pa " Admitted.";
  pp " Proof.";
  pp " assert (F0: forall x, (x - 1) + 1 = x).";
  pp "   intros; ring. ";
  pp " intros x; case x; unfold digits, head0; clear x.";
  for i = 0 to size do
    pp " intros x Hx; rewrite spec_reduce_%i." i;
    pp " assert (F1:= spec_more_than_1_digit w%i_spec)." i;
    pp " generalize (spec_head0 w%i_spec x Hx)." i;
    pp " unfold base.";
    pp " pattern (Zpos (znz_digits w%i_op)) at 1; " i;
    pp " rewrite <- (fun x => (F0 (Zpos x))).";
    pp " rewrite Zpower_exp; auto with zarith.";
    pp " rewrite Zpower_1_r; rewrite Z_div_mult; auto with zarith.";
  done;
  pp " intros n x Hx; rewrite spec_reduce_n.";
  pp " assert (F1:= spec_more_than_1_digit (wn_spec n)).";
  pp " generalize (spec_head0 (wn_spec n) x Hx).";
  pp " unfold base.";
  pp " pattern (Zpos (znz_digits (make_op n))) at 1; ";
  pp " rewrite <- (fun x => (F0 (Zpos x))).";
  pp " rewrite Zpower_exp; auto with zarith.";
  pp " rewrite Zpower_1_r; rewrite Z_div_mult; auto with zarith.";
  pp " Qed.";
  pr "";


  (* Tail0 *)
  pr " Definition tail0 w := match w with";
  for i = 0 to size do
    pr " | %s%i w=> reduce_%i (w%i_op.(znz_tail0) w)"  c i i i;
  done;
  pr " | %sn n w=> reduce_n n ((make_op n).(znz_tail0) w)" c;
  pr " end.";
  pr "";


  pr " Theorem spec_tail00: forall x, [x] = 0 ->[tail0 x] = Zpos (digits x).";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x; case x; unfold tail0; clear x.";
  for i = 0 to size do
    pp "   intros x; rewrite spec_reduce_%i; exact (spec_tail00 w%i_spec x)." i i;
  done;
  pp " intros n x; rewrite spec_reduce_n; exact (spec_tail00 (wn_spec n) x).";
  pp " Qed.";
  pr "  ";


  pr " Theorem spec_tail0: forall x,";
  pr "   0 < [x] -> exists y, 0 <= y /\\ [x] = (2 * y + 1) * 2 ^ [tail0 x].";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x; case x; clear x; unfold tail0.";
  for i = 0 to size do
    pp " intros x Hx; rewrite spec_reduce_%i; exact (spec_tail0 w%i_spec x Hx)." i  i;
  done;
  pp " intros n x Hx; rewrite spec_reduce_n; exact (spec_tail0 (wn_spec n) x Hx).";
  pp " Qed.";
  pr "";


  (* Number of digits *)
  pr " Definition %sdigits x :=" c;
  pr "  match x with";
  pr "  | %s0 _ => %s0 w0_op.(znz_zdigits)" c c;
  for i = 1 to size do 
    pr "  | %s%i _ => reduce_%i w%i_op.(znz_zdigits)" c i i i;
  done;
  pr "  | %sn n _ => reduce_n n (make_op n).(znz_zdigits)" c;
  pr "  end.";
  pr "";

  pr " Theorem spec_Ndigits: forall x, [Ndigits x] = Zpos (digits x).";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x; case x; clear x; unfold Ndigits, digits.";
  for i = 0 to size do
    pp " intros _; try rewrite spec_reduce_%i; exact (spec_zdigits w%i_spec)." i i;
  done;
  pp " intros n _; try rewrite spec_reduce_n; exact (spec_zdigits (wn_spec n)).";
  pp " Qed.";
  pr "";


  (* Shiftr *)
  for i = 0 to size do
    pr " Definition shiftr%i n x := w%i_op.(znz_add_mul_div) (w%i_op.(znz_sub) w%i_op.(znz_zdigits) n) w%i_op.(znz_0) x." i i i i i;
  done;
  pr " Definition shiftrn n p x := (make_op n).(znz_add_mul_div) ((make_op n).(znz_sub) (make_op n).(znz_zdigits) p) (make_op n).(znz_0) x.";
  pr "";

  pr " Definition shiftr := Eval lazy beta delta [same_level] in ";
  pr "     same_level _ (fun n x => %s0 (shiftr0 n x))" c;
  for i = 1 to size do
    pr "           (fun n x => reduce_%i (shiftr%i n x))" i i;
  done;
  pr "           (fun n p x => reduce_n n (shiftrn n p x)).";
  pr "";


  pr " Theorem spec_shiftr: forall n x,";
  pr "  [n] <= [Ndigits x] -> [shiftr n x] = [x] / 2 ^ [n].";
  pa " Admitted.";
  pp " Proof.";
  pp " assert (F0: forall x y, x - (x - y) = y).";
  pp "   intros; ring.";
  pp " assert (F2: forall x y z, 0 <= x -> 0 <= y -> x < z -> 0 <= x / 2 ^ y < z).";
  pp "   intros x y z HH HH1 HH2.";
  pp "   split; auto with zarith.";
  pp "   apply Zle_lt_trans with (2 := HH2); auto with zarith.";
  pp "   apply Zdiv_le_upper_bound; auto with zarith.";
  pp "   pattern x at 1; replace x with (x * 2 ^ 0); auto with zarith.";
  pp "   apply Zmult_le_compat_l; auto.";
  pp "   apply Zpower_le_monotone; auto with zarith.";
  pp "   rewrite Zpower_0_r; ring.";
  pp "  assert (F3: forall x y, 0 <= y -> y <= x -> 0 <= x - y < 2 ^ x).";
  pp "    intros xx y HH HH1.";
  pp "    split; auto with zarith.";
  pp "    apply Zle_lt_trans with xx; auto with zarith.";
  pp "    apply Zpower2_lt_lin; auto with zarith.";
  pp "  assert (F4: forall ww ww1 ww2 ";
  pp "         (ww_op: znz_op ww) (ww1_op: znz_op ww1) (ww2_op: znz_op ww2)";
  pp "           xx yy xx1 yy1,";
  pp "  znz_to_Z ww2_op yy <= znz_to_Z ww1_op (znz_zdigits ww1_op) ->";
  pp "  znz_to_Z ww1_op (znz_zdigits ww1_op) <= znz_to_Z ww_op (znz_zdigits ww_op) ->";
  pp "  znz_spec ww_op -> znz_spec ww1_op -> znz_spec ww2_op ->";
  pp "  znz_to_Z ww_op xx1 = znz_to_Z ww1_op xx ->";
  pp "  znz_to_Z ww_op yy1 = znz_to_Z ww2_op yy ->";
  pp "  znz_to_Z ww_op";
  pp "  (znz_add_mul_div ww_op (znz_sub ww_op (znz_zdigits ww_op)  yy1)";
  pp "     (znz_0 ww_op) xx1) = znz_to_Z ww1_op xx / 2 ^ znz_to_Z ww2_op yy).";
  pp "  intros ww ww1 ww2 ww_op ww1_op ww2_op xx yy xx1 yy1 Hl Hl1 Hw Hw1 Hw2 Hx Hy.";
  pp "     case (spec_to_Z Hw xx1); auto with zarith; intros HH1 HH2.";
  pp "     case (spec_to_Z Hw yy1); auto with zarith; intros HH3 HH4.";
  pp "     rewrite <- Hx.";
  pp "     rewrite <- Hy.";
  pp "     generalize (spec_add_mul_div Hw";
  pp "                  (znz_0 ww_op) xx1";
  pp "                  (znz_sub ww_op (znz_zdigits ww_op) ";
  pp "                    yy1)";
  pp "                ).";
  pp "     rewrite (spec_0 Hw).";
  pp "     rewrite Zmult_0_l; rewrite Zplus_0_l.";
  pp "     rewrite (ZnZ.spec_sub Hw).";
  pp "     rewrite Zmod_small; auto with zarith.";
  pp "     rewrite (spec_zdigits Hw).";
  pp "     rewrite F0.";
  pp "     rewrite Zmod_small; auto with zarith.";
  pp "     unfold base; rewrite (spec_zdigits Hw) in Hl1 |- *;";
  pp "      auto with zarith.";
  pp "  assert (F5: forall n m, (n <= m)%snat ->" "%";
  pp "     Zpos (znz_digits (make_op n)) <= Zpos (znz_digits (make_op m))).";
  pp "    intros n m HH; elim HH; clear m HH; auto with zarith.";
  pp "    intros m HH Hrec; apply Zle_trans with (1 := Hrec).";
  pp "    rewrite make_op_S.";
  pp "    match goal with |- Zpos ?Y <= ?X => change X with (Zpos (xO Y)) end.";
  pp "    rewrite Zpos_xO.";
  pp "    assert (0 <= Zpos (znz_digits (make_op n))); auto with zarith.";
  pp "  assert (F6: forall n, Zpos (znz_digits w%i_op) <= Zpos (znz_digits (make_op n)))." size;
  pp "    intros n ; apply Zle_trans with (Zpos (znz_digits (make_op 0))).";
  pp "    change (znz_digits (make_op 0)) with (xO (znz_digits w%i_op))." size;
  pp "    rewrite Zpos_xO.";
  pp "    assert (0 <= Zpos (znz_digits w%i_op)); auto with zarith." size;
  pp "    apply F5; auto with arith.";
  pp "  intros x; case x; clear x; unfold shiftr, same_level.";
  for i = 0 to size do
    pp "    intros x y; case y; clear y.";
    for j = 0 to i - 1 do
      pp "     intros y; unfold shiftr%i, Ndigits." i;
      pp "       repeat rewrite spec_reduce_%i; repeat rewrite spec_reduce_%i; unfold to_Z; intros H1." i j;
      pp "       apply F4 with (3:=w%i_spec)(4:=w%i_spec)(5:=w%i_spec); auto with zarith." i j i;
      pp "       rewrite (spec_zdigits w%i_spec)." i;
      pp "       rewrite (spec_zdigits w%i_spec)." j;
      pp "       change (znz_digits w%i_op) with %s." i (genxO (i - j) (" (znz_digits w"^(string_of_int j)^"_op)"));
      pp "       repeat rewrite (fun x => Zpos_xO (xO x)).";
      pp "       repeat rewrite (fun x y => Zpos_xO (@znz_digits x y)).";
      pp "       assert (0 <= Zpos (znz_digits w%i_op)); auto with zarith." j;
      pp "       try (apply sym_equal; exact (spec_extend%in%i y))." j i;

    done;
    pp "     intros y; unfold shiftr%i, Ndigits." i;
    pp "     repeat rewrite spec_reduce_%i; unfold to_Z; intros H1." i;
    pp "       apply F4 with (3:=w%i_spec)(4:=w%i_spec)(5:=w%i_spec); auto with zarith." i i i;
    for j = i + 1 to size do
      pp "     intros y; unfold shiftr%i, Ndigits." j;
      pp "       repeat rewrite spec_reduce_%i; repeat rewrite spec_reduce_%i; unfold to_Z; intros H1." i j;
      pp "       apply F4 with (3:=w%i_spec)(4:=w%i_spec)(5:=w%i_spec); auto with zarith." j j i;
      pp "       try (apply sym_equal; exact (spec_extend%in%i x))." i j;
    done;
    if i == size then
      begin
        pp "     intros m y; unfold shiftrn, Ndigits.";
        pp "       repeat rewrite spec_reduce_n; unfold to_Z; intros H1.";
        pp "       apply F4 with (3:=(wn_spec m))(4:=wn_spec m)(5:=w%i_spec); auto with zarith." size;
        pp "       try (apply sym_equal; exact (spec_extend%in m x))." size;
      end
    else 
      begin
        pp "     intros m y; unfold shiftrn, Ndigits.";
        pp "       repeat rewrite spec_reduce_n; unfold to_Z; intros H1.";
        pp "       apply F4 with (3:=(wn_spec m))(4:=wn_spec m)(5:=w%i_spec); auto with zarith." i;
        pp "       change ([Nn m (extend%i m (extend%i %i x))] = [N%i x])." size i (size - i - 1) i;
        pp "       rewrite <- (spec_extend%in m); rewrite <- spec_extend%in%i; auto." size i size;
      end
  done;
  pp "    intros n x y; case y; clear y;";
  pp "     intros y; unfold shiftrn, Ndigits; try rewrite spec_reduce_n.";
  for i = 0 to size do
    pp "     try rewrite spec_reduce_%i; unfold to_Z; intros H1." i;
    pp "       apply F4 with (3:=(wn_spec n))(4:=w%i_spec)(5:=wn_spec n); auto with zarith." i;
    pp "       rewrite (spec_zdigits w%i_spec)." i;
    pp "       rewrite (spec_zdigits (wn_spec n)).";
    pp "       apply Zle_trans with (2 := F6 n).";
    pp "       change (znz_digits w%i_op) with %s." size (genxO (size - i) ("(znz_digits w" ^ (string_of_int i) ^ "_op)"));
    pp "       repeat rewrite (fun x => Zpos_xO (xO x)).";
    pp "       repeat rewrite (fun x y => Zpos_xO (@znz_digits x y)).";
    pp "       assert (H: 0 <= Zpos (znz_digits w%i_op)); auto with zarith." i;
    if i == size then
      pp "       change ([Nn n (extend%i n y)] = [N%i y])." size i
    else
      pp "       change ([Nn n (extend%i n (extend%i %i y))] = [N%i y])." size i (size - i - 1) i;
    pp "       rewrite <- (spec_extend%in n); auto." size;
    if i <> size then
      pp "       try (rewrite <- spec_extend%in%i; auto)." i size;
  done;
  pp "     generalize y; clear y; intros m y.";
  pp "     rewrite spec_reduce_n; unfold to_Z; intros H1.";
  pp "       apply F4 with (3:=(wn_spec (Max.max n m)))(4:=wn_spec m)(5:=wn_spec n); auto with zarith.";
  pp "     rewrite (spec_zdigits (wn_spec m)).";
  pp "     rewrite (spec_zdigits (wn_spec (Max.max n m))).";
  pp "     apply F5; auto with arith.";
  pp "     exact (spec_cast_r n m y).";
  pp "     exact (spec_cast_l n m x).";
  pp " Qed.";
  pr "";

  pr " Definition safe_shiftr n x := ";
  pr "   match compare n (Ndigits x) with";
  pr "   |  Lt => shiftr n x ";
  pr "   | _ => %s0 w_0" c;
  pr "   end.";
  pr "";


  pr " Theorem spec_safe_shiftr: forall n x,";
  pr "   [safe_shiftr n x] = [x] / 2 ^ [n].";
  pa " Admitted.";
  pp " Proof.";
  pp " intros n x; unfold safe_shiftr;";
  pp "    generalize (spec_compare n (Ndigits x)); case compare; intros H.";
  pp " apply trans_equal with (1 := spec_0 w0_spec).";
  pp " apply sym_equal; apply Zdiv_small; rewrite H.";
  pp " rewrite spec_Ndigits; exact (spec_digits x).";
  pp " rewrite <- spec_shiftr; auto with zarith.";
  pp " apply trans_equal with (1 := spec_0 w0_spec).";
  pp " apply sym_equal; apply Zdiv_small.";
  pp " rewrite spec_Ndigits in H; case (spec_digits x); intros H1 H2.";
  pp " split; auto.";
  pp " apply Zlt_le_trans with (1 := H2).";
  pp " apply Zpower_le_monotone; auto with zarith.";
  pp " Qed.";
  pr "";

  pr "";

  (* Shiftl *)
  for i = 0 to size do
    pr " Definition shiftl%i n x := w%i_op.(znz_add_mul_div) n x w%i_op.(znz_0)." i i i
  done;
  pr " Definition shiftln n p x := (make_op n).(znz_add_mul_div) p x (make_op n).(znz_0).";
  pr " Definition shiftl := Eval lazy beta delta [same_level] in";
  pr "    same_level _ (fun n x => %s0 (shiftl0 n x))" c;
  for i = 1 to size do
    pr "           (fun n x => reduce_%i (shiftl%i n x))" i i;
  done;
  pr "           (fun n p x => reduce_n n (shiftln n p x)).";
  pr "";
  pr "";


  pr " Theorem spec_shiftl: forall n x,";
  pr "  [n] <= [head0 x] -> [shiftl n x] = [x] * 2 ^ [n].";
  pa " Admitted.";
  pp " Proof.";
  pp " assert (F0: forall x y, x - (x - y) = y).";
  pp "   intros; ring.";
  pp " assert (F2: forall x y z, 0 <= x -> 0 <= y -> x < z -> 0 <= x / 2 ^ y < z).";
  pp "   intros x y z HH HH1 HH2.";
  pp "   split; auto with zarith.";
  pp "   apply Zle_lt_trans with (2 := HH2); auto with zarith.";
  pp "   apply Zdiv_le_upper_bound; auto with zarith.";
  pp "   pattern x at 1; replace x with (x * 2 ^ 0); auto with zarith.";
  pp "   apply Zmult_le_compat_l; auto.";
  pp "   apply Zpower_le_monotone; auto with zarith.";
  pp "   rewrite Zpower_0_r; ring.";
  pp "  assert (F3: forall x y, 0 <= y -> y <= x -> 0 <= x - y < 2 ^ x).";
  pp "    intros xx y HH HH1.";
  pp "    split; auto with zarith.";
  pp "    apply Zle_lt_trans with xx; auto with zarith.";
  pp "    apply Zpower2_lt_lin; auto with zarith.";
  pp "  assert (F4: forall ww ww1 ww2 ";
  pp "         (ww_op: znz_op ww) (ww1_op: znz_op ww1) (ww2_op: znz_op ww2)";
  pp "           xx yy xx1 yy1,";
  pp "  znz_to_Z ww2_op yy <= znz_to_Z ww1_op (znz_head0 ww1_op xx) ->";
  pp "  znz_to_Z ww1_op (znz_zdigits ww1_op) <= znz_to_Z ww_op (znz_zdigits ww_op) ->";
  pp "  znz_spec ww_op -> znz_spec ww1_op -> znz_spec ww2_op ->";
  pp "  znz_to_Z ww_op xx1 = znz_to_Z ww1_op xx ->";
  pp "  znz_to_Z ww_op yy1 = znz_to_Z ww2_op yy ->";
  pp "  znz_to_Z ww_op";
  pp "  (znz_add_mul_div ww_op yy1";
  pp "     xx1 (znz_0 ww_op)) = znz_to_Z ww1_op xx * 2 ^ znz_to_Z ww2_op yy).";
  pp "  intros ww ww1 ww2 ww_op ww1_op ww2_op xx yy xx1 yy1 Hl Hl1 Hw Hw1 Hw2 Hx Hy.";
  pp "     case (spec_to_Z Hw xx1); auto with zarith; intros HH1 HH2.";
  pp "     case (spec_to_Z Hw yy1); auto with zarith; intros HH3 HH4.";
  pp "     rewrite <- Hx.";
  pp "     rewrite <- Hy.";
  pp "     generalize (spec_add_mul_div Hw xx1 (znz_0 ww_op) yy1).";
  pp "     rewrite (spec_0 Hw).";
  pp "     assert (F1: znz_to_Z ww1_op (znz_head0 ww1_op xx) <= Zpos (znz_digits ww1_op)).";
  pp "     case (Zle_lt_or_eq _ _ HH1); intros HH5.";
  pp "     apply Zlt_le_weak.";
  pp "     case (ZnZ.spec_head0 Hw1 xx).";
  pp "       rewrite <- Hx; auto.";
  pp "     intros _ Hu; unfold base in Hu.";
  pp "     case (Zle_or_lt (Zpos (znz_digits ww1_op))";
  pp "                     (znz_to_Z ww1_op (znz_head0 ww1_op xx))); auto; intros H1.";
  pp "     absurd (2 ^  (Zpos (znz_digits ww1_op)) <= 2 ^ (znz_to_Z ww1_op (znz_head0 ww1_op xx))).";
  pp "       apply Zlt_not_le.";
  pp "       case (spec_to_Z Hw1 xx); intros HHx3 HHx4.";
  pp "       rewrite <- (Zmult_1_r (2 ^ znz_to_Z ww1_op (znz_head0 ww1_op xx))).";
  pp "       apply Zle_lt_trans with (2 := Hu).";
  pp "       apply Zmult_le_compat_l; auto with zarith.";
  pp "     apply Zpower_le_monotone; auto with zarith.";
  pp "     rewrite (ZnZ.spec_head00 Hw1 xx); auto with zarith.";
  pp "     rewrite Zdiv_0_l; auto with zarith.";
  pp "     rewrite Zplus_0_r.";
  pp "     case (Zle_lt_or_eq _ _ HH1); intros HH5.";
  pp "     rewrite Zmod_small; auto with zarith.";
  pp "     intros HH; apply HH.";
  pp "     rewrite Hy; apply Zle_trans with (1:= Hl).";
  pp "     rewrite <- (spec_zdigits Hw). ";
  pp "     apply Zle_trans with (2 := Hl1); auto.";
  pp "     rewrite  (spec_zdigits Hw1); auto with zarith.";
  pp "     split; auto with zarith .";
  pp "     apply Zlt_le_trans with (base (znz_digits ww1_op)).";
  pp "     rewrite Hx.";
  pp "     case (ZnZ.spec_head0 Hw1 xx); auto.";
  pp "       rewrite <- Hx; auto.";
  pp "     intros _ Hu; rewrite Zmult_comm in Hu.";
  pp "     apply Zle_lt_trans with (2 := Hu).";
  pp "     apply Zmult_le_compat_l; auto with zarith.";
  pp "     apply Zpower_le_monotone; auto with zarith.";
  pp "     unfold base; apply Zpower_le_monotone; auto with zarith.";
  pp "     split; auto with zarith.";
  pp "     rewrite <- (spec_zdigits Hw); auto with zarith.";
  pp "     rewrite <- (spec_zdigits Hw1); auto with zarith.";
  pp "     rewrite <- HH5.";
  pp "     rewrite Zmult_0_l.";
  pp "     rewrite Zmod_small; auto with zarith.";
  pp "     intros HH; apply HH.";
  pp "     rewrite Hy; apply Zle_trans with (1 := Hl).";
  pp "     rewrite (ZnZ.spec_head00 Hw1 xx); auto with zarith.";
  pp "     rewrite <- (spec_zdigits Hw); auto with zarith.";
  pp "     rewrite <- (spec_zdigits Hw1); auto with zarith.";
  pp "  assert (F5: forall n m, (n <= m)%snat ->" "%";
  pp "     Zpos (znz_digits (make_op n)) <= Zpos (znz_digits (make_op m))).";
  pp "    intros n m HH; elim HH; clear m HH; auto with zarith.";
  pp "    intros m HH Hrec; apply Zle_trans with (1 := Hrec).";
  pp "    rewrite make_op_S.";
  pp "    match goal with |- Zpos ?Y <= ?X => change X with (Zpos (xO Y)) end.";
  pp "    rewrite Zpos_xO.";
  pp "    assert (0 <= Zpos (znz_digits (make_op n))); auto with zarith.";
  pp "  assert (F6: forall n, Zpos (znz_digits w%i_op) <= Zpos (znz_digits (make_op n)))." size;
  pp "    intros n ; apply Zle_trans with (Zpos (znz_digits (make_op 0))).";
  pp "    change (znz_digits (make_op 0)) with (xO (znz_digits w%i_op))." size;
  pp "    rewrite Zpos_xO.";
  pp "    assert (0 <= Zpos (znz_digits w%i_op)); auto with zarith." size;
  pp "    apply F5; auto with arith.";
  pp "  intros x; case x; clear x; unfold shiftl, same_level.";
  for i = 0 to size do
    pp "    intros x y; case y; clear y.";
    for j = 0 to i - 1 do
      pp "     intros y; unfold shiftl%i, head0." i;
      pp "       repeat rewrite spec_reduce_%i; repeat rewrite spec_reduce_%i; unfold to_Z; intros H1." i j;
      pp "       apply F4 with (3:=w%i_spec)(4:=w%i_spec)(5:=w%i_spec); auto with zarith." i j i;
      pp "       rewrite (spec_zdigits w%i_spec)." i;
      pp "       rewrite (spec_zdigits w%i_spec)." j;
      pp "       change (znz_digits w%i_op) with %s." i (genxO (i - j) (" (znz_digits w"^(string_of_int j)^"_op)"));
      pp "       repeat rewrite (fun x => Zpos_xO (xO x)).";
      pp "       repeat rewrite (fun x y => Zpos_xO (@znz_digits x y)).";
      pp "       assert (0 <= Zpos (znz_digits w%i_op)); auto with zarith." j;
      pp "       try (apply sym_equal; exact (spec_extend%in%i y))." j i;
    done;
    pp "     intros y; unfold shiftl%i, head0." i;
    pp "     repeat rewrite spec_reduce_%i; unfold to_Z; intros H1." i;
    pp "       apply F4 with (3:=w%i_spec)(4:=w%i_spec)(5:=w%i_spec); auto with zarith." i i i;
    for j = i + 1 to size do
      pp "     intros y; unfold shiftl%i, head0." j;
      pp "       repeat rewrite spec_reduce_%i; repeat rewrite spec_reduce_%i; unfold to_Z; intros H1." i j;
      pp "       apply F4 with (3:=w%i_spec)(4:=w%i_spec)(5:=w%i_spec); auto with zarith." j j i;
      pp "       try (apply sym_equal; exact (spec_extend%in%i x))." i j;
    done;
    if i == size then
      begin
        pp "     intros m y; unfold shiftln, head0.";
        pp "       repeat rewrite spec_reduce_n; unfold to_Z; intros H1.";
        pp "       apply F4 with (3:=(wn_spec m))(4:=wn_spec m)(5:=w%i_spec); auto with zarith." size;
        pp "       try (apply sym_equal; exact (spec_extend%in m x))." size;
      end
    else 
      begin
        pp "     intros m y; unfold shiftln, head0.";
        pp "       repeat rewrite spec_reduce_n; unfold to_Z; intros H1.";
        pp "       apply F4 with (3:=(wn_spec m))(4:=wn_spec m)(5:=w%i_spec); auto with zarith." i;
        pp "       change ([Nn m (extend%i m (extend%i %i x))] = [N%i x])." size i (size - i - 1) i;
        pp "       rewrite <- (spec_extend%in m); rewrite <- spec_extend%in%i; auto." size i size;
      end
  done;
  pp "    intros n x y; case y; clear y;";
  pp "     intros y; unfold shiftln, head0; try rewrite spec_reduce_n.";
  for i = 0 to size do
    pp "     try rewrite spec_reduce_%i; unfold to_Z; intros H1." i;
    pp "       apply F4 with (3:=(wn_spec n))(4:=w%i_spec)(5:=wn_spec n); auto with zarith." i;
    pp "       rewrite (spec_zdigits w%i_spec)." i;
    pp "       rewrite (spec_zdigits (wn_spec n)).";
    pp "       apply Zle_trans with (2 := F6 n).";
    pp "       change (znz_digits w%i_op) with %s." size (genxO (size - i) ("(znz_digits w" ^ (string_of_int i) ^ "_op)"));
    pp "       repeat rewrite (fun x => Zpos_xO (xO x)).";
    pp "       repeat rewrite (fun x y => Zpos_xO (@znz_digits x y)).";
    pp "       assert (H: 0 <= Zpos (znz_digits w%i_op)); auto with zarith." i;
    if i == size then
      pp "       change ([Nn n (extend%i n y)] = [N%i y])." size i
    else
      pp "       change ([Nn n (extend%i n (extend%i %i y))] = [N%i y])." size i (size - i - 1) i;
    pp "       rewrite <- (spec_extend%in n); auto." size;
    if i <> size then
      pp "       try (rewrite <- spec_extend%in%i; auto)." i size;
  done;
  pp "     generalize y; clear y; intros m y.";
  pp "     repeat rewrite spec_reduce_n; unfold to_Z; intros H1.";
  pp "       apply F4 with (3:=(wn_spec (Max.max n m)))(4:=wn_spec m)(5:=wn_spec n); auto with zarith.";
  pp "     rewrite (spec_zdigits (wn_spec m)).";
  pp "     rewrite (spec_zdigits (wn_spec (Max.max n m))).";
  pp "     apply F5; auto with arith.";
  pp "     exact (spec_cast_r n m y).";
  pp "     exact (spec_cast_l n m x).";
  pp " Qed.";
  pr "";

  (* Double size *)
  pr " Definition double_size w := match w with";
  for i = 0 to size-1 do
    pr " | %s%i x => %s%i (WW (znz_0 w%i_op) x)" c i c (i + 1) i;
  done;
  pr " | %s%i x => %sn 0 (WW (znz_0 w%i_op) x)" c size c size;
  pr " | %sn n x => %sn (S n) (WW (znz_0 (make_op n)) x)" c c;
  pr " end.";
  pr "";

  pr " Theorem spec_double_size_digits: ";
  pr "   forall x, digits (double_size x) = xO (digits x).";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x; case x; unfold double_size, digits; clear x; auto.";
  pp " intros n x; rewrite make_op_S; auto.";
  pp " Qed.";
  pr "";


  pr " Theorem spec_double_size: forall x, [double_size x] = [x].";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x; case x; unfold double_size; clear x.";
  for i = 0 to size do
    pp "   intros x; unfold to_Z, make_op; ";
    pp "     rewrite znz_to_Z_%i; rewrite (spec_0 w%i_spec); auto with zarith." (i + 1) i;
  done;
  pp "   intros n x; unfold to_Z;";
  pp "     generalize (znz_to_Z_n n); simpl word.";
  pp "     intros HH; rewrite HH; clear HH.";
  pp "     generalize (spec_0 (wn_spec n)); simpl word.";
  pp "     intros HH; rewrite HH; clear HH; auto with zarith.";
  pp " Qed.";
  pr "";


  pr " Theorem spec_double_size_head0: ";
  pr "   forall x, 2 * [head0 x] <= [head0 (double_size x)].";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x.";
  pp " assert (F1:= spec_pos (head0 x)).";
  pp " assert (F2: 0 < Zpos (digits x)).";
  pp "   red; auto.";
  pp " case (Zle_lt_or_eq _ _ (spec_pos x)); intros HH.";
  pp " generalize HH; rewrite <- (spec_double_size x); intros HH1.";
  pp " case (spec_head0 x HH); intros _ HH2.";
  pp " case (spec_head0 _ HH1).";
  pp " rewrite (spec_double_size x); rewrite (spec_double_size_digits x).";
  pp " intros HH3 _.";
  pp " case (Zle_or_lt ([head0 (double_size x)]) (2 * [head0 x])); auto; intros HH4.";
  pp " absurd (2 ^ (2 * [head0 x] )* [x] < 2 ^ [head0 (double_size x)] * [x]); auto.";
  pp " apply Zle_not_lt.";
  pp " apply Zmult_le_compat_r; auto with zarith.";
  pp " apply Zpower_le_monotone; auto; auto with zarith.";
  pp " generalize (spec_pos (head0 (double_size x))); auto with zarith.";
  pp " assert (HH5: 2 ^[head0 x] <= 2 ^(Zpos (digits x) - 1)).";
  pp "   case (Zle_lt_or_eq 1 [x]); auto with zarith; intros HH5.";
  pp "   apply Zmult_le_reg_r with (2 ^ 1); auto with zarith.";
  pp "   rewrite <- (fun x y z => Zpower_exp x (y - z)); auto with zarith.";
  pp "   assert (tmp: forall x, x - 1 + 1 = x); [intros; ring | rewrite tmp; clear tmp].";
  pp "   apply Zle_trans with (2 := Zlt_le_weak _ _ HH2).";
  pp "   apply Zmult_le_compat_l; auto with zarith.";
  pp "   rewrite Zpower_1_r; auto with zarith.";
  pp "   apply Zpower_le_monotone; auto with zarith.";
  pp "   split; auto with zarith. ";
  pp "   case (Zle_or_lt (Zpos (digits x)) [head0 x]); auto with zarith; intros HH6.";
  pp "   absurd (2 ^ Zpos (digits x) <= 2 ^ [head0 x] * [x]); auto with zarith.";
  pp "   rewrite <- HH5; rewrite Zmult_1_r.";
  pp "   apply Zpower_le_monotone; auto with zarith.";
  pp " rewrite (Zmult_comm 2).";
  pp " rewrite Zpower_mult; auto with zarith.";
  pp " rewrite Zpower_2.";
  pp " apply Zlt_le_trans with (2 := HH3).";
  pp " rewrite <- Zmult_assoc.";
  pp " replace (Zpos (xO (digits x)) - 1) with";
  pp "   ((Zpos (digits x) - 1) + (Zpos (digits x))).";
  pp " rewrite Zpower_exp; auto with zarith.";
  pp " apply Zmult_lt_compat2; auto with zarith.";
  pp " split; auto with zarith.";
  pp " apply Zmult_lt_0_compat; auto with zarith.";
  pp " rewrite Zpos_xO; ring.";
  pp " apply Zlt_le_weak; auto.";
  pp " repeat rewrite spec_head00; auto.";
  pp " rewrite spec_double_size_digits.";
  pp " rewrite Zpos_xO; auto with zarith.";
  pp " rewrite spec_double_size; auto.";
  pp " Qed.";
  pr "";

  pr " Theorem spec_double_size_head0_pos: ";
  pr "   forall x, 0 < [head0 (double_size x)].";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x.";
  pp " assert (F: 0 < Zpos (digits x)).";
  pp "  red; auto.";
  pp " case (Zle_lt_or_eq _ _ (spec_pos (head0 (double_size x)))); auto; intros F0.";
  pp " case (Zle_lt_or_eq _ _ (spec_pos (head0 x))); intros F1.";
  pp "   apply Zlt_le_trans with (2 := (spec_double_size_head0 x)); auto with zarith.";
  pp " case (Zle_lt_or_eq _ _ (spec_pos x)); intros F3.";
  pp " generalize F3; rewrite <- (spec_double_size x); intros F4.";
  pp " absurd (2 ^ (Zpos (xO (digits x)) - 1) < 2 ^ (Zpos (digits x))).";
  pp "   apply Zle_not_lt.";
  pp "   apply Zpower_le_monotone; auto with zarith.";
  pp "   split; auto with zarith.";
  pp "   rewrite Zpos_xO; auto with zarith.";
  pp " case (spec_head0 x F3).";
  pp " rewrite <- F1; rewrite Zpower_0_r; rewrite Zmult_1_l; intros _ HH.";
  pp " apply Zle_lt_trans with (2 := HH).";
  pp " case (spec_head0 _ F4).";
  pp " rewrite (spec_double_size x); rewrite (spec_double_size_digits x).";
  pp " rewrite <- F0; rewrite Zpower_0_r; rewrite Zmult_1_l; auto.";
  pp " generalize F1; rewrite (spec_head00 _ (sym_equal F3)); auto with zarith.";
  pp " Qed.";
  pr "";


  (* Safe shiftl *)

  pr " Definition safe_shiftl_aux_body cont n x :=";
  pr "   match compare n (head0 x)  with";
  pr "      Gt => cont n (double_size x)";
  pr "   |  _ => shiftl n x";
  pr "   end.";
  pr "";

  pr " Theorem spec_safe_shift_aux_body: forall n p x cont,";
  pr "       2^ Zpos p  <=  [head0 x]  ->";
  pr "      (forall x, 2 ^ (Zpos p + 1) <= [head0 x]->";
  pr "         [cont n x] = [x] * 2 ^ [n]) ->";
  pr "      [safe_shiftl_aux_body cont n x] = [x] * 2 ^ [n].";
  pa " Admitted.";  
  pp " Proof.";
  pp " intros n p x cont H1 H2; unfold safe_shiftl_aux_body.";
  pp " generalize (spec_compare n (head0 x)); case compare; intros H.";
  pp "  apply spec_shiftl; auto with zarith.";
  pp "  apply spec_shiftl; auto with zarith.";
  pp " rewrite H2.";
  pp " rewrite spec_double_size; auto.";
  pp " rewrite Zplus_comm; rewrite Zpower_exp; auto with zarith.";
  pp " apply Zle_trans with (2 := spec_double_size_head0 x).";
  pp " rewrite Zpower_1_r; apply Zmult_le_compat_l; auto with zarith.";
  pp " Qed.";
  pr "";

  pr " Fixpoint safe_shiftl_aux p cont n x  {struct p} :=";
  pr "   safe_shiftl_aux_body ";
  pr "       (fun n x => match p with";
  pr "        | xH => cont n x";
  pr "        | xO p => safe_shiftl_aux p (safe_shiftl_aux p cont) n x";
  pr "        | xI p => safe_shiftl_aux p (safe_shiftl_aux p cont) n x";
  pr "        end) n x.";
  pr "";

  pr " Theorem spec_safe_shift_aux: forall p q n x cont,";
  pr "    2 ^ (Zpos q) <= [head0 x] ->";
  pr "      (forall x, 2 ^ (Zpos p + Zpos q) <= [head0 x] ->";
  pr "         [cont n x] = [x] * 2 ^ [n]) ->      ";
  pr "      [safe_shiftl_aux p cont n x] = [x] * 2 ^ [n].";
  pa " Admitted.";
  pp " Proof.";
  pp " intros p; elim p; unfold safe_shiftl_aux; fold safe_shiftl_aux; clear p.";
  pp " intros p Hrec q n x cont H1 H2.";
  pp " apply spec_safe_shift_aux_body with (q); auto.";
  pp " intros x1 H3; apply Hrec with (q + 1)%spositive; auto." "%";
  pp " intros x2 H4; apply Hrec with (p + q + 1)%spositive; auto." "%";
  pp " rewrite <- Pplus_assoc.";
  pp " rewrite Zpos_plus_distr; auto.";
  pp " intros x3 H5; apply H2.";
  pp " rewrite Zpos_xI.";
  pp " replace (2 * Zpos p + 1 + Zpos q) with (Zpos p + Zpos (p + q + 1));";
  pp "   auto.";
  pp " repeat rewrite Zpos_plus_distr; ring.";
  pp " intros p Hrec q n x cont H1 H2.";
  pp " apply spec_safe_shift_aux_body with (q); auto.";
  pp " intros x1 H3; apply Hrec with (q); auto.";
  pp " apply Zle_trans with (2 := H3); auto with zarith.";
  pp " apply Zpower_le_monotone; auto with zarith.";
  pp " intros x2 H4; apply Hrec with (p + q)%spositive; auto." "%";
  pp " intros x3 H5; apply H2.";
  pp " rewrite (Zpos_xO p).";
  pp " replace (2 * Zpos p + Zpos q) with (Zpos p + Zpos (p + q));";
  pp "   auto.";
  pp " repeat rewrite Zpos_plus_distr; ring.";
  pp " intros q n x cont H1 H2.";
  pp " apply spec_safe_shift_aux_body with (q); auto.";
  pp " rewrite Zplus_comm; auto.";
  pp " Qed.";
  pr "";


  pr " Definition safe_shiftl n x :=";
  pr "  safe_shiftl_aux_body";
  pr "   (safe_shiftl_aux_body";
  pr "    (safe_shiftl_aux (digits n) shiftl)) n x.";
  pr "";

  pr " Theorem spec_safe_shift: forall n x,";
  pr "   [safe_shiftl n x] = [x] * 2 ^ [n].";
  pa " Admitted.";
  pp " Proof.";
  pp " intros n x; unfold safe_shiftl, safe_shiftl_aux_body.";
  pp " generalize (spec_compare n (head0 x)); case compare; intros H.";
  pp "  apply spec_shiftl; auto with zarith.";
  pp "  apply spec_shiftl; auto with zarith.";
  pp " rewrite <- (spec_double_size x).";
  pp " generalize (spec_compare n (head0 (double_size x))); case compare; intros H1.";
  pp "  apply spec_shiftl; auto with zarith.";
  pp "  apply spec_shiftl; auto with zarith.";
  pp " rewrite <- (spec_double_size (double_size x)).";
  pp " apply spec_safe_shift_aux with 1%spositive." "%";
  pp " apply Zle_trans with (2 := spec_double_size_head0 (double_size x)).";
  pp " replace (2 ^ 1) with (2 * 1).";
  pp " apply Zmult_le_compat_l; auto with zarith.";
  pp " generalize (spec_double_size_head0_pos x); auto with zarith.";
  pp " rewrite Zpower_1_r; ring.";
  pp " intros x1 H2; apply spec_shiftl.";
  pp " apply Zle_trans with (2 := H2).";
  pp " apply Zle_trans with (2 ^ Zpos (digits n)); auto with zarith.";
  pp " case (spec_digits n); auto with zarith.";
  pp " apply Zpower_le_monotone; auto with zarith.";
  pp " Qed.";
  pr "";

  (* even *)
  pr " Definition is_even x :=";
  pr "  match x with";
  for i = 0 to size do
    pr "  | %s%i wx => w%i_op.(znz_is_even) wx" c i i
  done;
  pr "  | %sn n wx => (make_op n).(znz_is_even) wx" c;
  pr "  end.";
  pr "";


  pr " Theorem spec_is_even: forall x,";
  pr "   if is_even x then [x] mod 2 = 0 else [x] mod 2 = 1.";
  pa " Admitted.";
  pp " Proof.";
  pp " intros x; case x; unfold is_even, to_Z; clear x.";
  for i = 0 to size do
    pp "   intros x; exact (spec_is_even w%i_spec x)." i;
  done;
  pp "  intros n x; exact (spec_is_even (wn_spec n) x).";
  pp " Qed.";
  pr "";

  pr " Theorem spec_0: [zero] = 0.";
  pa " Admitted.";
  pp " Proof.";
  pp " exact (spec_0 w0_spec).";
  pp " Qed.";
  pr "";

  pr " Theorem spec_1: [one] = 1.";
  pa " Admitted.";
  pp " Proof.";
  pp " exact (spec_1 w0_spec).";
  pp " Qed.";
  pr "";

  pr "End Make.";
  pr "";

