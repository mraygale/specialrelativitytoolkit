function [result] = lorentzBoost(data, v, gal=false)
  if isempty(data)
    result = data;
  else
    if gal
      t = data(:,2);
      x = data(:,1) - v * data(:,2);
    else
      g = 1 / sqrt(1 - v^2);
      t = g * (data(:,2) - v * data(:,1));
      x = g * (data(:,1) - v * data(:,2));
    endif
    result = cat(2, x, t);
  endif
endfunction
