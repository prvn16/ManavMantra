function tt = innerjoin(tA, tB, varargin)
%INNERJOIN Inner join between two tables or two timetables.
%   C = INNERJOIN(A, B) 
%   C = INNERJOIN(A, B, 'PARAM1',val1, 'PARAM2',val2, ...)
%
%   Limitations: 
%   1) Only INNERJOIN between tall table and table, or 
%      tall timetable and timetable is supported. 
%   2) Second and third outputs are not supported.
%
%   See also TABLE/INNERJOIN, TIMETABLE/INNERJOIN

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,inf);
[tA, tB] = tall.validateType(tA, tB, upper(mfilename), {'table', 'timetable'}, 1:2);
if istall(tA) && istall(tB)
    error(message('MATLAB:bigdata:array:InnerjoinTwoTallTableNotSupported',tall.getClass(tA)));
end
tall.checkNotTall(upper(mfilename), 2, varargin{:});
% Create dummy table to determine variable names and types.
Aname = inputname(1);
Bname = inputname(2);

% Use joinBySample to create an appropriate adaptor for the output. We do
% this first as it provides the actual variable names. We don't want to
% repeat this same work per chunk.
adaptorA = matlab.bigdata.internal.adaptors.getAdaptor(tA);
adaptorB = matlab.bigdata.internal.adaptors.getAdaptor(tB);
requiresVarMerging = true;
[adaptorOut, varNames] = joinBySample(...
    @(A, B) joinNamedTables(@innerjoin, A, B, Aname, Bname, varargin{:}),...
    requiresVarMerging, adaptorA, adaptorB);

% Now schedule the actual work.
if istall(tA)   
    tt = chunkfun(@(x)iLocalInnerjoin(x,tB,varNames,varargin{:}),tA);
else
    tt = chunkfun(@(x)iLocalInnerjoin(tA,x,varNames,varargin{:}),tB);
end
tt.Adaptor = adaptorOut;
end

function tt = iLocalInnerjoin(A,B,outputNames,varargin)
tt = innerjoin(A,B,varargin{:});
tt.Properties.VariableNames = outputNames;
end
