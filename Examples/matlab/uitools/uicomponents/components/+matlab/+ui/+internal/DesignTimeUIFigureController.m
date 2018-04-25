classdef DesignTimeUIFigureController < ...
        matlab.ui.internal.controller.FigureController & ...
        matlab.ui.internal.DesignTimeGbtParentingController & ...
        appdesservices.internal.interfaces.controller.ServerSidePropertyHandlingController
    %DESIGNTIMEUIFIGURECONTROLLER - This class contains design time logic
    %specific to the uifigure
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    methods
        function obj = DesignTimeUIFigureController(component, parentController, proxyView)
            % This constructor is called twice on the same component in the
            % case of loading, so we need to check for the presence of the
            % GUIDEFigure property.
            if (~isprop(component, 'GUIDEFigure'))
                guideFigureProp = addprop(component, 'GUIDEFigure');
                guideFigureProp.Transient = true;
            end
            
            obj = obj@matlab.ui.internal.controller.FigureController(component, parentController, proxyView);
            obj = obj@matlab.ui.internal.DesignTimeGbtParentingController(component, parentController, proxyView);            
        end
        
        function id = getId(obj)
            % GETID(OBJ) returns a string that is the ID of the peer node
            id = obj.ProxyView.getId();
        end
    end
    
    methods ( Access=protected )
        function handleDesignTimePropertyChanged(obj, peerNode, data)
            
            % handleDesignTimePropertyChanged( obj, peerNode, data ) 
            % Controller method which handles property updates in design time. For 
            % property updates that are common between run time and design time, 
            % this method delegates to the corresponding run time controller.
        
            % Handle property updates from the client
                
            updatedProperty = data.key;
            updatedValue = data.newValue;
            
            switch (updatedProperty)
                case 'Color'
                    obj.Model.Color = convertClientNumbertoServerNumber(obj, updatedValue);
                    
                case 'Colormap'
                    obj.Model.Colormap = convertClientNumbertoServerNumber(obj, updatedValue);

                case 'Resize'
                    if strcmp(updatedValue, 'on')
                        obj.Model.Resize = 'on';
                    else
                        obj.Model.Resize = 'off';
                    end
                    
                otherwise
                    % call base class to handle it
                    handleDesignTimePropertyChanged@matlab.ui.internal.DesignTimeGBTComponentController(obj, peerNode, data);
            end
        end
        
        function additionalPropertyNamesForView = getAdditionalPropertyNamesForView(obj)
            % Hook for subclasses to provide a list of property names that
            % needs to be sent to the view for loading in addition to the 
            % ones pushed to the view defined by PropertyManagementService
            %
            % Example:
            % 1) Callback function properties
            % 2) Name, Colormap required by client side
            % 3) TODO: should Position/Units be defined in
            % PropertyManagmentService?
            
            additionalPropertyNamesForView = {'Name'; 'Colormap'; 'NextPlot'; 'CloseRequestFcn'; 'Position';
                'Units';'IntegerHandle';'NumberTitle';};

            additionalPropertyNamesForView = [additionalPropertyNamesForView; ...
                getAdditionalPropertyNamesForView@matlab.ui.internal.DesignTimeGBTComponentController(obj)];
            
            additionalPropertyNamesForView = setdiff(additionalPropertyNamesForView, ...
                {'IsSizeFixed', 'AspectRatioLimits'});
            
        end
        
        function excludedPropertyNames = getExcludedPropertyNamesForView(obj)
            % Hook for subclasses to provide a list of property names that
            % needs to be excluded from the properties to sent to the view
            % 
            % Examples:
            % - Children, Parent, are not needed by the view
            % - Position, InnerPosition, OuterPosition are not updated by
            % the view and are excluded so their peer node values don't
            % become stale
            % - HandleVisibility is not supported on UIFigure            
            %   (its visible but warns when set)
            
            excludedPropertyNames = {'Position_I'; 'Title'; 'HandleVisibility'};            
            
            excludedPropertyNames = [excludedPropertyNames; ...
                getExcludedPropertyNamesForView@matlab.ui.internal.DesignTimeGBTComponentController(obj); ...
                ];
            
        end
        
        function viewPvPairs = getPropertiesForView(obj, propertyNames)
            % Override to customize CloseRequestFcn value
            %
            
            viewPvPairs = {};
            % Return empty for default closereq callback
            closeRequestFcn = '';
            if ~strcmp(obj.Model.CloseRequestFcn, 'closereq')
                closeRequestFcn = obj.Model.CloseRequestFcn;
            end

            % Merge super class returan value
            viewPvPairs = [viewPvPairs, ...
                {'CloseRequestFcn', closeRequestFcn},...
                ];
       
            % Merge super class return value
            viewPvPairs = [viewPvPairs, ...
                getPropertiesForView@matlab.ui.internal.DesignTimeGbtParentingController(obj, propertyNames)];
        end
    
        function viewPvPairs = getAutoResizePropertyForView(obj, propertyNames)
            % Design time controller method, invoked to restore auto resize
            % related values from the model
            
            viewPvPairs = {};
            
            if(any(ismember('AutoResizeChildren', propertyNames)))
                % Initialize the auto resize property.
                % Apps created in 16a/16b do not define the AutoResizeChildren
                % property. Instead, they have a dynamic property AutoResize.
                % We use AutoResize if it was loaded from the saved app to
                % maintain backwards compatibility.
                if(isprop(obj.Model, 'AutoResize'))
                    if(obj.Model.AutoResize)
                        obj.Model.AutoResizeChildren = 'on';
                    else
                        obj.Model.AutoResizeChildren = 'off';
                    end
                    % Once we have used the saved dynamic property 'AutoResize'
                    % to load the app, we no longer need it, and we don't
                    % want to re-save it either
                    metaObj = obj.Model.findprop('AutoResize');
                    delete(metaObj);
                end
                
                viewPvPairs = [viewPvPairs, ...
                    {'AutoResizeChildren', obj.Model.AutoResizeChildren},...
                    ];
            end
        end
    end    
end

