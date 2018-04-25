% WEBTABGROUPCONTROLLER Web-based controller for UITabGroup.
classdef WebTabGroupController < matlab.ui.internal.componentframework.WebContainerController
  properties(Access = 'protected')
      positionBehavior
  end
    

  methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Constructor
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = WebTabGroupController( model, varargin )
        % Constructor

       obj = obj@matlab.ui.internal.componentframework.WebContainerController( model, varargin{:} );
       obj.positionBehavior = matlab.ui.internal.componentframework.services.optional.PositionBehaviorAddOn(obj.PropertyManagementService);

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      updateSelectedTab
    %
    %  Description: Method invoked when tab selection changes. In the model,
    %               selected tab is represented by the MCOS handle of the tab
    %               component. View representation is achieved through an
    %               identifier string corresponding to the tab.
    %
    %  Inputs :     None.
    %  Outputs:     Unique identifier representing the tab.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function selectedTab = updateSelectedTab( obj )
      
      selectedTab = '';
      if( ~isempty( obj.Model.SelectedTab ) )
        selectedTab = obj.Model.SelectedTab.getId();
      end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      updatePosition
    %
    %  Description: Method invoked when tab group position changes. 
    %
    %  Inputs :     None.
    %  Outputs:     
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function newPosValue = updatePosition( obj )
        newPosValue = obj.positionBehavior.updatePosition(obj.Model);
    end        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      handlePropertyUpdate
    %
    %  Description: Custom handler for property updates.
    %
    %  Inputs :     event -> Event payload.
    %  Outputs:     None.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function handlePropertyUpdate( obj, ~, event )
        
        % Handle property updates from the client
        if( obj.EventHandlingService.isClientEvent( event ) )
            
            % Determine to updated property using the EHS and then custom handle.
            switch ( obj.EventHandlingService.getUpdatedProperty( event ) )
                
                case 'SelectedTab'
                    selectedTab = obj.EventHandlingService.getProperty( 'SelectedTab' );
                    newSelectedTabHandle = obj.findModelFromChildId( selectedTab );
                    if ~isempty(newSelectedTabHandle) %g1411634
                        oldSelectedTabHandle = obj.Model.SelectedTab;
                        obj.Model.SelectedTab = newSelectedTabHandle;
                        obj.Model.notifySelectionChanged(oldSelectedTabHandle, newSelectedTabHandle);
                    else
                        % update PN with correct SelectedTab id from model.
                        obj.triggerUpdateOnDependentViewProperty('SelectedTab');
                    end
                otherwise
                    %event
            end
        end
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

        % Attach all property listeners
        obj.EventHandlingService.attachPropertyListeners( @obj.handlePropertyUpdate, ...
                                                          @obj.handlePropertyDeletion );

        % Attach listeners for child additions and/or deletions
        obj.EventHandlingService.attachChildListeners( @obj.handleChildAddition, ...
                                                       @obj.handleChildDeletion );

        % Attach a listener for events
        obj.EventHandlingService.attachEventListener( @obj.handleEvent );

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      handlePropertyDeletion
    %
    %  Description: Custom handler for property deletions.
    %
    %  Inputs :     event -> Event payload.
    %  Outputs:     None.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function handlePropertyDeletion( ~, ~, ~ )
       % Noop
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      handleChildAddition
    %
    %  Description: Custom handler for child additions.
    %
    %  Inputs :     event -> Event payload.
    %  Outputs:     None.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function handleChildAddition( ~, ~, ~ )
       % Noop
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      handleChildDeletion
    %
    %  Description: Custom handler for child deletions.
    %
    %  Inputs :     event -> Event payload.
    %  Outputs:     None.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function handleChildDeletion( ~, ~, ~ )
       % Noop
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function defineViewProperties( obj )

      % Define view properties for the tab group
      obj.PropertyManagementService.defineViewProperty( 'SelectedTab' );
      obj.PropertyManagementService.defineViewProperty( 'TabLocation' );
      obj.PropertyManagementService.defineViewProperty( 'Enable' );
      obj.PropertyManagementService.defineViewProperty( 'Visible' );
      obj.PropertyManagementService.defineViewProperty( 'HandleVisibility' );
      obj.PropertyManagementService.defineViewProperty( 'AutoResizeChildren' );
      defineViewProperties@matlab.ui.internal.componentframework.WebContainerController( obj );

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function defineRenamedProperties( obj )
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function definePropertyDependencies( obj )

       % Define property dependencies specific to the table, then call super
       obj.PropertyManagementService.definePropertyDependency( 'SelectedTab', ...
                                                               'SelectedTab' );
%        obj.PropertyManagementService.definePropertyDependency( 'Position_I', ...
%                                                                'Position' );
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      handleEvent
    %
    %  Description: Custom handler for events.
    %
    %  Inputs :     event -> Event payload.
    %  Outputs:     None.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function handleEvent( obj, src, event )

      % Handle events
      if( obj.EventHandlingService.isClientEvent( event ) )
            
          eventStructure = obj.EventHandlingService.getEventStructure( event );
          handled = obj.positionBehavior.handleClientPositionEvent( src, eventStructure, obj.Model );
          if (~handled)
              % Now, defer to the base class for common event processing
              handleEvent@matlab.ui.internal.componentframework.WebContainerController( obj, src, event );
          end
      end

    end

  end

end
