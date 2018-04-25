classdef SplitReader < matlab.mixin.Copyable
%SplitReader   Abstract class that can iterate over data in a split.
% This class inherits copyability to allow cloning a split reader and
% resetting it rather than modifying the state of an existing instance

%   Copyright 2014 The MathWorks, Inc.
   
    properties (Access = 'public', Abstract = true)
        Split;    % Split to read
    end
    
    
    methods (Access = 'public', Abstract = true)
        
        % Return logical scalar indicating availability of data
        tf = hasSplitData(rdr);

        % Return data and info as appropriate for the datastore
        [data, info] = readSplitData(rdr);
        
        % Reset the reader to the beginning of the split
        reset(rdr);
        
    end
    
    
end
