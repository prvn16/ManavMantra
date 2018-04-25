function zrange = estimateViewingBox(zdata, zmin, zmax, poleSearch)
% internal helper function

% estimate the viewing box based on the data computed, taking into account that some limit may be given by the user

% Copyright 2015-2016 The MathWorks, Inc.

if nargin < 4
  poleSearch = true;
end

if isempty(zdata)
  zrange = [nan nan nan nan];
  return;
end

if poleSearch
  % look at the extreme values, arbitrarily meaning outside the 0.1..0.9 quantiles
  
  zdata_s = sort(zdata(:));
  
  x01 = zdata_s(ceil(0.1*numel(zdata_s)));
  x09 = zdata_s(ceil(0.9*numel(zdata_s)));
  x05 = zdata_s(ceil(0.5*numel(zdata_s)));
  
  if ~isfinite(zmax)
    zmax = min(zdata_s(end), x05+10*(x09-x05));
  end
  if ~isfinite(zmin)
    zmin = max(zdata_s(1), x05-10*(x05-x01));
  end
else
  zmin = min(zdata);
  zmax = max(zdata);
end

% maybe round out, if our values are close to somewhat round numbers.
% What “round” means here depends on the values we computed, since we want
% to have similar behavior for fplot(@(x)sin(x)) and fplot(@(x)1e-3*sin(x)).
magnitude = 1-round(log10(zmax - zmin));
if isfinite(magnitude) && isreal(magnitude)
  maxdelta = 10^(-magnitude-1);
  dmin = zmin - round(zmin,magnitude);
  if dmin>0 && dmin<maxdelta
    zmin = round(zmin,magnitude);
  end
  dmax = round(zmax,magnitude) - zmax;
  if dmax>0 && dmax<maxdelta
    zmax = round(zmax,magnitude);
  end
end

zrange = matlab.graphics.chart.primitive.utilities.arraytolimits([zmin zmax zdata(zdata>=zmin & zdata<=zmax)]);
