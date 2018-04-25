function args = check_fan_params(in,args,valid_params,...
                                 function_name,num_pre_param_args)
%CHECK_FAN_PARAMS Check validity of parameters and values for fan-beam functions.
%   ARGS = ...
%   CHECK_FAN_PARAMS(IN,ARGS,VALID_PARAMS,FUNCTION_NAME,NUM_PRE_PARAM_ARGS)
%   checks the validity of the param/values pairs IN.
%
%   VALID_PARAMS is a cell array containing strings.
%
%   FUNCTION_NAME is a string containing the function name to be used in the
%   formatted error message.
%
%   NUM_PRE_PARAM_ARGS is a positive integer indicating how many arguments
%   precede the param/value pairs; it is also used in the formatted error
%   message.

%   Copyright 1993-2015 The MathWorks, Inc.

if rem(length(in),2)~=0
    error(message('images:check_fan_params:oddNumberArgs', upper( function_name )))
end    

valid.FanSensorGeometry = {'arc','line'};
valid.Interpolation = {'nearest', 'linear', 'spline', 'cubic', 'pchip'};
valid.Filter        = {'Ram-Lak','Shepp-Logan','Cosine','Hamming','Hann','None'};
valid.FanCoverage   = {'cycle','minimal'};
valid.ParallelCoverage = {'cycle','halfcycle'};

for k = 1:2:length(in)
    prop_string = validatestring(in{k}, valid_params, function_name,...
                               'PARAM', num_pre_param_args + k);
    
    switch prop_string
      case {'FanSensorGeometry','Interpolation','Filter','FanCoverage',...
            'ParallelCoverage'}
        args.(prop_string) = validatestring(in{k+1},...
                                          valid.(prop_string),...
                                          function_name, prop_string, ...
                                          num_pre_param_args+k+1);
      case {'FanRotationIncrement',...
            'FanSensorSpacing',...
            'FrequencyScaling',...
            'OutputSize',...
            'ParallelRotationIncrement',...
            'ParallelSensorSpacing'}
        args.(prop_string) = in{k+1};
        checkScalar(prop_string,args.(prop_string),function_name,...
                    num_pre_param_args+k+1);
        
      otherwise
        error(message('images:check_fan_params:unrecognizedParameter', prop_string, mfilename));
        
    end
end

% If 'cubic' interpolation is specified, convert it to 'pchip'. 
if isfield(args,'Interpolation')
    if strcmp(args.Interpolation,'cubic')
        args.Interpolation = 'pchip';
    end
end    

% Could add further validation for numeric arguments here.


%----------------------------------------------
function checkScalar(param,value,function_name,argument_position)

validateattributes(value, {'double'}, ...
              {'real', '2d', 'nonsparse', 'finite'}, ...
              function_name, param, argument_position);

if numel(value) > 1
    error(message('images:check_fan_params:valueMustBeScalar', param));
end
