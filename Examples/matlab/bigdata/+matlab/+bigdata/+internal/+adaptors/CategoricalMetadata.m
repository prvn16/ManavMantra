%CategoricalMetadata Metadata subclass for categorical arrays

%   Copyright 2016 The MathWorks, Inc.

classdef CategoricalMetadata < matlab.bigdata.internal.adaptors.AbstractArrayMetadata
    methods
        function obj = CategoricalMetadata(tallSz)
            names         = {'Categories'};
            aggregateFcns = {@(chunk) {categories(chunk)}};
            reduceFcns    = {@(data) data(1)};
            obj@matlab.bigdata.internal.adaptors.AbstractArrayMetadata(...
                tallSz, names, aggregateFcns, reduceFcns);
        end
    end
end
