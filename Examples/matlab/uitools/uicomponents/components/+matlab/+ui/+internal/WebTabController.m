% WEBTABCONTROLLER Web-based controller for UITab.
classdef WebTabController < matlab.ui.internal.controller.WebCanvasContainerController

  properties(Access = 'protected')
      positionBehavior
  end

  methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Constructor
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = WebTabController( model, varargin )

    % Super constructor
      obj = obj@matlab.ui.internal.controller.WebCanvasContainerController( model, varargin{:} );
      
      obj.positionBehavior = matlab.ui.internal.componentframework.services.optional.PositionBehaviorAddOn(obj.PropertyManagementService);
    end


    function add(obj, component, parentController)
    % add Adds this component to the view
    %    add(Controller, Component, ParentController) adds the Controller
    %    whose model is Component underneath the component who's controller
    %    is ParentController.
        add@matlab.ui.internal.controller.WebCanvasContainerController(obj, component, parentController);
        parentController.triggerUpdateOnDependentViewProperty('SelectedTab');
    end

    function attachPropertyListeners( obj )

        obj.EventHandlingService.attachPropertyListeners( @obj.handlePropertyUpdate, ...
                                                          @obj.handlePropertyDeletion );
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      updatePosition
    %
    %  Description: Method invoked when the model's Position property changes. 
    %
    %  Inputs :     None.
    %  Outputs:     
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function newPosValue = updatePosition( obj )
        % Always called at initialization
        % Does not seem to make any difference...
        % @TODO probably we need to investigate why the model sets the prop
        oneOriginPosValue = obj.Model.Position;
        newPosValue = obj.positionBehavior.updatePositionInPixels(oneOriginPosValue);
    end        
    
    
  end
  
  methods( Access = 'protected' )

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

    end
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      defineViewProperties
    %
    %  Description: Within the context of MVC ( Model-View-Controller )
    %               software paradigm, this is the method the "Controller"
    %               layer uses to define which properties will be consumed by
    %               the web-based user interface.
    %  Inputs:      None
    %  Outputs:     None
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function defineViewProperties( obj )

      % Add view properties specific to the panel, then call super
      obj.PropertyManagementService.defineViewProperty( 'BackgroundColor' );
      obj.PropertyManagementService.defineViewProperty( 'ForegroundColor' );
      obj.PropertyManagementService.defineViewProperty( 'Tag' );
      obj.PropertyManagementService.defineViewProperty( 'UserData' );
      obj.PropertyManagementService.defineViewProperty( 'Title' );
      obj.PropertyManagementService.defineViewProperty( 'TooltipString' );
      obj.PropertyManagementService.defineViewProperty( 'Enable' );
      obj.PropertyManagementService.defineViewProperty( 'AutoResizeChildren' );
      
      defineViewProperties@matlab.ui.internal.controller.WebCanvasContainerController( obj );
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

        defineRenamedProperties@matlab.ui.internal.controller.WebCanvasContainerController( obj );
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      defineRenamedProperties
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

        definePropertyDependencies@matlab.ui.internal.controller.WebCanvasContainerController( obj );
    end

    
    function handleEvent( obj, src, event )

        if( obj.EventHandlingService.isClientEvent( event ) )
            eventStructure = obj.EventHandlingService.getEventStructure( event );
            handled = obj.positionBehavior.handleClientPositionEvent( src, eventStructure, obj.Model );
            if (~handled)
                % Now, defer to the base class for common event processing
                handleEvent@matlab.ui.internal.controller.WebCanvasContainerController( obj, src, event );
            end

        end

    end      
    
  end

end
