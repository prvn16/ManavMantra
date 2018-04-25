function setParameterValue(this, param, paramVal)
% SETPARAMETERVALUE sets the specified parameter to the specified value
% after converting it to a string

% Copyright 2015 The MathWorks, Inc

strVal = fxptui.convertEnumToParamValue(param, paramVal);
try
    set_param(this.daobject.getFullName,param,strVal);
catch paramException
    msg =  fxptui.message('MMODTOError');
    paramMsgException = MException('Simulink:Data:DataTypeSetting', msg).addCause(paramException); %create an exception and add cause
    throw(paramMsgException);
end

