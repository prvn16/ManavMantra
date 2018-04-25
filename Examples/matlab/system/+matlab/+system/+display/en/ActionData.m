classdef ActionData< handle
%matlab.system.display.ActionData   Callback object for Action
%   This class is not intended to be instantiated directly.  An instance is
%   passed to the ActionCalledFcn of a matlab.system.display.Action when 
%   ActionCalledFcn is specified as a function handle.  Use the UserData
%   property of matlab.system.display.ActionData to store persistent data
%   such as a figure handle.
%
%  ActionData properties:
%
%      UserData - Action user data
% 
%   See also matlab.system.display.Action.

 
%   Copyright 2014 The MathWorks, Inc.

    methods
        function out=ActionData
            %matlab.system.display.ActionData   Callback object for Action
            %   This class is not intended to be instantiated directly.  An instance is
            %   passed to the ActionCalledFcn of a matlab.system.display.Action when 
            %   ActionCalledFcn is specified as a function handle.  Use the UserData
            %   property of matlab.system.display.ActionData to store persistent data
            %   such as a figure handle.
            %
            %  ActionData properties:
            %
            %      UserData - Action user data
            % 
            %   See also matlab.system.display.Action.
        end

    end
    methods (Abstract)
    end
    properties
        %UserData   Action user data
        %   Action user data, which may be accessed in ActionCalledFcn of a
        %   matlab.system.display.Action to store or retrieve data (such as
        %   a figure handle) that is intended to be persistent between
        %   invocations of the action.
        UserData;

    end
end
