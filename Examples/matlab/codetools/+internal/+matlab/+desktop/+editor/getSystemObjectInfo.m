function [isConfirmedSystem, isConfirmedNonSystem, isConfirmedEventSystem, ...
    methodIsImplemented, methodIsAvailable, methodLabels] = getSystemObjectInfo(varargin)
%getSystemObjectInfo   Return System object information
%
%   This function is unsupported and might change or be removed without
%   notice in a future version. 

%   Copyright 2015 The MathWorks, Inc.

% This is entrypoint for MATLAB Editor to determine if file corresponds to 
% a System object. Use this entrypoint to guard against errors in calling
% matlab.system.editor.internal.getSystemObjectInfo (most importantly, "not 
% found" error due to folder being removed from path due to custom pathdef).

try
    [isConfirmedSystem, isConfirmedNonSystem, isConfirmedEventSystem, ...
        methodIsImplemented, methodIsAvailable, methodLabels] = matlab.system.editor.internal.getSystemObjectInfo(varargin{:});
catch err %#ok<NASGU> % Catch error to avoid populating lasterr
    % Return that file is not a System object
    isConfirmedSystem = false;
    isConfirmedEventSystem = false;
    isConfirmedNonSystem = true;
    methodIsImplemented = [];
    methodIsAvailable = [];
    methodLabels = [];
end
