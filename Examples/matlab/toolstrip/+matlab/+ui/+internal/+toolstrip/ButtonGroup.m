classdef ButtonGroup < handle
    % Button Group
    %
    % Radio buttons or toggle buttons in this group can only be selected
    % one at a time.
    %   
    %   Example:
    %       grp = matlab.ui.internal.toolstrip.ButtonGroup
    %       radio1 = matlab.ui.internal.toolstrip.RadioButton('Choice 1',grp)
    %       radio2 = matlab.ui.internal.toolstrip.RadioButton('Choice 2',grp)
    %
    % See also matlab.ui.internal.toolstrip.RadioButton, matlab.ui.internal.toolstrip.ToggleButton
    
    % Author(s): Rong Chen
    % Copyright 2015 The MathWorks, Inc.
    
    properties (Hidden, GetAccess = public, SetAccess = private)
        % Property "Id": 
        %
        %   The unique id of the button group.
        %   It is a string and it is read-only.
        Id
    end
    
    % ----------------------------------------------------------------------------
    methods
        
        %% Constructor
        function this = ButtonGroup()
            % Constructor "ButtonGroup": 
            %
            %   Construct a button group
            %
            %   Example:
            %       grp = matlab.ui.internal.toolstrip.ButtonGroup
            this.Id = char(java.util.UUID.randomUUID);
        end
        
    end
    
end
