function [data limits] = SpaceshipParadox(varargin)
  opts = {};
  opts = [opts 'name = ''Spaceship Paradox'''];
  opts = [opts 'labels{1}=''Bow of Tail Ship'''];
  opts = [opts 'labels{2}=''Stern of Lead Ship'''];

  opts = [opts 'vo = 0'];
  opts = [opts 'step = 0.1'];
  opts = [opts 'res = 0.001'];
  opts = [opts 'gal = false'];
  opts = [opts 'rs = 0'];
  opts = [opts 'alt = false;'];
  opts = [opts 'nochart = false;'];
  opts = [opts 'nochart = false'];  
  opts = [opts 'los'];

  opts = [opts 'v(1) = 0.4'];
  opts = [opts 'v(2) = v(1)'];

  opts = [opts 'x(1) = -v(1) / 2'];
  opts = [opts 'x(2) = 0;'];
  
  opts = [opts 'limits = [x(1)-0.1 x(2)+v(2)/2+0.1 -0.1 0.45]'];
  opts = [opts 'coda = 0.5'];
  opts = [opts 'showage = false'];

  opts = [opts varargin];

  % Pocess arguments
  for i=1:numel(opts)
    arg = opts{i};
    if isempty(strfind(arg,'='))
      arg = [arg '=true'];
    endif
    eval([arg ';'])
  endfor

  [data limits]= minkowskiChart(opts{:});

  if nochart == false && gal == false
    plotShockwaves(v, x, vo, res)
  endif
endfunction