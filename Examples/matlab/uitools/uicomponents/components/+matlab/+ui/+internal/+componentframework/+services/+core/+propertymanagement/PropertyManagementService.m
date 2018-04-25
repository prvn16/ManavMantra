% PROPERTYMANAGEMENTSERVICE As a core service of the MATLAB Component Framework
% (MCF), the Property Management Service (PMS) is designed to configure model
% properties of web components and how they are reflected in the view.

%   Copyright 2014-2015 The MathWorks, Inc.

classdef PropertyManagementService < handle
    
  properties ( Access = 'protected' )
        
     % Database of renamed properties
     RenamesMap

     % Database of dependencies
     DependenciesMap
        
     % Reverse dependency database
     ReverseDependenciesMap

     % Database of view properties 
     ViewPropertiesCell

  end

  methods ( Access = 'public' )

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         Constructor
    %  Postconditions: Initialized property configurations, including the list 
    %                  of view properties, renames and dependencies.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = PropertyManagementService()
       % Constructor for the Property Management Service (PMS), which is a core
       % service of the MATLAB Component Framework (MCF).

       % Intialize the database which keeps track of renamed properties
       obj.RenamesMap = containers.Map();

       % Initialize the database which keeps track of dependencies
       obj.DependenciesMap = containers.Map();
        
       % Initializes the database of reverse dependencies
       obj.ReverseDependenciesMap = containers.Map();

       % Initialize view properties database
       obj.ViewPropertiesCell = {};
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         defineViewProperty
    %  Inputs:         property -> Name of view property.
    %  Outputs:        None.
    %  Postconditions: Initialized property configurations, including the list 
    %                  of view properties, renames and dependencies.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function defineViewProperty( obj, property )
       % MATLAB Component Framework's (MCF) Property Management Service (PMS) 
       % provides the ability to control which model properties will participate
       % in the view representation of the web component. This method provides
       % the interface to achieve this capability.
       obj.ViewPropertiesCell = [ obj.ViewPropertiesCell, { property } ];
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         getViewProperties
    %  Inputs:         None.  
    %  Outputs:        viewPropertiesCell -> List of view properties.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function viewPropertiesCell = getViewProperties( obj )
       % Method which retrieves all the view properties from the list maintained
       % by the Property Management Service.
       viewPropertiesCell = obj.ViewPropertiesCell;    
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         defineRenamedProperty
    %
    %  Inputs :        modelName -> Name of the property on the model side.   
    %                  viewName  -> Name of the property on the view side.
    %  Outputs:        None.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function defineRenamedProperty( obj, modelName, viewName )
       % MATLAB Component Framework's (MCF) Property Management Service (PMS) 
       % provides the ability to rename model properties on the view. This    
       % method provides the interface to achieve this capability.
       obj.RenamesMap( modelName ) = viewName;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         hasRename
    %
    %  Inputs :        property -> Name of the property on the model side.   
    %  Outputs:        Boolean which indicates if the property has been renamed.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function isRenamed = hasRename( obj, property )
       % Returns a boolean to indicate if the model property has been renamed on
       % the view.
       isRenamed = obj.RenamesMap.isKey( property );
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         getRename
    %
    %  Inputs :        property -> Property for which the rename is returned.
    %  Outputs:        rename -> Rename of the model property. 
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function rename = getRename( obj, property )
       % Returns the rename of the model property provided.
       rename = obj.RenamesMap( property );
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         definePropertyDependency
    %
    %  Details:        When a model side property is set, using the PMS, the   
    %                  controller logic updates the dependent view side property
    %                  using a "custom update" method defined in the controller
    %                  of the web component.
    %
    %                  If for a given model side property more than one 
    %                  dependency is established using the PMS, upon the setting
    %                  of the model side property, every single dependent view
    %                  side property is updated. 
    %
    %  Inputs:         property -> Name of the property on the model side.   
    %                  dependentProperty  -> Name of the dependent property.
    %  Outputs:        None.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function definePropertyDependency( obj, property, dependentProperty )
       % MATLAB Component Framework's (MCF) Property Management Service (PMS) 
       % provides the ability to define property dependencies which impact the    
       % view. This method provides the interface to achieve this capability.
 
       % If the model side property already have a dependency, add to it,
       % otherwise create a new dependency
       if obj.DependenciesMap.isKey( property ) 
          obj.DependenciesMap( property ) = ... 
            [ obj.DependenciesMap( property ) , dependentProperty ];
          else
             obj.DependenciesMap( property ) = { dependentProperty };
       end

       % Now establish reverse lookup capability 
       if obj.ReverseDependenciesMap.isKey( dependentProperty ) 
          obj.ReverseDependenciesMap( dependentProperty ) = ... 
            [ obj.ReverseDependenciesMap( dependentProperty ) , property ];
       else
          obj.ReverseDependenciesMap( dependentProperty ) = { property };
       end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         hasDependency
    %
    %  Inputs:         property -> Name of the model side property. 
    %  Outputs:        bool -> Boolean which indicates if the given property has
    %                          a property dependency.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function bool = hasDependency( obj, property )
       % Method which returns a boolean to indicate if the model property has a
       % dependency.
       bool = obj.DependenciesMap.isKey( property );
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         hasReverseDependency
    %
    %  Inputs:         property -> Name of the view property.            
    %  Outputs:        bool -> Boolean which determines if the given property 
    %                          has a reverse dependency.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function bool = hasReverseDependency( obj, property )
       % Method which returns a boolean to indicate if the view property has a
       % reverse dependency.
       bool = obj.ReverseDependenciesMap.isKey( property );
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         getDependencies
    %
    %  Inputs:         property -> Name of the model property. 
    %  Outputs:        dependentProperties -> Cell containing the dependencies            
    %                                         for a given model side property.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     function dependentProperties = getDependencies( obj, property )
        % Method which returns a cell containing a list of dependencies for a 
        % given model side property.
        dependentProperties = obj.DependenciesMap( property );
     end
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         getReverseDependencies
    %
    %  Inputs:         property -> Name of the view property. 
    %  Outputs:        sourceProperties -> Cell containing the dependencies            
    %                                      for a given view side property.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function sourceDependencies = getReverseDependencies( obj, property )
       % Method which returns the reverse dependency mapping for a given view
       % property.
       sourceDependencies = obj.ReverseDependenciesMap( property );
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         definePvPairs
    %
    %  Inputs:         model -> Model representation of the component.
    %  Outputs:        pvPairs -> Property/value pairs for the view properties.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function pvPairs = definePvPairs( obj, model )
       % MATLAB Component Framework's (MCF) Property Management Service (PMS) 
       % provides the ability to create property/value pairs based on the view 
       % properties and the renames previously defined through the service. This
       % method provides the interface to achieve this capability.

       % Start constructing the property value pairs
       pvPairs = {};
       for idx = 1:numel( obj.ViewPropertiesCell )  

         % Take into account renames
         propertyName = obj.ViewPropertiesCell( idx ); 
         if( obj.RenamesMap.isKey( propertyName{1} ) )
            nameAfterLookup = obj.RenamesMap( propertyName{1} );
         else
            nameAfterLookup = propertyName{1};
         end
             
         % Now retrieve property value
         propertyValue = '';
         if isprop( model, propertyName{1} )
            propertyValue = model.( propertyName{1} );
         end

         % Aggregate to the PV pairs
         pvPairs = [ pvPairs, { nameAfterLookup, propertyValue } ];

       end
         
    end
       
  end

  methods( Static )     

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:         convertPvPairsToStruct
    %
    %  Inputs:         pvPairs -> Property/value pairs to be converted.
    %  Outputs:        structFormat -> MATLAB structure for the PV pairs.      
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function structFormat = convertPvPairsToStruct( pvPairs )
       % Converts the PV pairs into MATLAB structure.
       structFormat = appdesservices.internal.peermodel.convertPvPairsToStruct( pvPairs );
    end

  end
    
end
