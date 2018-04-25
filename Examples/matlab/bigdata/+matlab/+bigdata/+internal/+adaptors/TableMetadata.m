%TableMetadata Metadata subclass for tables.

%   Copyright 2016 The MathWorks, Inc.

classdef TableMetadata < matlab.bigdata.internal.adaptors.AbstractArrayMetadata
    methods
        function obj = TableMetadata(tallSz)
            names         = {'TableSummary'};
            aggregateFcns = {@matlab.bigdata.internal.util.calculateLocalSummary};
            reduceFcns    = {@matlab.bigdata.internal.util.reduceSummary};
            obj@matlab.bigdata.internal.adaptors.AbstractArrayMetadata(...
                tallSz, names, aggregateFcns, reduceFcns);
        end
    end
end
