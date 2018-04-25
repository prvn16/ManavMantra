classdef Splitter < handle
%Splitter   Abstract class that allows dividing up data read tasks.

%   Copyright 2014 The MathWorks, Inc.
    
    methods (Static = true, Access = 'public', Abstract = true)
        % Create Splitter from appropriate arguments
        splitter = create(args);
    
        % Create Splitter from existing Splits
        splitter = createFromSplits(splits);
        
    end
    
    properties (Access = 'public', Abstract = true)
        % Array containing logical splits for this Splitter type
        Splits; 
    end    
end