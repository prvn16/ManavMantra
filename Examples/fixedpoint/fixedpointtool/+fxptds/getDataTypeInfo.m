function DTInfo = getDataTypeInfo(s)
% GETDATATYPEINFO   Get the datatype information from the data.

%   Copyright 2012-2014 The MathWorks, Inc.


DTInfo.SimDT = '';
DTInfo.BlkStatus = '';
DTInfo.RangeMin = [];
DTInfo.RangeMax = [];
DTInfo.IsScaledDouble = false;
DTInfo.DataTypeObj = [];
DTInfo.InvalidRangeFields = {};

if(isa(s, 'fxptds.AbstractResult'))
  s = struct(s);
end

if isfield(s,'DataTypeName') || isfield(s,'DataType') || isfield(s,'CompiledDT')
  if isfield(s,'CompiledDT')
      simdt = s.CompiledDT;
  else
      simdt = s.DataTypeName;
  end
  if isempty(simdt); return; end
  switch simdt
    case { 'double','single','boolean' }
      % do nothing
      otherwise
        if strncmpi(simdt,'fixdt(',6)
            DTInfo.DataTypeObj = eval(simdt);
        else
            IsScaledDouble = false;
            try
                [DataTypeObj,IsScaledDouble] = fixdt( simdt );
                simdt = fixdt(DataTypeObj);
            catch
                DataTypeObj = [];
                % eat the error in this case. The compiledDT could have been an alias type, bus type or enum type.
            end
            DTInfo.DataTypeObj = DataTypeObj;
            DTInfo.IsScaledDouble = IsScaledDouble;
        end
      if (isa(DTInfo.DataTypeObj,'Simulink.NumericType') || isa(DTInfo.DataTypeObj,'embedded.numerictype')) ...
              && SimulinkFixedPoint.DataType.isFixedPointType(DTInfo.DataTypeObj)
        [dt_min,dt_max] = ...
          SimulinkFixedPoint.DataType.getFixedPointRepMinMaxRwvInDouble(DTInfo.DataTypeObj);
      DTInfo.RangeMin = dt_min;
      DTInfo.RangeMax = dt_max;
      end
  end
  DTInfo.SimDT = simdt;
  
  if isfield(s,'isScaledDouble')
      DTInfo.IsScaledDouble = s.isScaledDouble;
  end

  if(isfield(s, 'MinValue') && isfield(s, 'MaxValue'))
    if s.MinValue > s.MaxValue
      DTInfo.BlkStatus = 'Did Not Execute';
      DTInfo.InvalidRangeFields{end+1} = {'MinValue', 'MaxValue'};
    elseif s.MinValue == s.MaxValue
      DTInfo.BlkStatus = 'Static';
    end
  end
  if(isfield(s, 'SimMin') && isfield(s, 'SimMax'))
    if s.SimMin > s.SimMax
      DTInfo.BlkStatus = 'Did Not Execute';
      DTInfo.InvalidRangeFields{end+1} = {'SimMin', 'SimMax'};
    elseif s.SimMin == s.SimMax
      DTInfo.BlkStatus = 'Static';
    end
  end
end

%-------------------------------------------------------------------
% [EOF]
