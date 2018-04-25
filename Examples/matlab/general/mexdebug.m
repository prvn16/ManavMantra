function mexdebug(arg)
%MEXDEBUG Debug MEX-files (Unix only). 
%   MEXDEBUG has been deprecated, use DBMEX instead.
%
%   See also DBMEX.

%   Copyright 1984-2006 The MathWorks, Inc. 

warning(message('MATLAB:mexdebug:ObsoleteFunction'))

if any(getenv('MATLAB_DEBUG'))  
    if nargin < 1, arg = 'on'; end
    if strcmp(arg,'stop')
        system_dependent(9);
    elseif strcmp(arg,'print')
        system_dependent(8,2);
    else
        system_dependent(8,strcmp(arg,'on'));
    end
else
    disp(' ')
    disp(getString(message('MATLAB:mexdebug:MATLABMustBeRunWithinDebugger')));
    disp(' ')
    disp(['    ',getString(message('MATLAB:mexdebug:ToRunMATLABWithinADebugger'))]);
    disp('           matlab -Ddebugger');
    disp(['    ',getString(message('MATLAB:mexdebug:WhereDebuggerIsTheDebuggerYouWishToUse'))]);
    disp(' ')
end
