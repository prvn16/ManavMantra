function [errID,a2SD,b2SD,Tsd] = eml_fi_math_with_same_types(Ta,Tb)
% Fixed-point helper function that checks to see that 
% Ta & Tb have the same DataType.

%   Copyright 2006-2012 The MathWorks, Inc.
    
% Get the DataTypes
taDataType = Ta.DataType;
tbDataType = Tb.DataType;

% If a & Tb are scaled check for scaled-double'ness on them and promote the
% one that is not scaled-double to be so.
if isscaledtype(Ta) && isscaledtype(Tb)
    errID = '';
    if isscaleddouble(Ta) && ~isscaleddouble(Tb)
        a2SD = false;
        b2SD = true;
        Tsd  = Tb; 
        Tsd.DataType = 'ScaledDouble';
    elseif isscaleddouble(Tb) && ~isscaleddouble(Ta)
        a2SD = true;
        b2SD = false;
        Tsd  = Ta; 
        Tsd.DataType = 'ScaledDouble';
    else
        a2SD = false;
        b2SD = false;
        Tsd  = [];
    end
elseif ~strcmpi(taDataType,tbDataType)
    errID = 'fixed:fi:unsupportedFiMixedMath';
    a2SD  = false;
    b2SD  = false;
    Tsd   = [];
else
    errID = '';
    a2SD  = false;
    b2SD  = false;
    Tsd   = [];
end
