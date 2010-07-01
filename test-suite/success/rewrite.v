(* Check that dependent rewrite applies on arbitrary terms *)

Inductive listn : nat -> Set :=
  | niln : listn 0
  | consn : forall n : nat, nat -> listn n -> listn (S n).

Axiom
  ax :
    forall (n n' : nat) (l : listn (n + n')) (l' : listn (n' + n)),
    existS _ (n + n') l = existS _ (n' + n) l'.

Lemma lem :
 forall (n n' : nat) (l : listn (n + n')) (l' : listn (n' + n)),
 n + n' = n' + n /\ existT _ (n + n') l = existT _ (n' + n) l'.
Proof.
intros n n' l l'.
 dependent rewrite (ax n n' l l').
split; reflexivity.
Qed.

(* Used to raise an anomaly instead of an error in 8.1 *)
(* Submitted by Y. Makarov *)

Parameter N : Set.
Parameter E : N -> N -> Prop.

Axiom e : forall (A : Set) (EA : A -> A -> Prop) (a : A), EA a a.

Theorem th : forall x : N, E x x.
intro x. try rewrite e.
Abort.

(* Behavior of rewrite wrt conversion *)

Require Import Arith.

Goal forall n, 0 + n = n -> True.
intros n H.
rewrite plus_0_l in H.
Abort.

(* Rewrite dependent proofs from left-to-right *)

Lemma l1 :
  forall x y (H:x = y:>nat) (P:forall x y, x=y -> Type), P x y H -> P x y H.
intros x y H P H0.
rewrite H.
rewrite H in H0.
assumption.
Qed.

(* Rewrite dependent proofs from right-to-left *)

Lemma l2 :
  forall x y (H:x = y:>nat) (P:forall x y, x=y -> Type), P x y H -> P x y H.
intros x y H P H0.
rewrite <- H.
rewrite <- H in H0.
assumption.
Qed.

(* Check rewriting dependent proofs with non-symmetric equalities *)

Lemma l3:forall x (H:eq_true x) (P:forall x, eq_true x -> Type), P x H -> P x H.
intros x H P H0.
rewrite H.
rewrite H in H0.
assumption.
Qed.

(* Dependent rewrite *)

Require Import JMeq.

Goal forall A B (a:A) (b:B), JMeq a b -> JMeq b a -> True.  
inversion 1; (* Goal is now [JMeq a a -> True] *) dependent rewrite H3.
Undo.
intros; inversion H; dependent rewrite H4 in H0.
Undo.
intros; inversion H; dependent rewrite <- H4 in H0.
Abort.

(* Test conversion between terms with evars that both occur in K-redexes and
   are elsewhere solvable.

   This is quite an artificial example, but it used to work in 8.2.

   Since rewrite supports conversion on terms without metas, it
   was successively unifying (id 0 ?y) and 0 where ?y was not a
   meta but, because coming from a "_", an evar.

   After commit r12440 which unified the treatment of metas and
   evars, it stopped to work. Chung-Kil Hur's Heq package used
   this feature. Solved in r13...
*)

Parameter g : nat -> nat -> nat.
Definition K (x y:nat) := x.

Goal (forall y, g y (K 0 y) = 0) -> g 0 0 = 0.
intros.
rewrite (H _).
reflexivity.
Qed.

Goal (forall y, g (K 0 y) y = 0) -> g 0 0 = 0.
intros.
rewrite (H _).
reflexivity.
Qed.
