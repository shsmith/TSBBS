const
   queue_size       = 3000;   {fixed size of all queues}
   queue_high_water = 2700;   {maximum queue.count before blocking}
   queue_low_water  = 2400;   {unblock queue at this point}

type
   queue_rec = record
      next_in:  integer;
      next_out: integer;
      count:    integer;
      data:     array[1..queue_size] of char;
   end;
