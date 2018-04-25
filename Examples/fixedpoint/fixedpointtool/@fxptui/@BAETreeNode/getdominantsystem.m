function [dSys, dParam] = getdominantsystem(this, param)
%GETDOMINANTSYSTEM Get the dominantsystem.
%   OUT = GETDOMINANTSYSTEM(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

dSys = [];
dParam = [];
if(~isa(this, 'DAStudio.Object'))
	return;
end

%throw an error if an invalid param is passed in
%initialize the output args with the current system and param value
dSys = this.TreeNode.daobject;
dParam = this.(param);
%get this systems parent
parent = this.Parent; % call to getParent
%loop until the model root is reached, we want to find the highest system
%with a dominant setting (ie: anything but UseLocalSettings)
while ~isempty(parent)
    %if this parent doesn't have a dominant setting get the next parent
    if ~strcmpi('UseLocalSettings', parent.(param))
        %this parent contains dominant setting, hold on to it
        dSys =   parent.daobject;
        dParam = parent.(param);
    end
    parent = parent.Parent;
end


% [EOF]
