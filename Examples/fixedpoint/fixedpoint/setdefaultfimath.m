function setdefaultfimath(varargin)
% SETDEFAULTFIMATH Configure global fimath
%
%   SETDEFAULTFIMATH is obsolete. SETDEFAULTFIMATH still works but may be removed in a future release.
%   Use <a href="matlab:help globalfimath">globalfimath</a> instead.   
%
%   See also RESETGLOBALFIMATH, SAVEGLOBALFIMATHPREF, REMOVEGLOBALFIMATHPREF
    
%   Copyright 2003-2015 The MathWorks, Inc.
    
nargoutchk(0,0);
narginchk(1,inf);
globalfimath(varargin{:});


