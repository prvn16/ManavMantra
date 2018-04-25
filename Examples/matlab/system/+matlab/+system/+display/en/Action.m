classdef Action< handle
%matlab.system.display.Action   System object display action
%   A = matlab.system.display.Action(CALLBACK,P1,V1,...,PN,VN) creates an 
%   action for use in System object display.  You use
%   matlab.system.display.Action in getPropertyGroupsImpl to assign actions 
%   in property groups.
%
%   CALLBACK is a string or function handle.  This input is stored in the
%   ActionCalledFcn property.
%
%   Inputs P1,V1,...,PN,VN are optional property name-value pair arguments 
%   for Label, Description, Placement, and Assignment that you can specify
%   in any order.  
%
%  Action properties:
%
%      ActionCalledFcn - Action callback function
%      Label           - Action label
%      Description     - Action description
%      Placement       - Action placement in property group
%      Alignment       - Action graphical alignment
% 
%   See also matlab.system.display.ActionData.

 
%   Copyright 2014-2015 The MathWorks, Inc.

    methods
        function out=Action
            % Parse arguments given default values
        end

    end
    methods (Abstract)
    end
    properties
        %ActionCalledFcn   Action callback function
        %   Callback function of this action as a string or function 
        %   handle.  If specified as a string, CALLBACK represents a MATLAB
        %   expression that will be evaluated in the base workspace when
        %   the action is called.  If specified as a function handle,
        %   CALLBACK represents a function that will be evaluated when the
        %   action is called.  The function definition must define two
        %   inputs that are assigned a matlab.system.display.ActionData 
        %   object instance and a System object instance.
        ActionCalledFcn;

        %Alignment   Action graphical alignment
        %   Graphical alignment of this action as 'left' or 'right'.  The
        %   default value of this property is 'left'.
        Alignment;

        %Description   Action description
        %   Description of this action as a string.  The default value of 
        %   this property is an empty string.
        Description;

        %Label   Action label
        %   Label of this action as a string.  The default value of this 
        %   property is an empty string.
        Label;

        %Placement   Action placement in property group
        %   Placement of this action in property group as 'first', 'last', 
        %   or the name of a property in the group.  If set to 'first', 
        %   action is placed above or before the properties.  If set to 
        %   'last', action is placed below or after the properties.  If set 
        %   to a property name, action is inserted before the named 
        %   property.  The default value of this property is 'last'.
        Placement;

    end
end
