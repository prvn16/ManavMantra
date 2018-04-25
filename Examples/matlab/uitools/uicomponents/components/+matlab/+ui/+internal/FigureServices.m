classdef FigureServices < handle
% FIGURESERVICES A set of static helper functions for working with Figures.

% Copyright 2015-2017 The MathWorks, Inc.
    
    methods(Static, Access = private)

        function out = setgetURL(fig, url)
        % Helper function to access the persistent map of Figure to URL.
        % This function allows for setting, getting and removing of an URL.
            persistent urlMap;
            
            if isempty(urlMap)
                % Create the URL map
                urlMap = containers.Map('KeyType','double','ValueType','char');
            end
            
            out = [];
            key = double(fig);
            if (nargin == 2)
                if isKey(urlMap, key) && isempty(url)
                    % Delete Figure URL
                    remove(urlMap, key);
                elseif ~isempty(key) && ~isempty(url)
                    % Insert Figure URL
                    urlMap(key) = url;
                end
            elseif isKey(urlMap, key)
                % Retrieve Figure URL
                out = string(urlMap(key));
            end
        end

    end
    
    methods(Static, Access = {?matlab.ui.internal.controller.FigureController})

        function setFigureURL(fig, url)
        %SETFIGUREURL Stores the URL for a given Figure.
        % SETFIGUREURL(FIG,URL) stores URL as the URL for the given Figure handle
        % FIG.
            matlab.ui.internal.FigureServices.setgetURL(fig, url);
        end
        
        function removeFigureURL(fig)
            %REMOVEFIGUREURL Removes the URL for the given Figure from the
            %repository.
            % REMOVEFIGUREURL(FIG) removes the URL for the given Figure
            % from the URL repository.
            matlab.ui.internal.FigureServices.setgetURL(fig, []);
        end
        
    end
        
    methods(Static)

        function url = getFigureURL(fig)
        %GETFIGUREURL Gets the URL for a given Figure handle.
        % GETFIGUREURL(FIG) returns the URL that represents the given Figure
        % handle FIG.
            url = matlab.ui.internal.FigureServices.setgetURL(fig);

            % call drawnow to let the Controller and URL be created and
            % re-get the URL, if the URL is not yet present in the urlMap
            if isempty(url)
                drawnow nocallbacks
                url = matlab.ui.internal.FigureServices.setgetURL(fig);
            end
        end
        
        function configureFigureForAppBuilding(fig)
        %CONFIGUREFIGURE Configures the given figure for application building
        %by setting several default property values for each of several types
        %of object that the figure may contain.
        
            % Set the units to Pixels as default, as we now support only
            % Pixels as type for units when hosting UIPanel in application figures
            set(fig, 'DefaultUipanelUnits', 'pixels', 'DefaultUipanelPosition', [20,20, 260, 221],...
                'DefaultUipanelBordertype', 'line', 'DefaultUipanelFontname', 'Helvetica',...
                'DefaultUipanelFontunits', 'pixels', 'DefaultUipanelFontsize', 12,...
                'DefaultUipanelAutoresizechildren', 'on');

            % Set the units to Pixels as default, as we now support only
            % Pixels as type for units when hosting UITabGroup in application figures
            set(fig, 'DefaultUitabgroupUnits', 'pixels', 'DefaultUitabgroupPosition', [20,20, 250, 210],...
                'DefaultUitabgroupAutoresizechildren', 'on');

            % Set the units to Pixels as default, as we now support only
            % Pixels as type for units when hosting UITab in application figures
            set(fig, 'DefaultUitabUnits', 'pixels', 'DefaultUitabAutoresizechildren', 'on');

            % Set the units to Pixels as default, as we now support only
            % Pixels as type for units when hosting UIButtonGroup in application figures
            set(fig, 'DefaultUibuttongroupUnits', 'pixels', 'DefaultUibuttongroupPosition', [20,20, 260, 210],...
                'DefaultUibuttongroupBordertype', 'line', 'DefaultUibuttongroupFontname', 'Helvetica',...
                'DefaultUibuttongroupFontunits', 'pixels', 'DefaultUibuttongroupFontsize', 12,...
                'DefaultUibuttongroupAutoresizechildren', 'on');

            % Set the Default Font properties for the UITable in application figures
            set(fig, 'DefaultUitableFontname', 'Helvetica', 'DefaultUitableFontunits', 'pixels',...
                'DefaultUitableFontsize', 12);

        end
        
    end

end
