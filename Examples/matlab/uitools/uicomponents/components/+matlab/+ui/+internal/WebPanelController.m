% WEBPANELCONTROLLER Web-based controller for UIPanel.
classdef WebPanelController < matlab.ui.internal.controller.WebCanvasContainerController
  properties(Access = 'protected')
      positionBehavior
  end

  methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Constructor
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = WebPanelController( model, varargin  )

       % Super constructor
       obj = obj@matlab.ui.internal.controller.WebCanvasContainerController( model, varargin{:} );
       
       obj.positionBehavior = matlab.ui.internal.componentframework.services.optional.PositionBehaviorAddOn(obj.PropertyManagementService);

    end
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      newFontSize
    %
    %  Description: Custom method to set newFontSize.
    %
    %  Outputs:     newFontSize struct-> on the Web Panel peernode
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function newFontSize = updateFontSize( obj )
        newFontSize = '';
        % using try catch as this is special case for the charts
        % as charts does not have the FontUnits property which need to be
        % ignored, need to investigate and come up with better option of
        % using the WebPanelController for the charts
        try
            value = struct('FontSize', obj.Model.FontSize, 'FontUnits', obj.Model.FontUnits);
            newFontSize = value;
        catch e %#ok<NASGU>

        end
    end
    
    function newBorderVisibility = updateBorderVisibility( obj )
        newBorderVisibility = '';
        % using try catch as this is special case for the charts
        % as charts does not have the FontUnits property which need to be
        % ignored, need to investigate and come up with better option of
        % using the WebPanelController for the charts
        try
            value = obj.Model.BorderType;
            if(isequal(value, 'none'))
                value = false;
            else
                value = true;
            end  
            newBorderVisibility = value;
        catch e %#ok<NASGU>
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      updatePosition
    %
    %  Description: Method invoked when panel position changes. 
    %
    %  Inputs :     None.
    %  Outputs:     
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function newPosValue = updatePosition( obj )
        oneOriginPosValue = obj.Model.Position;
        newPosValue = obj.positionBehavior.updatePositionInPixels(oneOriginPosValue);
    end        
    
    
  end

  methods( Access = 'protected' )

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
        obj.PropertyManagementService.defineViewProperty( 'Title' );
        obj.PropertyManagementService.defineViewProperty( 'TitlePosition' );
        obj.PropertyManagementService.defineViewProperty( 'Visible' );
        obj.PropertyManagementService.defineViewProperty( 'BorderVisibility' );
        obj.PropertyManagementService.defineViewProperty( 'BackgroundColor' );
        obj.PropertyManagementService.defineViewProperty( 'ForegroundColor' );
        obj.PropertyManagementService.defineViewProperty( 'FontAngle' );
        obj.PropertyManagementService.defineViewProperty( 'FontName' );
        obj.PropertyManagementService.defineViewProperty( 'FontSize' );
        obj.PropertyManagementService.defineViewProperty( 'FontWeight' );
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

       % Define renamed properties specific to the table, then call super
       obj.PropertyManagementService.defineRenamedProperty( 'FontAngle_I',  'FontAngle');
       obj.PropertyManagementService.defineRenamedProperty( 'FontName_I',  'FontName');
       obj.PropertyManagementService.defineRenamedProperty( 'FontWeight_I',  'FontWeight');
       obj.PropertyManagementService.defineRenamedProperty( 'FontSize_I',  'FontSize');
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
        obj.PropertyManagementService.definePropertyDependency('FontSize', 'FontSize');
        obj.PropertyManagementService.definePropertyDependency('FontSize_I', 'FontSize');
        obj.PropertyManagementService.definePropertyDependency('BorderType','BorderVisibility');
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
