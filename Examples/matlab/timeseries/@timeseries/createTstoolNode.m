function node = createTstoolNode(ts,varargin)
%CREATETSTOOLNODE  Create a node for the timeseries object in the tstool
%tree. 
%
%   CREATETSTOOLNODE(TS,H) where H is the parent node object. Information
%   from H is required to check against existing node with same name.

%   Copyright 2004-2012 The MathWorks, Inc.

len = length(get(ts,'Events'));
tsH = tsdata.timeseries(ts);
if len>0
    for i=1:len
        str(i) = {tsH.Events(i).name}; %#ok<AGROW>
    end
    
    if length(unique(str))~=len
        error(message('MATLAB:timeseries:createTstoolNode:nonUniqueNames'))
    end
end
node = tsH.createTstoolNode(varargin{:});
