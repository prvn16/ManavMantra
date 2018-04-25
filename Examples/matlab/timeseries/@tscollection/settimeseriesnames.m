function h = settimeseriesnames(h,oldname,newname)
%SETTIMESERIESNAMES  Change the name of the selected time series object.
%
% TSC = SETTIMESERIESNAMES(TSC,OLD,NEW) replaces the name of time series OLD with
% name NEW in the tscollection object TSC. 
%

%   Copyright 2005-2016 The MathWorks, Inc.
%

if isempty(oldname) || ~isvarname(newname)
    error(message('MATLAB:tscollection:settimeseriesname:badsyntax'))
end
if (~ischar(oldname) && ~(isstring(oldname) && isscalar(oldname))) || ...
       (~ischar(newname) && ~(isstring(newname) && isscalar(newname)))
    % oldname or newname are not single char vectors or strings
    error(message('MATLAB:tscollection:settimeseriesname:onlychars'))
end
if strcmp(oldname,newname)
    ; % do nothing (G961753)
elseif any(strcmp(oldname,gettimeseriesnames(h)))  
    tmp = getts(h,oldname);
    tmp.Name = newname;
    h = setts(h,tmp,newname);
    h = removets(h,oldname);
else
    error(message('MATLAB:tscollection:settimeseriesname:badmember', oldname))
end