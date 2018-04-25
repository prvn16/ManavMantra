%GenericArrayMetadata Metadata class that collects no additional metadata.

%   Copyright 2016 The MathWorks, Inc.

classdef GenericArrayMetadata < matlab.bigdata.internal.adaptors.AbstractArrayMetadata
    
    methods
        function obj = GenericArrayMetadata(tallSz)
        % Nothing additional to collect for generic arrays.
            emptyCellCol = cell(0, 1);
            obj@matlab.bigdata.internal.adaptors.AbstractArrayMetadata(...
                tallSz, emptyCellCol, emptyCellCol, emptyCellCol);
        end
    end
end
