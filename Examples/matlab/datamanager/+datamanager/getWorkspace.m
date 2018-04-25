function [mfile,fcnname] = getWorkspace(offset)

% Utility method for brushing/linked plots. May change in a future release.

% Copyright 2008-2010 The MathWorks, Inc.

[dbstruct,dbI] = dbstack('-completenames');
if length(dbstruct)>=(dbI+1+offset)
    mfile = dbstruct(dbI+1+offset).file;
    fcnname = dbstruct(dbI+1+offset).name;
else
    mfile = '';
    fcnname = '';
    return
end

% Be sure that mfile is not part of matlab/toolbox, which means that
% a drawnow has triggered the calling function from an unexpected
% workspace.
k = dbI+2+offset;
matlabToolboxPath = toolboxdir('matlab');
while ~isempty(strfind(lower(mfile),matlabToolboxPath))
    if k<=length(dbstruct)
        mfile = dbstruct(k).file;
        fcnname = dbstruct(k).name;
    else
        mfile = '';
        fcnname = '';
        return        
    end
    k = k+1;
end