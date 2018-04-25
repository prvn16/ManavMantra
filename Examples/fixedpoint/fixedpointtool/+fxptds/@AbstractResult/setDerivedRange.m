function setDerivedRange(this, minVal, maxVal)
    % Set the derived min/max value on the result
    % Copyright 2013-2016 The MathWorks, Inc.
    this.DerivedMin = SimulinkFixedPoint.extractMin(minVal);
    this.DerivedMax = SimulinkFixedPoint.extractMax(maxVal);
    
    if ~isempty(this.DerivedMin) || ~isempty(this.DerivedMax)
        this.HasDerivedMinMax = true;
    end
end