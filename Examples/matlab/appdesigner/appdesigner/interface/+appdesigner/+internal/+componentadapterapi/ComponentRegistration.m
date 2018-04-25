classdef ComponentRegistration < handle
% 
%ComponentRegistration  An interface to provide information about a component 
%    The ComponentRegistration class is an interface component authors
%    will implement to provide the App Designer with information
%    about a component
%
%    ComponentRegistration methods:
%        getComponentType - the component type.  Must be unique
%        getJavaScriptAdapter - the client side adapter's module
%        getComponentDesignTimeDefaults - structure of component default values
%                                        to be used on the client
%        getComponentRuntimeDefaults - structure of run time component default values

%    Copyright 2013 The MathWorks, Inc.
%

    methods(Static,Abstract)   
        
        %getComponentType  Return the component's type
        %    type = getComponentType() will return the type
        %    of the component that is integrated into the AppDesigner.
        %
        %    The return value must be unique among all components so an
        %    example would be the concatenation of the component's 
        %    package and class name
        %
        %    Example:  
        %       type = 'matlab.ui.control.AngularGauge'
        type = getComponentType()
        
        %getJavaScriptAdapter  Return the client side adapter's module
        %
        %    adapter = getJavaScriptAdapter will return the module name of
        %    the adapter to be used on the client.
        %
        %    The return value should be the name of the module as it would
        %    need to be loaded by the Dojo loader.
        %
        %    Example:
        %       adapter = 'visualcomponents\adapters\AngularGaugeAdapter'                
        adapter = getJavaScriptAdapter() 
    end
    
    methods(Abstract)
        % getComponentDesignTimeDefaults  Return a pvPair array of design-time
        %                                 component default
        
        %    pvPairs = getComponentDesignDefaults will return a pvPair array of
        %              component default values
        %
        pvPairs = getComponentDesignTimeDefaults(obj)
        
        % getComponentRunTimeDefaults  Return a pvPair array of run-time 
        %                              component default values 
        
        %    pvPairs = getComponentRunTimeDefaults will return a pvPair array of
        %              component default values
        %
        pvPairs = getComponentRunTimeDefaults(obj)
    end
end


