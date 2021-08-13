function plotShockwaves(v, x, vo, res)
  label = ';Shockwaves (@lightspeed);';
  if numel(v) < 2
    return
  endif
  if numel(x) < 2
    x = [x zeros(1, 2 - numel(x))];
  endif

  to = [0, 0.5, 1];
  xo = x(1) + [0, v(1)*0.5, 0];
  for i=1:numel(to)
    shockwave = lightRay(xo(i), to(i), x(2), 0, 0, res);
    if isempty(shockwave) || ...
       ( 0 < shockwave(end,2) && shockwave(end,2) < 1 )
      shockwave = lightRay(xo(i), to(i), x(2), 0, v(2), res);
      if shockwave(end,2) > 0.5
        shockwave = lightRay(xo(i), to(i), x(2) + v(2), 0, -v(2), res);
      endif
    endif
    shockwave = lorentzBoost(shockwave, vo, false);
    plot(shockwave(:,1), shockwave(:,2), 'k--');
  endfor

  to = [0, 0.5, 1];
  xo = x(2) + [0, v(2)*0.5, 0];
  for i=1:numel(to)
    shockwave = lightRay(xo(i), to(i), x(1), 0, 0, res);
    if isempty(shockwave) || ...
       ( 0 < shockwave(end,2) && shockwave(end,2) < 1 )
      shockwave = lightRay(xo(i), to(i), x(1), 0, v(1), res);
      if shockwave(end,2) > 0.5
        shockwave = lightRay(xo(i), to(i), x(1) + v(1), 0, -v(1), res);
      endif
    endif
    shockwave = lorentzBoost(shockwave, vo, false);
    plot(shockwave(:,1), shockwave(:,2), ['k--' label]);
    label = '';
  endfor
endfunction
