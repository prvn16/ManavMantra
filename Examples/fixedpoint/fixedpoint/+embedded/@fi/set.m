function B = set(A, varargin)
%SET Set property values of fi object
%   Set the property 'PropertyName' of the fi object A is not allowed.
%
%   B = SET(A) displays all visible properties with public set access 
%              of fi object A in a scalar structure.
%   B = SET(A,'PropName') returns all admissible values for the specified
%   writable property, which must be Enum String Type
%

%   Copyright 2012-2017 The MathWorks, Inc.


if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if nargin == 1
    hClass = metaclass(A);
    propListHandles = findobj(hClass.PropertyList,  ...
        'SetAccess', 'public', ...
        'Hidden',    false);
    propNames = {propListHandles.Name};
    
    for i = 1: length(propNames)
        propName = propNames{i};   
        switch propName
          case {'RoundMode','RoundingMethod'}
            S.(propName) = {'Ceiling','Convergent','Zero','Floor','Nearest','Round'}';
          case {'OverflowMode', 'OverflowAction'}
             S.(propName) = {'Saturate','Wrap'}';
           case {'ProductMode', 'SumMode'}
             S.(propName) = {'FullPrecision','KeepLSB','KeepMSB','SpecifyPrecision'}';
          otherwise
            S.(propName) = {};   
        end
    end
    if nargout == 1
        B = S;
    else
        disp(S);
    end
elseif nargin == 2
    if ismember(lower(varargin), lower(properties(A)))
        AsgnVal = {};
        %== possible values for the user writable Enum String properties ===
        if strcmpi(varargin,'RoundMode') || strcmpi(varargin,'RoundingMethod')
            AsgnVal = {'Ceiling','Convergent','Zero','Floor','Nearest','Round'};
        elseif strcmpi(varargin,'OverflowMode') || strcmpi(varargin,'OverflowAction')
            AsgnVal = {'Saturate','Wrap'};
        elseif strcmpi(varargin,'ProductMode') || strcmpi(varargin,'SumMode')
            AsgnVal = {'FullPrecision','KeepLSB','KeepMSB','SpecifyPrecision'};
        end
        if nargout == 1
            B = AsgnVal';
        else
            disp(AsgnVal')
        end
    else
        error(message('MATLAB:noSuchMethodOrField', varargin{1}, class(A)));   
    end
else 
    error(message('fixed:embedded:setInvalidUse', 'FI'));
end
    

end %function

