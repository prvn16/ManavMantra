classdef WebMenuController < matlab.ui.internal.componentframework.WebContainerController
    %WEBMENUCONTROLLER Web-based controller for UIMenu.
        
    properties
    end
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Constructor
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = WebMenuController( model, varargin  )
            obj = obj@matlab.ui.internal.componentframework.WebContainerController( model, varargin{:} );
        end
        
    end
    
    methods ( Access = 'protected' )
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      postAdd
        %
        %  Description: Custom method for controllers which gets invoked after the
        %               addition of the web component into the view hierarchy.
        %
        %  Inputs :     None.
        %  Outputs:     None.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function postAdd( obj )

            % Attach a listener for events
            obj.EventHandlingService.attachEventListener( @obj.handleEvent );

        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:       handleEvent
        %
        %  Description:  handle the MenuItemClicked event from the client
        %
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function handleEvent( obj, src, event )

            if( obj.EventHandlingService.isClientEvent( event ) )
                
                eventStructure = obj.EventHandlingService.getEventStructure( event );
                switch ( eventStructure.Name )
                    case 'MenuItemClicked'
                        obj.fireActionEvent();
                    otherwise
                        % Now, defer to the base class for common event processing
                        handleEvent@matlab.ui.internal.componentframework.WebComponentController( obj, src, event );
                end    
                
            end
            
        end
        
        % Call a custom c++ method to fire action callback in GBT event chain
        function fireActionEvent(obj)
            obj.Model.handleActionEventFromClient();
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      defineViewProperties
        %
        %  Description: Within the context of MVC ( Model-View-Controller )
        %               software paradigm, this is the method the "Controller"
        %               layer uses to define which properties will be consumed by
        %               the web-based buser interface.
        %  Inputs:      None
        %  Outputs:     None
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineViewProperties( obj )

            % Add view properties specific to the menu,
            obj.PropertyManagementService.defineViewProperty( 'Label' );
            obj.PropertyManagementService.defineViewProperty( 'Checked' );
            obj.PropertyManagementService.defineViewProperty( 'Enable' );
            obj.PropertyManagementService.defineViewProperty( 'ForegroundColor' );
            obj.PropertyManagementService.defineViewProperty( 'Visible' );
            obj.PropertyManagementService.defineViewProperty( 'Separator' );
			obj.PropertyManagementService.defineViewProperty( 'Accelerator' );
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      defineRenamedProperties
        %
        %  Description: Within the context of MVC ( Model-View-Controller )
        %               software paradigm, this is the method the "Controller"
        %               layer uses to rename properties, which has been defined
        %               by the "Model" layer.
        %  Inputs:      None
        %  Outputs:     None
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function defineRenamedProperties( obj )
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        %  Method:      definePropertyDependencies
        %  Description: Within the context of MVC ( Model-View-Controller )
        %               software paradigm, this is the method the "Controller"
        %               layer uses to establish property dependencies between
        %               a property (or set of properties) defined by the "Model"
        %               layer and dependent "View" layer property.
        %  Inputs:      None
        %  Outputs:     None
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function definePropertyDependencies( obj )
        end
        
    end
    
end


