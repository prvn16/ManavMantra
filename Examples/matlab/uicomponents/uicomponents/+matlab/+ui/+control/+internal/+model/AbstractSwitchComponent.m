classdef (Hidden) AbstractSwitchComponent < ...
        matlab.ui.control.internal.model.AbstractStateComponent & ...        
        matlab.ui.control.internal.model.mixin.PositionableComponent & ...
        matlab.ui.control.internal.model.mixin.FontStyledComponent 
        
    
    % This undocumented class may be removed in a future release.
    
    % Copyright 2011-2015 The MathWorks, Inc.
    
    properties(Dependent)
        
        Orientation = 'horizontal';
        
    end
    
    properties(Access= {
            ?matlab.ui.control.internal.model.AbstractSwitchComponent, ... % give access to subclasses
            ?appdesservices.internal.interfaces.model.AbstractModel, ...
            ?appdesservices.internal.interfaces.model.AbstractModelMixin})
        % Internal properties
        %
        % These exist to provide:
        % - fine grained control to each properties
        % - circumvent the setter, beacuse sometimes multiple properties
        %   need to be set at once, and the object will be in an
        %   inconsistent state between properties being set
        
        PrivateOrientation = 'horizontal';
        
    end
    
    % ---------------------------------------------------------------------
    % Constructor
    % ---------------------------------------------------------------------
    methods
        function obj = AbstractSwitchComponent(defaultOrientation)
            narginchk(1,1);
                    
            % All switches have exactly 2 states
            sizeConstraints = [2, 2];
            
            obj = obj@matlab.ui.control.internal.model.AbstractStateComponent(...
                sizeConstraints);
                        
            % Selection strategy for the switches is always ExactlyOne
            obj.SelectionStrategy = matlab.ui.control.internal.model.ExactlyOneSelectionStrategy(obj);
            
            % All switches have the same default values for Items
            obj.Items = {  getString(message('MATLAB:ui:defaults:falseStateLabel')), ... 
                            getString(message('MATLAB:ui:defaults:trueStateLabel')) }; 
            
            obj.Value = getString(message('MATLAB:ui:defaults:falseStateLabel'));
            
            % Switches have specific default values for properties            
            obj.PrivateOrientation = defaultOrientation;
            
        end
    end
    
    % ---------------------------------------------------------------------
    % Property Getters / Setters
    % ---------------------------------------------------------------------
    methods
        
        function set.Orientation(obj, orientation)
            oldOrientation = obj.Orientation;
            
            % Error Checking
            try
                newOrientation =  matlab.ui.control.internal.model.PropertyHandling.processEnumeratedString...
                    (obj, ...
                    orientation, ...
                    {'horizontal', 'vertical'});
            catch %#ok<*CTCH>
                messageObj = message('MATLAB:ui:components:invalidTwoStringEnum', ...
                    'Orientation', 'horizontal', 'vertical');
                
                % MnemonicField is last section of error id
                mnemonicField = 'invalidOrientation';
                
                % Use string from object
                messageText = getString(messageObj);
                
                % Create and throw exception
                exceptionObject = matlab.ui.control.internal.model.PropertyHandling.createException(obj, mnemonicField, messageText);
                throw(exceptionObject);
                
            end
            
            % Property Setting
            obj.PrivateOrientation = newOrientation;
            
            if(strcmpi(newOrientation, oldOrientation))
                return;
            end
            
            % Update position related properties 
            obj.updatePositionPropertiesAfterOrientationChange(...
                oldOrientation, newOrientation);
            
            
            % Push to controller values that are certain.
            % Do not push the estimated OuterPosition to the view
            obj.markPropertiesDirty({ ...
                'Orientation',...
                'AspectRatioLimits',...
                'InnerPosition', ...
                });
            
        end
        
        function value = get.Orientation(obj)
            value = obj.PrivateOrientation;
        end
        
    end
    
    methods (Access = 'protected')
        
        function [newOuterPosition] = estimateOuterPositionAfterOrientationChange(...
                obj, oldOrientation, newOrientation, oldInnerSize)
            % Override of the method defined in the PositionableComponent
            % mixin.
            % 
            % This returns an estimate of the outer art after a change in
            % orientation.
            %
            % It not only flips the size and height of the outer art, but 
            % also accounts for how the labels display in the vertical vs
            % horizontal direction. 
            %
            % INPUTS: 
            %
            %  - oldInnerSize : value of inner size before orientation
            %                   change
            
            
            % Location of inner art does not change after an orientation change
            innerLocation = obj.InnerPosition(1:2);
            
            oldOuterLocation = obj.OuterPosition(1:2);
            oldOuterSize = obj.OuterPosition(3:4);
            
            if(strcmpi(newOrientation, oldOrientation))
                % no change in orientation so no change in outer art
                newOuterLocation = oldOuterLocation;
                newOuterSize = oldOuterSize;
                
            elseif (strcmpi(oldOrientation,'horizontal') && strcmpi(newOrientation,'vertical'))
                % The orientation changes from horizontal to vertical
                
                % Estimate the OuterSize
                
                % leftWidth is the width taken by the state labels to
                % the left of the inner art
                leftWidth = innerLocation(1) - oldOuterLocation(1);
                % rightWidth is the width taken by the state labels to
                % the right of the inner art
                rightWidth = oldOuterSize(1) - oldInnerSize(1) - leftWidth;
                
                % newOuterWidth is the largest of the widths of the state labels and
                % the width of the component before transposition
                newOuterWidth = max([leftWidth; rightWidth; oldInnerSize(2)]);
                
                % we assume the height of the state labels is
                % approximatively the height of the inner art before
                % transposition
                newOuterHeight = oldInnerSize(1) + 2*oldInnerSize(2);
                
                newOuterSize = [newOuterWidth, newOuterHeight];
                
                % Estimate the OuterLocation
                
                % deltaX is the width on each side of the inner art after
                % transposition
                deltaX = (newOuterWidth - oldInnerSize(2)) / 2;
                % round the value in case it is not an integer
                deltaX = round(deltaX);
                newOuterX = innerLocation(1) - deltaX;
                % deltaY is the height below the inner art after
                % transposition
                deltaY = (newOuterHeight - oldInnerSize(1)) / 2;
                % round the value in case it is not an integer
                deltaY = round(deltaY);
                newOuterY = innerLocation(2) - deltaY;
                
                newOuterLocation =  [newOuterX, newOuterY ];
                
            elseif (strcmpi(oldOrientation,'vertical') && strcmpi(newOrientation,'horizontal'))
                % The orientation changes from vertical to horizontal
                
                % Estimate the OuterSize
                
                % stateLabelHeight is an estimate of the height of the
                % state labels (on top and below the inner art before the
                % orientation change)
                stateLabelHeight = (oldOuterSize(2) - oldInnerSize(2) ) / 2;
                % round the value in case it is not an integer
                stateLabelHeight = round(stateLabelHeight);
                % newOuterHeight is the largest of the height of the
                % inner art and the height of the state labels
                newOuterHeight = max([oldInnerSize(1); stateLabelHeight]);
                
                % we assume the widths of the state labels are all the same
                % and equal to the width of the outer art before the
                % orientation change
                stateLabelWidth = oldOuterSize(1);
                % newOuterWidth is the new width of the inner art plus the
                % widths of the state labels
                newOuterWidth = oldInnerSize(2) + 2 * stateLabelWidth;
                
                newOuterSize = [newOuterWidth, newOuterHeight];
                
                % Estimate the OuterLocation
                
                % the X offset between the inner and outer art is the width
                % of the state label on the left of the inner art
                newOuterX = innerLocation(1) - stateLabelWidth;
                % if the heights of the state labels are greater than the
                % new height of the inner art, there will be an Y-offset
                deltaY = (newOuterHeight - oldInnerSize(1)) / 2;
                % round the value in case it is not an integer
                deltaY = round(deltaY);
                
                newOuterY = innerLocation(2) - deltaY;
                
                newOuterLocation =  [newOuterX, newOuterY ];
                
            end
            
            newOuterPosition = [newOuterLocation, newOuterSize];
        end
    end
   
end

