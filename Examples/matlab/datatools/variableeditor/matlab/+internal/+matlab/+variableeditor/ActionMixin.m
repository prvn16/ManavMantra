classdef (CaseInsensitiveProperties=true, TruncatedProperties=true, ConstructOnLoad=true) ActionMixin < handle
    % ActionMixin

    methods(Access='public')
        % getSupportedActions
        function actionList = getSupportedActions(~,varargin)
            actionList = [];
        end

        % isActionAvailable
        function isAvailable = isActionAvailable(~,~,varargin)
            isAvailable = false;
        end
    end
end
