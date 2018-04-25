function flag = eml_iscomplexroundmode_helper(F,rmode)
% Helper function that returns true if fimath F 
% has a roundmode that is ceil, round, nearest or convergent

% Copyright 2006-2015 The MathWorks, Inc.
    
narginchk(1,2);
if ~isfimath(F)
    error(message('fixed:fimath:inputNotFimath'));
end
if nargin==1
    rmode = '';
end
fRoundMode = get(F,'RoundMode');
if isempty(rmode)
    flag = strcmpi(fRoundMode,'round') ||...
           strcmpi(fRoundMode,'nearest') ||...
           strcmpi(fRoundMode,'convergent') ||...
           strcmpi(fRoundMode,'ceil');
elseif ischar(rmode)
    flag = strcmpi(fRoundMode,rmode);
end
%------------------------------------------------------------------
