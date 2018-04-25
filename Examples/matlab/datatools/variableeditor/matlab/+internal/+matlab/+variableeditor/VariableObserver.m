classdef VariableObserver < handle
    %VARIABLEOBSERVER
    %   Implment this acstract class to listen to variable changes

    % Copyright 2013 The MathWorks, Inc.

    % Public Abstract Methods
    methods(Access='public',Abstract=true)
        % variableChanged
        [data,varargout] = variableChanged(this,varargin);
    end
end

