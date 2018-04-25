classdef DataDescriptor < handle
    % This class provides information about one quantity. All its
    % properties are read-only.
    
    %   Copyright 2010-2016 The MathWorks, Inc.
%     
     properties(GetAccess = public, SetAccess = private)
         Name = ''; % A string representing the name of the data value (such as "X" or "Time").
         Value = []; % An array representing the value of the quantity (this may be empty).
     end
    
    methods
        function hObj = DataDescriptor(name, value)
            % Construct the object.
            
            % Make sure the inputs are valid
            narginchk(2,2);
            
            % The first argument must be a string.
            if ~ischar(name) && ~iscellstr(name)
                error(message('MATLAB:specgraph:chartMixin:dataannotatable:DataDescriptor:InvalidName'));
            end
           
            hObj.Name = name;
            hObj.Value = value;
        end        
    end    
end