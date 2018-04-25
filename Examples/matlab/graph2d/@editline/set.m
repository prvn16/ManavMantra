function A = set(A, varargin)
%EDITLINE/SET Set editline property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

lArgin = varargin;

HG = get(A,'MyHGHandle');

while length(lArgin) >= 2,
   prop = lArgin{1};
   val = lArgin{2};

   lArgin = lArgin(3:end);
   switch prop
   case {'XYData' 'XYDataRefresh'}
      set(HG, 'XData', val{1}, 'YData', val{2});
   otherwise
      axischildObj = A.axischild;
      A.axischild = set(axischildObj, prop, val);
   end
end

