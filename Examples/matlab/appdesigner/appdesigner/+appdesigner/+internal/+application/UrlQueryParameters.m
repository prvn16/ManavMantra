classdef UrlQueryParameters < handle
    %URLQUERYPARAMTERS Utility for configuring query parameters and getting
    % url query string for starting App Designer
    %
    % Copyright 2016-2017 The MathWorks, Inc.

    properties
        % Url query string with format: "key1=value1&key2=value2&...."
        QueryString
    end

    properties (Constant)
        % Settings that need to be used as query param if value = true
        SettingsList = {...
            {'startup', 'ShowIntroDialog'},...
            {'designview', 'ShowAxesBanner'},...
            {'codeview', 'ShowCodeViewTips'},...
            {'codeview', 'ShowProgrammingTips'}};
    end

    properties (Access = private)
        QueryParamsMap = containers.Map;
    end

    methods
        function obj = UrlQueryParameters(varargin)
            % Constructs a UrlQueryParameters that contains a unique query
            % key-value.
            % Optional input parameters (must use both together):
            %   keySet   - cell array of query keys
            %   valueSet - cell array of query key values

            obj.QueryParamsMap = obj.getDefaultUrlQueryParams();

            if nargin > 1
                % The optional keySet and valueSet were specified and so
                % extract them from varargin.
                keySet = varargin{1};
                valueSet = varargin{2};

                % Mixin the passed in query params with the default
                paramsToMixin = containers.Map(keySet, valueSet);
                obj.QueryParamsMap = [obj.QueryParamsMap; paramsToMixin];
            end

            % Build the query string
            obj.QueryString = obj.buildQueryString;
        end

        function value = getQueryValue(obj, key)
            % GETQUERYVLAUE returns the query value for a given query key.
            % Returns [] if query key doesn't exist.

            value = [];
            if obj.QueryParamsMap.isKey(key)
                value = obj.QueryParamsMap(key);
            end
        end
    end

    methods (Access = private)
        function queryParamsMap = getDefaultUrlQueryParams(obj)
            % GETDEFAULTURLQUERYPARAMS returns a Map with the default query
            % parameters to be used when starting App Designer.
            %
            % The set of query parameters to use are dynamic because some
            % of them depend on values for specific persistent settings.
            % A query parameter will only be added to the Map if it is
            % different than what is expected on the client.

            queryParamsMap = containers.Map;

            %% Add query parameters based on settings

            % Settings that need to be passed as query param if value = true
            s = obj.SettingsList;

            % The values for the settings
            values = cellfun(...
                @(x)appdesigner.internal.application.getAppDesignerSetting(x{:}), s);

            % For any setting value that is true, add it to the query params map
            if any(values)
                paramKeys = cellfun(@(x) x{2}, s(values), 'UniformOutput', false);
                paramValues = repmat({'true'}, 1, length(paramKeys));
                queryParamsMap = [queryParamsMap; containers.Map(paramKeys, paramValues)];
            end

            %% Add query parameters always used

            % The current working directory will be used to open the file
            % dialogs in a location that based on the pwd of MATLAB at the
            % time of open
            currentWorkingDirectory = pwd;

            % Add a trailing file separator if necessary
            if ~strcmp(currentWorkingDirectory(end), filesep)
                currentWorkingDirectory = [currentWorkingDirectory, filesep];
            end

            % Add the current working directory as query param.
            queryParamsMap('CWD') = currentWorkingDirectory;

            % Add the compiler information which indicates if this MATLAB
            % has compiler integrated in and if this MATLAB license
            % includes compiler functionality.
            if license('test','compiler') && ~isempty(ver('compiler'))
                queryParamsMap('HasCompiler') = 'true';
            end
        end

        function queryString = buildQueryString(obj)
            % BUILDQUERYSTRING - generates url query string in alphabetical
            % order based on query key

            queryKeys = sort(obj.QueryParamsMap.keys);
            queryStrings = cellfun(...
                @(key)sprintf('%s=%s', key, appdesigner.internal.application.encodeURIForJS(obj.QueryParamsMap(key))),...
                queryKeys, 'UniformOutput', false);
            queryString = strjoin(queryStrings, '&');
        end
    end

end
