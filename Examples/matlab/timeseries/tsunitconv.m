function convFactor = tsunitconv(outunits,inunits)
%TSUNITCONV Utility function used to convert time units
%
%   Copyright 2004-2015 The MathWorks, Inc.

convFactor = 1; % Return 1 if units are the same or unknown (e.g., lightyears)
if strcmpi(outunits,inunits)
  return;
end

factIn = timeseries.utGetFactors(inunits);
factOut = timeseries.utGetFactors(outunits);
if ~isempty(factIn) && ~isempty(factOut)
  convFactor = factIn/factOut;
end