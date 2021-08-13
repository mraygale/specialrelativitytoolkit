function result = segmentate(x1, t1, x2, t2, res)
  result = [];
  if x1 == x2 && t1 == t2
    return
  elseif abs(x2 - x1) < abs(t2 - t1)
    t = t1:sign(t2-t1)*res:t2;
    x = x1 + (x2 - x1) * (t - t1) / (t2 - t1);
  else
    x = x1:sign(x2-x1)*res:x2;
    t = t1 + (t2 - t1) * (x - x1) / (x2 - x1);
  endif
  result = cat(2, x', t');
  if x(end) != x2 || t(end) != t2
    result = [result; [x2 t2]];
  endif
endfunction  
