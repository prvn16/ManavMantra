% WEBBUTTONGROUPCONTROLLER Web-based controller for ButtonGroup.
classdef WebButtonGroupController < matlab.ui.internal.WebPanelController

  methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Constructor
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function obj = WebButtonGroupController(  model, varargin )

       % Super constructor
       obj = obj@matlab.ui.internal.WebPanelController(  model, varargin{:} );

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %  Method:      updateSelectedObject
    %
    %  Description: Method invoked when child selection changes. In the model,
    %               selected object is represented by the MCOS handle of the child
    %               component. View representation is achieved through an
    %               identifier string corresponding to the tab.
    %
    %  Inputs :     None.
    %  Outputs:     Unique identifier representing the tab.
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function selectedObject = updateSelectedObject( obj )

      selectedObject = '';
      if( ~isempty( obj.Model.SelectedObject ) )
        selectedObject = obj.Model.SelectedObject.ButtonId;
      end

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
      defineViewProperties@matlab.ui.internal.WebPanelController( obj );
      
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
       defineRenamedProperties@matlab.ui.internal.WebPanelController( obj );

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

       % Define property dependencies specific to the table, then call super
       definePropertyDependencies@matlab.ui.internal.WebPanelController( obj );
       
    end
 
  end
  
end

