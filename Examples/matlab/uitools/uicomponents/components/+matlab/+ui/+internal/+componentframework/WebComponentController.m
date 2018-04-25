% WEBCOMPONENTCONTROLLER Base class for all MATLAB Component Framework (MCF)
% web-based component controllers. Captures commonalities across all web-based
% component controllers in terms of the use of MCF services, such as the          
% Property Management Service (PMS) and the Event Handling Service (EHS).

%   Copyright 2013-2017 The MathWorks, Inc.

classdef WebComponentController < ...
               matlab.ui.internal.componentframework.WebController & ...
               matlab.ui.internal.componentframework.services.optional.ControllerInterface

  methods ( Access = 'public' )

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %
     %  Method:       Constructor
     %
     %  Inputs:       model -> Model MCOS object for the web component.
     %                varargin{1} -> Parent controller.
     %                varargin{2) -> View.
     %
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     function obj = WebComponentController( model, varargin )
        % MCF's web-based controller constructor for all web-based controllers,
        % which utilize the services provided by the MCF, such as the PMS and 
        % the EHS.

        % Input verification
        % Call the base class constructor
        obj = obj@matlab.ui.internal.componentframework.WebController();
        obj.Model = model;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:       hasView
    %
    %  Input :       None. 
    %  Output:       Boolean indicating if the controller contains the view     
    %                element of the web component within the view hierarchy.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function viewExists = hasView( obj )
        % Returns a boolean indicating if the controller contains the view     
        % element of the web component within the view hierarchy. Existence of 
        % the view element does not guarantee the readiness of the view.
        viewExists = obj.EventHandlingService.hasView();
    end
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:       add
    %        
    %  Inputs :      model -> Web component for which the MCF will create a view 
    %                element.
    %                parentController -> Parent's controller.  
    %  Outputs:      None.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function add( obj, ~, parentController )
        % Adds web component's view element into the view hierarchy previously 
        % established by the MATLAB Component Framework (MCF). This method uses
        % MCF's Property Management Service to create an initial set of view
        % properties.
 
        % Retrieve the peer node of the parent
        obj.ParentController = parentController;
        parentView = obj.getParentView( parentController );

        % Create property/value (PV) pairs and convert them to java map
        pvPairs = obj.PropertyManagementService.definePvPairs( obj.Model );
        map = obj.EventHandlingService.convertPvPairsToJavaMap( pvPairs );

        % Add this web component as a child to the peer node hierarchy
        obj.createView( parentController, parentView, map );

        % Have the EHS attach to the view
        obj.EventHandlingService.attachView( obj.ProxyView );

        % For applicable view properties which participate in dependencies with
        % model properties, trigger the customized update methods.  
        obj.triggerUpdatesOnDependentViewProperties;

        % Post add operation
        obj.postAdd();
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:       triggerUpdatesOnDependentViewProperties
    %
    %  Input :       None. 
    %  Output:       None.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function triggerUpdatesOnDependentViewProperties( obj , varargin)
        % This method triggers the recomputation of property values which are 
        % dependent on other model properties. This is achieved through the 
        % mechanism provided by MCF's Property Mamagement Service.
        viewPropertiesCell = obj.PropertyManagementService.getViewProperties;
        
        % exception list for updating dependent view properties.
        if nargin == 2
            except = varargin{1};
        else
            except = {};
        end
        
        for idx = 1:numel(viewPropertiesCell)  
 
          property = viewPropertiesCell( idx ); 
          name = char( property );
          
          if ismember(name, except) 
              continue; %skip update for given except list.
          end
          
          if obj.PropertyManagementService.hasRename( property ) 
            name = obj.PropertyManagementService.getRename( char(property) );
          end
          if( obj.PropertyManagementService.hasReverseDependency( name ) )
              obj.triggerUpdateOnDependentViewProperty( name );
          end

        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:       triggerUpdateOnDependentViewProperty
    %
    %  Details:      Method which triggers update methods on view properties  
    %                which depend on other model properties. Method iterates
    %                overall all view properties.
    %            
    %  Input :       None. 
    %
    %  Output:       None.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function triggerUpdateOnDependentViewProperty( obj, property )
        % This method triggers the recomputation of a property value which is 
        % dependent on other model properties. This is achieved through the 
        % mechanism provided by MCF's Property Mamagement Service.
        value =  feval( eval( [ '@obj.update' property ] ) );
        obj.EventHandlingService.setProperty( property, value );
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:       setProperty
    %
    %  Inputs:       property -> Name of the model side property.      
    %  Outputs:      None. 
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function setProperty( obj, property )
        % Using MCF's Property Management Service, this method updates the 
        % the view representation of the web component, when a model side
        % property is set. During update, any property renames and/or property
        % dependencies will be taking into account.
 
        % Account for property dependencies using the PMS. 
        if obj.PropertyManagementService.hasDependency( property ) 
               
          % Lookup dependent properties first
          dependentProperties = ...
              obj.PropertyManagementService.getDependencies( property );
               
          % Iterate through dependencies and invoke the corresponding
          % custom "update" method.
          for idx=1:numel( dependentProperties ) 
            obj.triggerUpdateOnDependentViewProperty( dependentProperties{idx} );
          end

        % Account for property renames using the PMS. 
        elseif obj.PropertyManagementService.hasRename( property ) 

          % First get the view side name of the property
          renamedProperty = ...
             obj.PropertyManagementService.getRename( property );

          % Now set the property
          obj.EventHandlingService.setProperty( renamedProperty, ...
                                                obj.Model.get( property ) );

        % Standard property setting
        else

          % Set the property only if it exists on the peer node
          % to avoid creating new properties
          if obj.EventHandlingService.hasProperty( property ) 
              obj.EventHandlingService.setProperty( property, ...
                obj.Model.get( property ) );
          end

        end

       % Customizable post set operation
       obj.postSet( property );
            
     end
      
    function sendACT( obj, act)
        if ~isempty(obj.ProxyView) 
            hm = java.util.HashMap;
            hm.put('Name','actRequest');
            hm.put('ACT',act);
            obj.ProxyView.PeerNode.dispatchPeerEvent('actRequest', obj.ProxyView.PeerNode, hm)
        end
    end
  end
  
  methods ( Access = 'protected' )

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:       postAdd
    %
    %  Inputs:       None. 
    %  Outputs:      None. 
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function postAdd( obj )
        % Customizable method provided by the MATLAB Component Framework (MCF)
        % that will be invoked after the web component's view representation is
        % added to the hierarchy.

        % Noop default implementation
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:       postSet
    %
    %  Inputs:       property -> Name of the model property which will be set. 
    %  Outputs:      None. 
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function postSet( ~, ~ )
       % Customizable method provided by the MATLAB Component Framework (MCF)
       % that will be invoked after to the setting of the property. 

       % Noop default implementation
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:       handleEvent
    % 
    %  Details:      MCF provides this customizable event handling method per
    %                web component. Specialization of this method can be 
    %                implemented in the web-based controller corresponding to
    %                the web component.
    %
    %  Inputs:       src -> Source of the event.                            
    %                event -> Event payload.
    %  Outputs:      None. 
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function handleEvent( obj, ~, event )
       % Customizable event handling method provided by the Event Handling
       % Service (EHS), which is a core service of the MATLAB Component 
       % Framework (MCF).
       if obj.EventHandlingService.isClientEvent( event ) 
          eventStructure = obj.EventHandlingService.getEventStructure( event );

          switch ( eventStructure.Name )
            case 'viewReady'
              obj.Model.setViewReady( true );
              notify( obj.Model, 'ViewReady' );
            otherwise
              %Noop
          end

        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:       getParentView
    %
    %  Inputs:       parentController -> Parent's web controller which contains        
    %                                    the view representation for the parent.
    %  Outputs:      parentViewElement -> Parent view representation.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function parentView = getParentView( ~, parentController )
       % Retrieves the view element of the parent component, if applicable.
       % The base implementation pulls it off the parent controller.
       parentView = parentController.ProxyView.PeerNode;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:       createView
    %
    %  Inputs:       parentController -> Parent's web controller which contains        
    %                                    the view representation for the parent.
    %                parentViewElement -> Parent view representation.
    %                pvPairsMap -> Java map for the PV pairs.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function createView( obj, parentController, parentView, pvPairsMap )
       % This method creates the view element for the web component, given the
       % parent information. This base implementation assumes that the given
       % parent view representation is not empty, but subclasses could accept
       % empty parent view representations when creation new PeerModelManagers.
       obj.ProxyView.PeerNode = ...
               parentView.addChild( class( obj.Model ), pvPairsMap );

       obj.ProxyView.PeerModelManager = ...
              parentController.ProxyView.PeerModelManager;
    end

  end
  
  methods(Access = {?matlab.ui.internal.componentframework.services.optional.ControllerInterface})
      function setParentController(obj, newParentController)
          % SETPARENTCONTROLLER(obj)
          % Method to set the parent controller
          obj.ParentController = newParentController;
      end
      
      function eventHandlingService = getEventHandlingService(obj)
          eventHandlingService = obj.EventHandlingService;
      end
      
      function propertyManagementService = getPropertyManagementService(obj)
          propertyManagementService = obj.PropertyManagementService;
      end
  end
        
end
  
