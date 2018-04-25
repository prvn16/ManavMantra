function tt = stack(tw,varargin)
%STACK Stack up data from multiple variables into a single variable
%   T = STACK(WIDE,DATAVARS) 
%   T = STACK(WIDE,DATAVARS,NAME1,VALUE1,...)
%
%   Limitations:
%   [T, IWIDE] = STACK(...) is not supported. 
%
%   See also TABLE/STACK, TIMETABLE/STACK

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,inf);
tw = tall.validateType(tw, upper(mfilename), {'table', 'timetable'}, 1);
tall.checkNotTall(upper(mfilename), 1, varargin{:});
% Create dummy table to determine variable names and types. 

% Stack the tall table
tt = chunkfun(@(x)stack(x,varargin{:}), tw); 

requiresVarMerging = false;
tt.Adaptor = joinBySample(@(w) iStack(w, varargin{:}), requiresVarMerging, tw.Adaptor);
end

function tt = iStack(w, iVar, varargin)
if isempty(iVar)
    tt = w;
else
    tt = stack(w, iVar, varargin{:});
end
end