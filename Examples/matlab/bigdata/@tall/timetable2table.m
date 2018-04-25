function t = timetable2table(tt,varargin)
%TIMETABLE2TABLE Convert tall timetable to tall table.
%   T = TIMETABLE2TABLE(TT)
%   T = TIMETABLE2TABLE(TT,'ConvertRowTimes',TF)
%
%   See also TIMETABLE2TABLE.

%   Copyright 2016-2017 The MathWorks, Inc.

if ~istall(tt)
    error(message('MATLAB:bigdata:array:ArgMustBeTall', 1, upper(mfilename)));
end
if ~strcmp(tall.getClass(tt), 'timetable')
    error(message('MATLAB:timetable2table:NonTimetable'));
end

pnames = {'ConvertRowTimes'};
dflts =  {            true };
convertRowTimes = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});

t = slicefun(@(x)timetable2table(x,varargin{:}),tt);

varNames = subsref(tt, substruct('.', 'Properties', '.', 'VariableNames'));
varAdaptors = cellfun(@(x) getVariableAdaptor(tt.Adaptor, x), varNames, ...
                      'UniformOutput', false);
    
% Construct Adaptor
props = subsref(tt, substruct('.', 'Properties'));

if convertRowTimes
   varNames = [props.DimensionNames{1}, varNames];
   varAdaptors = [{props.RowTimes.Adaptor}, varAdaptors];
   if ~isempty(props.VariableDescriptions)
        props.VariableDescriptions = [{''}, props.VariableDescriptions];
   end
   if ~isempty(props.VariableUnits)
        props.VariableUnits = [{''}, props.VariableUnits];
   end
   if ~isempty(props.VariableContinuity)
        props.VariableContinuity = [{'unset'}, props.VariableContinuity];
   end
end
newDimsNames = props.DimensionNames;
newDimsNames{1} = 'Row';
props = rmfield(props,'RowTimes');
props = rmfield(props,'DimensionNames');
props.RowNames = {};
t.Adaptor = matlab.bigdata.internal.adaptors.TableAdaptor(varNames, varAdaptors, ...
    newDimsNames, props);
