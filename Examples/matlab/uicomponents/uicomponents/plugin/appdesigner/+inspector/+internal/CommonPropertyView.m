classdef CommonPropertyView
    %CommonPropertyView - a helper class that creates common as well as component specific
    %                     property groups
    
    %   Copyright 2015-2017 The MathWorks, Inc.
    
    methods (Static)
        
        
        function group = createPropertyInspectorGroup(propertyViewObject, groupMessageId, varargin)
            % createPropertyInspectorGroup function is responsible for creating
            % a component specific property inspector group. The function takes
            % in the property view object, a group message id that is defined in
            % the Inspector.xml resource file and a list of property names.
            %   ex: inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:<group name>',...
            %                                                                           '<property 1>', '<property 2>');
            
            % Explicitly shut tooltip off
            tooltip = '';
            
            group = propertyViewObject.createGroup( ...
                groupMessageId, ...
                groupMessageId, ...
                tooltip);
            
            group.addProperties(varargin{:});
            
            % by default, expand all groups
            group.Expanded = true;
        end
        
        function createCommonPropertyInspectorGroup(propertyViewObject, includePosition)
            % createCommonPropertyInspectorGroup function is responsible for
            % creating common property inspector groups that are shared across
            % all the components. The following are considered to be common
            % properties across all components: Font, Location, Enable, Visible,
            % Editable, HandleVisibility.
            %
            % includePosition - optional logical to explicitly include or
            %                   exclude the Position category
            %
            %                   true by default if not specified
            
            if(nargin == 1)
                includePosition = true;
            end
            
            import inspector.internal.CommonPropertyView;
            
            if(isprop(propertyViewObject, 'BackgroundColor'))
                CommonPropertyView.createFontAndColorGroup(propertyViewObject);
            else
                CommonPropertyView.createFontGroup(propertyViewObject);
            end                            
            
            
            CommonPropertyView.createInteractivityGroup(propertyViewObject);                                    
            
            if(includePosition)
                CommonPropertyView.createPositionGroup(propertyViewObject);
            end
            
            CommonPropertyView.createCallbackExecutionControlGroup(propertyViewObject);
            CommonPropertyView.createParentChildGroup(propertyViewObject);            
            
            % Note for future property support:
            %
            % Enable this group when 'Type' is supported
            %
            % CommonPropertyView.createIdentifiersGroup(propertyViewObject);                      			            
        end
        
        function createPanelPropertyGroups(propertyViewObject)
            % This creates common groups related to containers like Panel
            % and Button Group
            %
            % Because these components have slightly differently named
            % properties for color (ex: ForegroundColor), their groupings
            % are different
            
            import inspector.internal.CommonPropertyView;
            
            CommonPropertyView.createPropertyInspectorGroup(propertyViewObject, 'MATLAB:ui:propertygroups:ColorAndStylingGroup', ...
                'ForegroundColor',...
                'BackgroundColor',...
                'BorderType' ...
                );
            
            CommonPropertyView.createPropertyInspectorGroup(propertyViewObject, 'MATLAB:ui:propertygroups:FontGroup', ...
                'FontName', ...
                'FontSize',...
                'FontWeight', ...
                'FontAngle'...
                );
            
            CommonPropertyView.createInteractivityGroup(propertyViewObject);
            CommonPropertyView.createPositionGroup(propertyViewObject);
            CommonPropertyView.createCallbackExecutionControlGroup(propertyViewObject);
            CommonPropertyView.createParentChildGroup(propertyViewObject);
        end
        
        % List of functions to specific common property groups
        %
        % Should be used when createCommonPropertyInspectorGroup() is
        % making too broad of assumptions about what is "common" to all
        % components
        
        % Expanded Groups
        function createFontAndColorGroup(propertyViewObject)                        
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(propertyViewObject, 'MATLAB:ui:propertygroups:FontAndColorGroup', ...
                'FontName', ...
                'FontSize',...
                'FontWeight', ...
                'FontAngle',...
                'FontColor', ...
                'ForegroundColor',...
                'BackgroundColor'...      
                );            
        end       
        
        function createFontGroup(propertyViewObject)                        
            % This is used when there is no 'BackgroundColor            
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(propertyViewObject, 'MATLAB:ui:propertygroups:FontGroup', ...
                'FontName', ...
                'FontSize',...
                'FontWeight', ...
                'FontAngle',...
                'FontColor', ...
                'ForegroundColor'...                
                );            
        end                  
        
        % Non Expanded Groups
        function group = createInteractivityGroup(propertyViewObject)
            group = inspector.internal.CommonPropertyView.createPropertyInspectorGroup(propertyViewObject, 'MATLAB:ui:propertygroups:InteractivityGroup');
            
            group.addProperties('Visible');    
            
            % Conditionally add the property
            if(isprop(propertyViewObject, 'Multiselect'))            
                group.addProperties('Multiselect');
            end
            
            % Conditionally add the property
            if(isprop(propertyViewObject, 'Editable'))            
                group.addProperties('Editable');
            end
            
            group.addProperties('Enable');                                                            
            
            group.Expanded = false;
        end
                
        function group = createPositionGroup(propertyViewObject)
            
            group = propertyViewObject.createGroup( ...
                'MATLAB:ui:propertygroups:PositionGroup', ...
                'MATLAB:ui:propertygroups:PositionGroup', ...
                '');
            
            group.addEditorGroup('Position');
            
            group.Expanded = false;
        end
        
        function group = createParentChildGroup(propertyViewObject)
            % Note for future property support:
            %
            % For Parent and Child, the long term design would be
            % to have them here in this grouping, and send them to
            % client.  However, the infrastructure is not in place in
            % App Designer nor the Inspector widget to:
            % - know what to send to the peer nodes
            % - know how to handle an edit (if editing is even
            % supported)
            %
            %
            
            group = inspector.internal.CommonPropertyView.createPropertyInspectorGroup(propertyViewObject, 'MATLAB:ui:propertygroups:ParentChildGroup', ...
                'HandleVisibility' ...
                );
            
            group.Expanded = false;
        end
        
        function group = createCallbackExecutionControlGroup(propertyViewObject)
            
            group = inspector.internal.CommonPropertyView.createPropertyInspectorGroup(propertyViewObject, 'MATLAB:ui:propertygroups:CallbackExecutionControlGroup',...
                'Interruptible', ...
                'BusyAction' ...
                );
            
            group.Expanded = false;
        end
        
        function group = createOptionsGroup(propertyViewObject, titleCatalogId)
            
            group = propertyViewObject.createGroup( ...
                titleCatalogId, ...
                titleCatalogId, ...
                '');
            
            group.addEditorGroup('Value', 'Items');
            group.addProperties('ItemsData');
            group.Expanded = true;
        end
        
        
        
        
        % Note for future property support:
        %
        % Enable this group when 'Type' is supported
        %
        % Work involves ensuring that both VC and GBT components are
        % sending the value to the client, as well as ensuring it is read
        % only
        % function group = createIdentifiersGroup(propertyViewObject)
        %  group = inspector.internal.CommonPropertyView.createPropertyInspectorGroup(propertyViewObject, 'MATLAB:ui:propertygroups:IdentifiersGroup', ...
        %        'Type');
        %
        %    group.Expanded = false;
        % end
        
        % Component specific , but shared Groups
        
        function group = createTicksGroup(propertyViewObject)
            
            group = propertyViewObject.createGroup( ...
                'MATLAB:ui:propertygroups:TicksGroup', ...
                'MATLAB:ui:propertygroups:TicksGroup', ...
                '');
            
            group.addEditorGroup('MajorTicks','MajorTickLabels');
            group.addProperties('MinorTicks');
            
            
            group.addSubGroup( 'MajorTicksMode', 'MajorTickLabelsMode', 'MinorTicksMode');
            
            group.Expanded = true;
            
        end
    end
end
