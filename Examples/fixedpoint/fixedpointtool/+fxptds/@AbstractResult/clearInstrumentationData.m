function clearInstrumentationData(this)
% CLEARINSTRUMENTATIONDATA Clear the data related to min/max overflow logging

% Copyright 2012-2016 The MathWorks, Inc.

    this.SimMin = [];
    this.SimMax = [];
    this.OverflowWrap = [];
    this.OverflowSaturation = [];
    this.DivideByZero = [];
    this.PossibleOverflows = false;
    this.HasSimMinMax = false;
    this.HasOverflowInformation = false;
    this.WholeNumber = [];
    this.HistogramData = struct('BinData', [], 'numZeros', 0);
end

