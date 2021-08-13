function [data limits] = minkowskiChart(varargin)
  data = {};
  limits = [];
  
  if isempty(varargin)
    showHelp
    return
  endif

  % Initialize options
  opts = {};
  opts = [opts 'v = []'];
  opts = [opts 'x = []'];
  opts = [opts 't = []'];
  opts = [opts 'light = false'];
  opts = [opts 'los = false'];
  opts = [opts 'incoming = true'];
  opts = [opts 'showage = true'];
  opts = [opts 'outgoing = true'];
  opts = [opts 'shockwaves = false'];
  opts = [opts 'gal = false'];
  opts = [opts 'xs = 1'];
  opts = [opts 'rs = 0'];
  opts = [opts 'alt = false'];
  opts = [opts 'vo = 0'];
  opts = [opts 'nolegend = false'];
  opts = [opts 'nochart = false'];
  opts = [opts 'name = '''''];
  opts = [opts 'labels = {}'];
  opts = [opts 'minor = false'];
  opts = [opts 'limits = []'];
  opts = [opts 'res = 0.001'];
  opts = [opts 'step = 0.1'];
  opts = [opts 'colors = ''gcmykrb'''];
  opts = [opts varargin];

  % Process arguments
  for i=1:numel(opts)
    arg = opts{i};
    if isempty(strfind(arg,'='))
      arg = [arg '=true'];
    endif
    eval([arg ';'])
  endfor

  if gal
    name = [name ' (Galilean)'];
  endif

  % Check for errors
  invalid = find(abs(v) >= 1);
  if gal == false && isempty(invalid) == false
    error('Cosmic speed limit exceeded')
  endif

  if rs < 0
    error(['Invalid Schwarzschild radious (rs=' num2str(rs) ')'])
  endif

  if rs > 0 && gal
    error('gal not supported for rs>0')
  endif

  if rs > 0 && vo != 0
    error('vo!=0 not supported for rs>0')
  endif
  
  % Calculate worldlines and metadata
  if isempty(v) == false && isvector(v) == false
    v = [v];
  endif

  if isempty(x) == false && isvector(x) == false
    x = [x];
  endif

  n = max([numel(v) numel(x)]);
  data = {};
  for i=1:n
    if isempty(v) || i > numel(v)
      v(i) = 0;
    endif

    if isempty(x) || i > numel(x)
      x(i) = 0;
    endif

    if isempty(t) || i > numel(t)
      t(i) = 0;
    endif

    data{i} = zigzag( v(i), x(i), t(i), gal, step, res);
    data{i} = boostData( data{i}, vo, xs, rs, gal, alt );
    data{i}.color = colors(1+mod(i-1,length(colors)));
  endfor
  
  if nochart
    return
  endif

  % Set axis limits
  if isempty(limits)
    x = [];
    t = [];
    for i=1:numel(data)
      if outgoing
        x = [x data{i}.outgoing.worldline(:,1)'];
        t = [t data{i}.outgoing.worldline(:,2)'];
      endif
      x = [x data{i}.incoming.worldline(:,1)'];
      t = [t data{i}.incoming.worldline(:,2)'];
    endfor
    limits = [min(x) max(x) max(0, min(t)) max(t)];
    if limits(1) == limits(2)
      limits(1) = -0.5;
      limits(2) = 0.5;
    endif
    if limits(3) == limits(4)
      limits(3) = 0;
      limits(4) = 1;
    endif
    center = (limits(1) + limits(2)) / 2;
    height = limits(4) - limits(3);
    limits(1) = max(-1, center - height / 2);
    limits(2) = min(1, center + height / 2);
  endif

  % Create chart
  figure, hold on, grid on
  if minor
    grid minor on
  endif

  if length(name) > 0
    if rs != 0
      name = [name ' near Black Hole'];
    endif
    if vo != 0
      name = [name ' (vo=' num2str(vo) ')'];
    endif
    name = strrep(name, ') (', ', ');
    title(name)
  endif

  xlabel ('Observer Space')
  ylabel ('Observer Time')

  if gal == false
    limits = plotMinkowskiGrid(limits,xs,rs,alt);
  endif
  axis(limits)

  % Plot data
  bystander = 0;
  traveler = 0;
  bystanders = 0;
  travelers = 0;
  for i=1:numel(data)
    bystanders = bystanders + 1;
    if data{i}.v != 0
      travelers = travelers + 1;
    endif
  endfor

  if rs > 0
    ymax = 1;
    for i=1:numel(data)
      if ymax < data{i}.incoming.worldline(end,2)
        ymax = data{i}.incoming.worldline(end,2);
      endif
    endfor
    for i=1:numel(data)
      if data{i}.v == 0
        data{i}.incoming.age *= (ymax - data{i}.incoming.worldline(1,2)) / ...
                                (data{i}.incoming.worldline(end,2) - data{i}.incoming.worldline(1,2));
        data{i}.incoming.worldline = [data{i}.incoming.worldline; [data{i}.incoming.worldline(1,1) ymax]];
        step = data{i}.incoming.ticks(end,2) - data{i}.incoming.ticks(end-1,2);
        for y=[data{i}.incoming.ticks(end,2) + step:step:ymax]
          data{i}.incoming.ticks = [data{i}.incoming.ticks; [data{i}.incoming.ticks(end,1) y]];
        endfor
      endif
    endfor
    
  endif

  for i=1:numel(data)
    for j=1:numel(data{i}.outgoing.los)
      data{i}.outgoing.los{j} = trim(data{i}.outgoing.los{j}, limits);
    endfor

    if isfield(data{i},"waypoint")
      data{i}.waypoint.los = trim(data{i}.waypoint.los, limits);
    endif

    for j=1:numel(data{i}.incoming.los)
      data{i}.incoming.los{j} = trim(data{i}.incoming.los{j}, limits);
    endfor

    plotData(data{i}, rs, light, los, limits, incoming);

    if nolegend == false
      xo = data{i}.outgoing.ticks(1,1);
      to = data{i}.outgoing.ticks(1,2);
        
      if i <= numel(labels) && length(labels{i}) > 0
        label = labels{i};
      else
        if data{i}.v == 0
          label = 'Bystander';
          if bystanders > 1
            bystander = bystander + 1;
            label = [label ' #' num2str(bystander)];
          endif
        else
          label = 'Traveler';
          if travelers > 1
            traveler = traveler + 1;
            label = [label ' #' num2str(traveler)];
          endif
        endif
      endif

      opts = data{i}.color;
      if data{i}.v != 0 || (light || los)
        opts = [opts 's-'];
      endif
      age = data{i}.outgoing.age;
      if incoming
        age += data{i}.incoming.age;
      endif
      opts = [opts ';Worldline for ' label ' (v=' num2str(data{i}.v)];
      if showage
        opts = [opts ', age=' num2str(age)];
      endif
      opts = [opts ');'];
      opts = strrep(opts, ') (', ', ');
      plot(xo, to, opts, 'linewidth', 2)

      if los && (isempty(data{i}.outgoing.los) == false || isempty(data{i}.incoming.los) == false)
        plot(xo, to, [data{i}.color '--;Lines of Simultaneity for ' label ';'])
      endif
    endif
  endfor

  % Extend legend
  if nolegend == false && numel(data) > 0
    if light
      plot(0, 0, 'r--;Red-shifted light;');
      plot(0, 0, 'b--;Blue-shifted light;');
      plot(0, 0, 'k--;Neutral light;');
    endif
    legend('location','northeastoutside')
  endif
endfunction

function showHelp
  name = 'minkowskiChart';
  disp('SYNOPSIS:')
  disp('  Calculates zigzag worldlines with proper time ticks and displays them')
  disp('  on a Minkowski spacetime diagram from the point of view of a stationary')
  disp('  or moving observer. Supports Galilean relativity, Special Relativity and')
  disp('  a Schwarzschild black hole. Optionally show lines of perceived simul-')
  disp('  taneity and/or light rays between traveler and bystander. Options such')
  disp('  initial velocities and initial positions can be specified as string variables.')
  disp('USAGE:')
  disp(['  [data limits] = ' name '(OPTIONS)'])
  disp('OPTIONS:')
  disp('  v = array of initial velocities. (e.g. ''v=[-0.6 0.6]'')')
  disp('  x = array of initial positions. (e.g. ''x=[-0.1 0.1]'')')
  disp('  vo = observer velocity')
  disp('  light = plot light rays between traveler and bystander')
  disp('  los = plot lines of simultenity through time ticks')
  disp('  rs = Schwarzschild radius for singularity at x=1')
  disp('  alt = use alternate Schwarzschild metric')
  disp('  gal = use Galilean relativity')
  disp('  step = time tick interval')
  disp('  res = plot resolution')
  disp('  nolegend = hide legend')
  disp('  colors = array of 1-character color codes')
  disp('  limits = [xmin xmax tmin tmax]');
  disp('RETURNS:')
  disp('  data = cell array of structures with ages, worldlines, time ticks, etc.')
  disp('  limits = [xmin xmax tmin tmax]');
  disp('NOTES:')
  disp('  1. Natural units (i.e. c=1)')
  disp('  2. Worldlines are zigzags with waypoints at t+0.5')
  disp('  3. Options are specified as ''tag'' or ''tag=value''')
  disp('  4. Tags without values are evaluated as ''tag=true''')
  disp('  5. Quotes within options must be escaped (e.g. ''name="My Chart"'')')
  disp('  6. Observer resides in flat space-time')
  disp('EXAMPLES:')
  disp(['  [data limits] = ' name '(''v=0.6'',''light'');'])
  disp(['  [data limits] = ' name '(''v=[-0.6 0.6]'');'])
  disp(['  [data limits] = ' name '(''los'');'])
  disp(['  [data limits] = ' name '(''v=[0 0.6]'',''vo=(1-sqrt(1-v(2)^2))/v(2)'',''los'');'])
endfunction