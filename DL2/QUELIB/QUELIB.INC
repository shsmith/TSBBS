
(*
 * Copyright 1987, 1989 Samuel H. Smith;  All rights reserved
 *
 * This is a component of the ProDoor System.
 * Do not distribute modified versions without my permission.
 * Do not remove or alter this notice or any other copyright notice.
 * If you use this in your own program you must distribute source code.
 * Do not use any of this in a commercial product.
 *
 *)

(*
 * quelib.inc - Circular Queue library (3-1-89)
 *
 *)


(*
 * INIT_QUE(queue)
 *
 *)

procedure init_que( var q: queue_rec);
begin
   q.next_in := 1;
   q.next_out := 1;
   q.count := 0;
end;


(*
 * EMPTY_QUE(queue): boolean
 *
 *)

function empty_que( var q: queue_rec ): boolean;
begin
   empty_que := q.count = 0;
end;


(*
 * QUE_FREE(queue): integer
 *
 *)

function que_free (var q: queue_rec): integer;
begin
   que_free := queue_size - q.count;
end;


(*
 * ENQUE(queue, char)
 *
 *)

procedure enque (var q: queue_rec; c: char);
begin
   inc(q.count);
   q.data[q.next_in] := c;
   if q.next_in < queue_size then
      inc(q.next_in)
   else
      q.next_in := 1;
end;


(*
 * DEQUE(queue,dest)
 *    (EMPTY_QUE check is required before calling DEQUE)
 *
 *)

procedure deque (var q: queue_rec; var c: char);
begin
   c := q.data[q.next_out];
   if q.next_out < queue_size then
      inc(q.next_out)
   else
      q.next_out := 1;
   dec(q.count);
end;

