function node = createTstoolNode(ts,varargin)
%CREATETSTOOLNODE  Create a node for the tscollection object in the tstool
%tree. 
%
%   CREATETSTOOLNODE(TSC,H) where H is the parent node object. Information
%   from H is required to check against existing node with same name.

%   Author(s): Rajiv Singh, James Owen
%   Copyright 2004-2006 The MathWorks, Inc.


tsH = tsdata.tscollection(ts);
node = tsH.createTstoolNode(varargin{:});
