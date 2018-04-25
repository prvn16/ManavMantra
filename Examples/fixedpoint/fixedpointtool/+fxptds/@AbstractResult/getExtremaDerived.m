function extremumSet = getExtremaDerived(this, extremumSet)
    % post-process the data when issues encountered with the derive range
    % accuracy
	%   Copyright 2016 The MathWorks, Inc.
    if isempty(this.CalcDerivedMin) && isempty(this.CalcDerivedMax)
        % use the native values
        derivedMin = this.DerivedMin;
        derivedMax = this.DerivedMax;
    else
        % use the native values
        % always ignore the native derived range
        derivedMin = this.CalcDerivedMin;
        derivedMax = this.CalcDerivedMax;
    end
    
    if ~isempty(derivedMin) &&  ~isinf(derivedMin)
        scaleDerivedMin = derivedMin;
        rangeVec = SimulinkFixedPoint.safeConcat(scaleDerivedMin, extremumSet);
    else
        rangeVec = extremumSet;
    end
    
    if ~isempty(derivedMax)  &&  ~isinf(derivedMax)
        scaleDerivedMax = derivedMax;
        rangeVec = SimulinkFixedPoint.safeConcat(scaleDerivedMax,rangeVec);
    end
    [curMin,curMax] = SimulinkFixedPoint.extractMinMax(rangeVec);
    extremumSet = this.combineIFsame([curMin,curMax]);
end
