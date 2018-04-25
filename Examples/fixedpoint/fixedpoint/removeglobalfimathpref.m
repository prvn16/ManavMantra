function removeglobalfimathpref
% REMOVEGLOBALFIMATHPREF Remove global fimath MATLAB preference 
%    
%    REMOVEGLOBALFIMATHPREF removes the user configured global fimath that was saved as a MATLAB preference.
%
%
%    Example:
%      resetglobalfimath; 
%      removeglobalfimathpref;
%    
%    See also GLOBALFIMATH, RESETGLOBALFIMATH
    
%   Copyright 2003-2012 The MathWorks, Inc.

% If the 'embedded'/'defaultfimath' preference exists delete it from the MATLAB preferences.    
if ispref('embedded','defaultfimath')
    rmpref('embedded','defaultfimath');
end
