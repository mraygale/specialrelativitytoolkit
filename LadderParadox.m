function [data limits] = LadderParadox(varargin)
  opts = {};
  opts = [opts 'name = ''Ladder Paradox'''];
  opts = [opts 'labels{1} = ''Tail of Ladder'''];
  opts = [opts 'labels{2} = ''Head of Ladder'''];
  opts = [opts 'labels{3} = ''Front Door (Open)'''];
  opts = [opts 'labels{4} = ''Back Door (Closed)'''];

  opts = [opts 'v(1) = 0.4'];
  opts = [opts 'v(2) = v(1)'];
  opts = [opts 'v(3) = 0'];
  opts = [opts 'v(4) = 0'];

  opts = [opts 'x(1) = -v(1) / 2'];
  opts = [opts 'x(2) = 0'];
  opts = [opts 'x(4) = v(2) / 2'];
  opts = [opts 'x(3) = x(4) - x(2) + x(1)'];
  opts = [opts 't = [0 0 0 0]'];

  opts = [opts 'nochart = false'];
  opts = [opts 'showage = false'];
  opts = [opts 'incoming = false'];
  opts = [opts 'los'];
  opts = [opts 'gal = false'];  
  opts = [opts 'vo = 0'];  
  opts = [opts 'res = 0.001'];
  opts = [opts 'minor'];
  opts = [opts 'colors = ''gbcmykr'''];
  opts = [opts 'limits = [-0.25 0.25 0 0.5]'];
  opts = [opts varargin];

  % Process arguments
  for i=1:numel(opts)
    arg = opts{i};
    if isempty(strfind(arg,'='))
      arg = [arg '=true'];
    endif
    eval([arg ';'])
  endfor

  [data limits] = minkowskiChart(opts{:});

  if nochart == false && gal == false
    plotShockwaves(v, x, t, vo, res)
  endif
endfunction