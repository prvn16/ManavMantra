classdef (Hidden) ComponentProxyViewFactory < appdesservices.internal.peermodel.PeerModelProxyViewFactory
    % COMPONENTPROXYVIEWFACTORY is the ProxyViewFactory for HMI Components
    %
    % This factory uses appdesservices.internal.peermodel.PeerModelProxyView as its
    % ProxyViews.  To decouple the PeerModelProxyView from the creation of
    % PeerNodes, this factory takes care of creating PeerNodes and
    % populating their initial state.  It then hands off the PeerNode to
    % the ProxyView during construction, and after that point it is the
    % responsibility of the ProxyView to update the properties.
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    properties(Access = 'private')
        % Represents the Unique Key that will be used for each App Window's
        % unique URL.
        AppWindowIDCounter = 1;
    end
    
    properties (SetAccess=protected)
        % Connection object that starts the MOTW connector and composes the 
        % URL for the CEF client web page
        Connection
    end
    
    methods        
        
        function proxyView = createProxyView(obj, type, parentController, propertyNameValues)
            % Create a ProxyView for the given controller
            
            if(isempty(parentController))
                % Create a unique namespace and URL for the App Window
                %
                % The namespace is defined as:
                %
                %   /appwindow/<uniqueID>
                %
                % The URL is defined as:
                %
                %   (path to index)/index.html?appWindowID=<uniqueID>
                %
                % To create a unique ID, this factory maintains a counter that
                % is incremented each time a window is made.
                
                % Get a new ID for this App Window
                uniqueID = num2str(generateUniqueKey(obj));
                
                % Create the namespace
                baseNameSpace = 'appwindow';
                uniqueNamespace = sprintf('/%s/%s', baseNameSpace, uniqueID);
                
                % Create the URL
                baseURL = 'toolbox/matlab/uicomponents/web/index.html';
                pathToWebPage = sprintf('%s?appWindowID=%s', baseURL, uniqueID);
                
                % Construct the Connection object with the path to the
                % webpage. It will start the connector.
                obj.Connection = appdesservices.internal.peermodel.Connection(pathToWebPage);
                
                % Create arguments for the initial setting of the browser
                %
                % Do this by finding each property name in the PV Pair
                % array, and then getting the value by looking at index + 1
                nameIndex = find(strcmp(propertyNameValues, 'Name')) + 1;
                initialBrowserArguments.Title = propertyNameValues{nameIndex};
                
                sizeIndex = find(strcmp(propertyNameValues, 'Size')) + 1;
                initialBrowserArguments.Size = propertyNameValues{sizeIndex};
                
                locationIndex = find(strcmp(propertyNameValues, 'Location')) + 1;
                initialBrowserArguments.Location = propertyNameValues{locationIndex};
              
                % Create the Proxy View
                proxyView = createRootProxyView(obj, uniqueNamespace, type, propertyNameValues, initialBrowserArguments);   
                
            else
                % When other components are passed in, then just need to
                % create a regular proxy view
                proxyView = createDefaultProxyView(obj, ...
                    type, ...
                    parentController.ProxyView.PeerNode, ...
                    parentController.ProxyView.PeerModelManager, ...
                    propertyNameValues ...
                );
            end
        end        
    end
    
    methods(Access = 'protected')        
        function proxyView = doCreateDefaultProxyView(obj, varargin)
            proxyView = appdesservices.internal.peermodel.ServerDrivenPeerNodeProxyView(varargin{:});
        end
    end
    
    methods(Access = 'private')
        function id = generateUniqueKey(obj)
            
            % Return the current value
            id = obj.AppWindowIDCounter;
            
            % Increment the counter
            obj.AppWindowIDCounter = obj.AppWindowIDCounter + 1;
        end
    end
    
    methods(Static)
        function converterFcn = getPVPairsConverter(type)
            % get PV pairs converter function handle according to the
            % passing type
            %
            % ComponetnProxyViewFactory overrides it to add a JSON
            % compatible data converter
            switch type
                case appdesservices.internal.peermodel.ValueConverterType.JSON_COMPATIBLE
                    converterFcn = @appdesservices.internal.peermodel.convertPvPairsToJSONCompatible;
                case appdesservices.internal.peermodel.ValueConverterType.JSON_COMPATIBLE_STRUCT
                    converterFcn = @appdesservices.internal.peermodel.convertPvPairsToJSONCompatibleStruct;
                otherwise
                    converterFcn = appdesservices.internal.peermodel.PeerModelProxyViewFactory.getPVPairsConverter(type);
            end
        end
    end
end
