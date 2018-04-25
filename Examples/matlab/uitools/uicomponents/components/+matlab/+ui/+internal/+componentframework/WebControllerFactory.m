classdef WebControllerFactory < matlab.ui.internal.componentframework.services.optional.ControllerInterface

%   Copyright 2014-2017 The MathWorks, Inc.
    
    % WEBCONTROLLERFACTORY is the factory class which creates controllers for new components
    %                      that are being integrated into the Handle Graphics (HG) hierarchy.
    %                      Integration imposes certain API restrictions on the components.
    %                      Restrictions pertaining to controller creation is validated by the
    %                      "checkPreconditions" method.
    properties (Access = private)
        Model
    end
    
    methods( Access = 'protected' )
        
        % Function which validates the preconditions required by the "createController" method.
        %
        % Error message is displayed explicitly prior to the "error" call, because when the request
        % to create a controller is made through an "omCallMethod" invocation, specific error message
        % is not displayed, unless done explicitly.
        function checkPreconditions( ~, component, parentController, nArguments )
            
            % Number of input arguments to the "createController" function is 3.
            if( nArguments ~= 3 )
                error( message( 'MATLAB:class:InvalidArgument', 'WebControllerFactory:create', 'nargin' ) );
            end
            
            % Component utilizing this factory class needs to be a WebComponent, otherwise
            % the polymporphic code base established by the Component Framework will not be
            % exercised.
            if( ~isa( component, 'matlab.ui.control.Component' ) )
                error( message('MATLAB:class:InvalidSuperclassName') );
            end
            
            
            % Check base class for Parent controller. 
            % Needs to be a derived class of WebController or
            % ComponentController            
            if isa( component, 'matlab.ui.Figure')
                % Exception has been made for the UI figure.
            else
                if ( ~isa( parentController, 'matlab.ui.internal.componentframework.WebController' ) && ...
                    ~isa( parentController, 'matlab.ui.control.internal.controller.ComponentController' ))                    
                    error( message('MATLAB:class:InvalidSuperclassName') );
                end
            end
        end
        
        % Function which clears the controller object of the model.
        %
        % For web component's of composite nature ( containers ), the function recursively
        % clears the children controllers.
        function clearController( obj, component )
            
            % Get controller information through extended access provided
            controller = component.getControllerHandle;
            if( ~isempty( controller ) && isvalid( controller ) )
                delete( controller );
            end
            
            % Recursively clear controllers for children
            if( isprop( component, 'Children' ) )
                children = allchild(component);
                if( ~isempty( children ) )
                    for child=1:numel( children )
                        obj.clearController( children(child) );
                    end
                end
            end
        end
        
    end
    
    methods( Access = 'public' )
        
        % Basic constructor
        function obj = WebControllerFactory( model )
            obj.Model = model;
        end
        
        % This method which enables the creation of controllers gets invoked through an
        % "omCallMethod" invocation. Upon execution, the first step the function takes is to
        % validate the preconditions imposed by the Component Framework. Please refer to
        % "checkPreConditions" method for details.
        function create(  obj, component, parent )
            
            % Create the controller, after checking the preconditions.
            % If the parent is empty, clear the controller of the web component.
            if( ~isempty( parent ) )
                parentController = parent.getControllerHandle;
                checkPreconditions( obj, component, parentController, nargin );
                try
                    component.createController( parentController, [] );
                catch ME
                    if strcmp(ME.identifier, 'MATLAB:class:InvalidHandle') ...
                            && ~isvalid(obj)
                        % Ignoring this one exception - Under some
                        % conditions (e.g. if a component is deleted during
                        % a drawnow callback before it is fully created)
                        % the component (and its controller) can be already
                        % deleted before this code is reached.
                        %
                        % Therefore, swallow this exception and silently
                        % return.
                    else
                        rethrow(ME);
                    end
                end
            else
                obj.clearController( component );
            end
            
        end
        
    end
    
end
