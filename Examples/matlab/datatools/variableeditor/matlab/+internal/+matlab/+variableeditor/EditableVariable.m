classdef EditableVariable < handle
    %EDITABLEVARIABLE
    %   Defines an editable variable

    % Copyright 2013 The MathWorks, Inc.

    % Public Abstract Methods
    methods(Access='public',Abstract=true)
        % setData
        varargout = setData(this,varargin);
    end
end

