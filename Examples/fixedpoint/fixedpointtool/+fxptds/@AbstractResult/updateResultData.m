function updateResultData(this, data)
    % UPDATERESULTDATA Update the result based on the data.
    
    % Copyright 2012-2017 The MathWorks, Inc.
    
    this.IsVisible = true;
    
    if isfield(data,'ProposedDT') && ~isempty(data.ProposedDT)
        this.setProposedDT(data.ProposedDT);
    end
    
    if(isfield(data, 'IsScaledDouble'))
        this.IsScaledDouble = data.IsScaledDouble;
    end
    
    hasSimMinMax = false;
    if(isfield(data, 'MinValue'))
        this.SimMin = SimulinkFixedPoint.extractMin(data.MinValue);
        hasSimMinMax = true;
        if ~isempty(data.MinValue)
            this.HasSimMinMax = true;
        end
        if isfield(data,'RangeMin') && ~isempty(data.RangeMin)
            if this.SimMin < data.RangeMin
                this.PossibleOverflows = true;
                this.HasOverflowInformation = true;
            end
        end
    end
    
    if(isfield(data, 'MaxValue'))
        this.SimMax = SimulinkFixedPoint.extractMax(data.MaxValue);
        hasSimMinMax = true;
        if ~isempty(data.MaxValue)
            this.HasSimMinMax = true;
        end
        this.OverflowMode = this.getOverflowMode;
        if isfield(data,'RangeMax') && ~isempty(data.RangeMax)
            if this.SimMax > data.RangeMax
                this.PossibleOverflows = true;
                this.HasOverflowInformation = true;
            end
        end
    end
    
    if(isfield(data, 'DataTypeName'))
        this.CompiledDT = data.DataTypeName;
    end
    
    if(isfield(data, 'DerivedMin'))
        this.DerivedMin = SimulinkFixedPoint.extractMin(data.DerivedMin);
        if ~isempty(data.DerivedMin)
            this.HasDerivedMinMax = true;
        end
    end
    
    if(isfield(data, 'DerivedMax'))
        this.DerivedMax = SimulinkFixedPoint.extractMax(data.DerivedMax);
        if ~isempty(data.DerivedMax)
            this.HasDerivedMinMax = true;
        end
    end
    
    if(isfield(data, 'CalcDerivedMin'))
        this.CalcDerivedMin = SimulinkFixedPoint.extractMin(data.CalcDerivedMin);
    end
    
    if(isfield(data, 'CalcDerivedMax'))
        this.CalcDerivedMax = SimulinkFixedPoint.extractMax(data.CalcDerivedMax);
    end
    
    if(isfield(data, 'DerivedRangeIntervals'))
        this.DerivedRangeIntervals = data.DerivedRangeIntervals;
    end
    
    if(isfield(data, 'SimMin'))
        if isempty(this.OverflowMode)
            this.OverflowMode = this.getOverflowMode;
        end
        this.SimMin = data.SimMin;
        if ~isempty(data.SimMin)
            this.HasSimMinMax = true;
        end
    end
    
    if(isfield(data, 'SimMax'))
        this.SimMax = data.SimMax;
        if ~isempty(data.SimMax)
            this.HasSimMinMax = true;
        end
    end
    
    if(isfield(data, 'DesignMin'))
        this.DesignMin = data.DesignMin;
        if ~isempty(this.DesignMin)
            this.HasDesignMinMax = true;
        end
    end
    
    if(isfield(data, 'DesignMax'))
        this.DesignMax = data.DesignMax;
        if ~isempty(this.DesignMax)
            this.HasDesignMinMax = true;
        else
            if isempty(this.DesignMin)
                this.HasDesignMinMax = false;
            end
        end
    end
    
    if(isfield(data, 'CompiledDesignMin'))
        this.CompiledDesignMin = SimulinkFixedPoint.extractMin(data.CompiledDesignMin);
    end
    
    if(isfield(data, 'CompiledDesignMax'))
        this.CompiledDesignMax = SimulinkFixedPoint.extractMax(data.CompiledDesignMax);
    end
    
    if(isfield(data, 'SpecifiedDT'))
        this.SpecifiedDT = data.SpecifiedDT;
        this.HasSpecifiedDT = this.hasSpecifiedDT;
    end
    
    if(isfield(data, 'Accept'))
        this.Accept = data.Accept;
    end
    
    if(isfield(data, 'OverflowOccurred'))
        this.OverflowWrap = data.OverflowOccurred;
        if ~isempty(data.OverflowOccurred) && data.OverflowOccurred
            this.HasOverflowInformation = true;
        else
            this.OverflowWrap = [];
        end
    elseif hasSimMinMax
        % Clear out Overflows explicitly if it is not part of the sim min/max
        % data that is being passed in. With derived min/max workflow, we
        % update the timestamp of the results having derived min/max to the
        % current time-stamp in-order to prevent them from being erased. We
        % need to clear simulation data in this case if it doesn't exist.
        this.OverflowWrap = [];
    end
    
    if(isfield(data, 'SaturationOccurred'))
        this.OverflowSaturation = data.SaturationOccurred;
        if ~isempty(data.SaturationOccurred) && data.SaturationOccurred
            this.HasOverflowInformation = true;
        else
            this.OverflowSaturation = [];
        end
    elseif hasSimMinMax
        % Clear out Saturations explicitly if it is not part of the sim min/max
        % data that is being passed in. With derived min/max workflow, we
        % update the timestamp of the results having derived min/max to the
        % current time-stamp in-order to prevent them from being erased. We
        % need to clear simulation data in this case if it doesn't exist.
        this.OverflowSaturation = [];
    end
    
    if(isfield(data, 'DivisionByZeroOccurred'))
        this.DivideByZero = data.DivisionByZeroOccurred;
        if ~isempty(data.DivisionByZeroOccurred) && data.DivisionByZeroOccurred
            this.HasOverflowInformation = true;
        else
            this.DivideByZero = [];
        end
    elseif hasSimMinMax
        this.DivideByZero = [];
    end
    
    if(isfield(data, 'Alert'))
        this.Alert = data.Alert;
        % Cache away for performance
        this.HasAlert = this.hasAlert;
    end
    
    if(isfield(data, 'Comments') && ~isempty(data.Comments))
        this.Comments = data.Comments;
    end
    
    % CompiledDT field for some child class
    % are not directly settable.
    
    if(isfield(data, 'isVisible') && ~isempty(data.isVisible))
        this.IsVisible = data.isVisible;
    end
    
    if isfield(data,'DTConstraints')
        this.DTConstraints = data.DTConstraints;
    end
    
    if isfield(data,'LocalExtremumSet')
        this.LocalExtremumSet = double(data.LocalExtremumSet);
    end
    
    if(isfield(data, 'DTGroup'))
        this.DTGroup = data.DTGroup;
    end
    
    if isfield(data, 'WholeNumber')
        this.WholeNumber = (data.WholeNumber > 0);
    end
    
    if isfield(data, 'HistogramData')
        if isfield(data.HistogramData, 'BinData')
            this.HistogramData.BinData = data.HistogramData.BinData;
        end
        if isfield(data.HistogramData, 'numZeros')
            this.HistogramData.numZeros = data.HistogramData.numZeros;
        end
    end
    
    % Update the result's DerivedRangeState
    this.setDerivedRangeState;
    
end


% LocalWords:  Calc
