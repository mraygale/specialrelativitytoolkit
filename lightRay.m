function ray = lightRay(xo, to, x, t, v, res)
  % x + v * (ti - t) = xo +/- c * (ti - to)
  ti = (xo - x - to + v * t) / (v - 1);
  if ti <= to
    ti = (xo - x + to + v * t) / (v + 1);
  endif
  xi = x + v * (ti - t);
  ray = segmentate(xo, to, xi, ti, res);
endfunction
