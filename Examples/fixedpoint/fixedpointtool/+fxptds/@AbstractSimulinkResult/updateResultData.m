function updateResultData(this, data)
% UPDATERESULTDATA Update the result with the supplied data.

%    Copyright 2012-2016 The MathWorks, Inc.

updateResultData@fxptds.AbstractResult(this, data);

if isfield(data,'ActualSourceIDs')
    setActualSourceIDs(this, data.ActualSourceIDs);
end

hasSimMinMax = false;
if isfield(data,'MinValue') || isfield(data,'MaxValue')
      hasSimMinMax = true;
end
if(isfield(data, 'ReplaceOutDataType') && ~isempty(data.ReplaceOutDataType))
  this.ReplaceOutDataType = data.ReplaceOutDataType;
end

if(isfield(data, 'ReplacementOutDTName') && ~isempty(data.ReplacementOutDTName))
  this.ReplacementOutDTName = data.ReplacementOutDTName;
end

% Result data field can be set directly
if(isfield(data, 'CompiledDT'))
    this.CompiledDT = data.CompiledDT;
end

if(isfield(data, 'CompiledInputDT') && ~isempty(data.CompiledInputDT))
  this.CompiledInputDT = data.CompiledInputDT;
end

if(isfield(data, 'CompiledOutputDT') && ~isempty(data.CompiledOutputDT))
  this.CompiledOutputDT = data.CompiledOutputDT;
end

if(isfield(data, 'CompiledInputComplex') && ~isempty(data.CompiledInputComplex))
    this.CompiledInputComplex =  data.CompiledInputComplex;
end

if(isfield(data, 'CompiledOutputComplex') && ~isempty(data.CompiledOutputComplex))
    this.CompiledOutputComplex = data.CompiledOutputComplex;
end

if(isfield(data, 'ParameterSaturationOccurred'))
    this.ParameterSaturation = data.ParameterSaturationOccurred;
elseif hasSimMinMax
    this.ParameterSaturation = [];
end
if ~isempty(this.ParameterSaturation)
    this.HasSupportingMinMax = true;
end

if(isfield(data, 'InitValueMin'))
  this.InitialValueMin  = SimulinkFixedPoint.extractMin(data.InitValueMin);
  if ~isempty(this.InitialValueMin)
      this.HasSupportingMinMax = true;
  end
end

if(isfield(data, 'InitValueMax'))
  this.InitialValueMax = SimulinkFixedPoint.extractMax(data.InitValueMax);
  if ~isempty(this.InitialValueMax)
      this.HasSupportingMinMax = true;
  end
end

if(isfield(data, 'InitialValueMin'))
  this.InitialValueMin  = SimulinkFixedPoint.extractMin(data.InitialValueMin);
  if ~isempty(this.InitialValueMin)
      this.HasSupportingMinMax = true;
  end
end

if(isfield(data, 'InitialValueMax'))
  this.InitialValueMax = SimulinkFixedPoint.extractMax(data.InitialValueMax);
  if ~isempty(this.InitialValueMax)
      this.HasSupportingMinMax = true;
  end
end

if(isfield(data, 'ModelRequiredMin'))
    this.ModelRequiredMin  = SimulinkFixedPoint.extractMin(data.ModelRequiredMin);
    if ~isempty(this.ModelRequiredMin)
        this.HasSupportingMinMax = true;
    end
end

if(isfield(data, 'ModelRequiredMax'))
  this.ModelRequiredMax = SimulinkFixedPoint.extractMax(data.ModelRequiredMax);
  if ~isempty(this.ModelRequiredMax)
      this.HasSupportingMinMax = true;
  end
end


