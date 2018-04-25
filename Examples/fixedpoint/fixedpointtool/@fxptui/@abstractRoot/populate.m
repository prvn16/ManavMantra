function populate(handle, varargin)
%POPULATE Populates the root

%   Copyright 2009-2012 The MathWorks, Inc.
%   

if nargin == 1
    return;
end

mdlname = varargin{1}.getFullName; 

child = fxptui.blkdgmnode(mdlname);
handle.children = child;
handle.topchildren = child;

topmodeobj = get_param(mdlname, 'Object');
mdlrefBlocks = find(topmodeobj, '-isa', 'Simulink.ModelReference');

for idx = 1:length(mdlrefBlocks)
    refMdlName = mdlrefBlocks(idx).ModelName;
    load_system(refMdlName);
    child = fxptui.blkdgmnode(refMdlName);
    handle.children(end+1) = child;
end
