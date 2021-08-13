function result = boostData(data, vo, xs, rs, gal, alt)  result = data;  if vo != 0    % Velocity from observer perspective    if gal == false      result.vo = result.vo / (1 - data.vo * vo);    endif    % Outgoing worldline and time ticks    result.outgoing.worldline = lorentzBoost(data.outgoing.worldline, vo, gal);    result.outgoing.ticks = lorentzBoost(data.outgoing.ticks, vo, gal);    % Light rays from bystander to outgoing leg    for i=1:numel(data.bystander.outgoing)        result.bystander.outgoing{i} = lorentzBoost(data.bystander.outgoing{i}, vo, gal);    endfor    % Light rays from outgoing leg to bystander    for i=1:numel(data.outgoing.bystander)      result.outgoing.bystander{i} = lorentzBoost(data.outgoing.bystander{i}, vo, gal);    endfor    % Lines of simultaneity for outgoing leg    for i=1:numel(data.outgoing.los)      result.outgoing.los{i} = lorentzBoost(data.outgoing.los{i}, vo, gal);    endfor    % Light ray from bystander to waypoint    if isfield(result,"bystander.waypoint")      result.bystander.waypoint = lorentzBoost(data.bystander.waypoint, vo, gal);    endif    % Light ray from waypoint to bystander    if isfield(result,"waypoint.bystander")      result.waypoint.bystander = lorentzBoost(data.waypoint.bystander, vo, gal);    endif    % Line of simultaneity at waypoint    if isfield(result,"waypoint.los")      result.waypoint.los = lorentzBoost(data.waypoint.los, vo, gal);    endif    % Incoming worldline and time ticks    result.incoming.worldline = lorentzBoost(data.incoming.worldline, vo, gal);    result.incoming.ticks = lorentzBoost(data.incoming.ticks, vo, gal);    % Light rays from bystander to incoming leg    for i=1:numel(data.bystander.incoming)      result.bystander.incoming{i} = lorentzBoost(data.bystander.incoming{i}, vo, gal);    endfor    % Light rays from incoming leg to bystander    for i=1:numel(data.incoming.bystander)      result.incoming.bystander{i} = lorentzBoost(data.incoming.bystander{i}, vo, gal);    endfor    % Lines of simultaneity for incoming leg    for i=1:numel(data.incoming.los)      result.incoming.los{i} = lorentzBoost(data.incoming.los{i}, vo, gal);    endfor  endif  if rs != 0    % Outgoing leg    result.outgoing.worldline = schwarzschild(result.outgoing.worldline, xs, rs, alt);    result.outgoing.ticks = schwarzschild(result.outgoing.ticks, xs, rs, alt);    for i=1:numel(result.bystander.outgoing)      if isempty(result.bystander.outgoing{i}) == false        result.bystander.outgoing{i} = schwarzschild(result.bystander.outgoing{i}, xs, rs, alt);      endif    endfor    for i=1:numel(result.outgoing.bystander)      if isempty(result.outgoing.bystander{i}) == false        result.outgoing.bystander{i}(:,2) -=result.outgoing.bystander{i}(1,2);        result.outgoing.bystander{i} = schwarzschild(result.outgoing.bystander{i}, xs, rs, alt);        result.outgoing.bystander{i}(:,2) += result.outgoing.ticks(i,2);      endif    endfor    for i=1:numel(result.outgoing.los)      result.outgoing.los{i} = schwarzschild(result.outgoing.los{i}, xs, rs, alt);    endfor        % Waypoint    result.bystander.waypoint = schwarzschild(result.bystander.waypoint, xs, rs, alt);    if isempty(result.bystander.waypoint) == false      result.waypoint.bystander(:,2) -= result.waypoint.bystander(1,2);    endif    result.waypoint.bystander = schwarzschild(result.waypoint.bystander, xs, rs, alt);    if isempty(result.waypoint.bystander) == false      result.waypoint.bystander(:,2) += result.outgoing.worldline(end,2);    endif    result.waypoint.los(:,2) = result.outgoing.worldline(end,2);     % Incoming leg    for i=1:numel(result.incoming.los)      result.incoming.los{i}(:,2) -= result.incoming.worldline(end,2);    endfor    for i=1:numel(result.incoming.bystander)      if isempty(result.incoming.bystander{i}) == false        result.incoming.bystander{i}(:,2) -= result.incoming.worldline(end,2);      endif    endfor    for i=1:numel(result.incoming.bystander)      if isempty(result.bystander.incoming{i}) == false        result.bystander.incoming{i}(:,2) -= result.incoming.worldline(end,2);      endif    endfor    result.incoming.ticks(:,2) -= result.incoming.worldline(end,2);    result.incoming.worldline(:,2) -= result.incoming.worldline(end,2);    result.incoming.worldline = schwarzschild(result.incoming.worldline, xs, rs, alt);    result.incoming.ticks = schwarzschild(result.incoming.ticks, xs, rs, alt);    result.incoming.ticks(:,2) += result.outgoing.worldline(end,2) - result.incoming.worldline(1,2);    result.incoming.worldline(:,2) += result.outgoing.worldline(end,2) - result.incoming.worldline(1,2);    for i=1:numel(result.bystander.incoming)      if isempty(result.bystander.incoming{i}) == false        result.bystander.incoming{i} = schwarzschild(result.bystander.incoming{i}, xs, rs, alt);        result.bystander.incoming{i}(:,2) += result.incoming.worldline(end,2);      endif    endfor    for i=1:numel(result.incoming.bystander)      if isempty(result.incoming.bystander{i}) == false        result.incoming.bystander{i} = schwarzschild(result.incoming.bystander{i}, xs, rs, alt);        result.incoming.bystander{i}(:,2) += result.incoming.worldline(end,2);      endif    endfor    for i=1:numel(result.incoming.los)      result.incoming.los{i} = schwarzschild(result.incoming.los{i}, xs, rs, alt);      result.incoming.los{i}(:,2) += result.incoming.worldline(end,2);    endfor    % Bystander age adjustment    result.bystander.age = result.incoming.worldline(end,2) - result.outgoing.worldline(1,2);  endifendfunction