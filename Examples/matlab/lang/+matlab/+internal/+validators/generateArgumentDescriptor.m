function [ fname, msgId, argname, argpos ]  = generateArgumentDescriptor( inputs, callingFunc )
; %#ok<NOSEM> % Undocumented

% Copyright 2011-6 The MathWorks, Inc.

% initialize optional inputs to default values
fname = '';
argname = '';
argpos = [];

if numel( inputs ) > 0
    % Try to disambiguate between user specifying argument position or
    % function name as the fourth input
    if numel( inputs ) == 1
        if isa( inputs{1}, 'double' )
            if ~isscalar( inputs{1} ) 
                error( matlab.internal.validators.generateId( callingFunc, 'badFunctionName' ), ...
                    '%s', createMessageString(callingFunc, 'badFunctionName') )                
            elseif ~isfinite(inputs{1}) || ~(floor(inputs{1})==inputs{1}) || inputs{1} < 1
                error( matlab.internal.validators.generateId( callingFunc, 'badArgPosition' ), ...
                    '%s', createMessageString(callingFunc, 'badArgPosition') ) 
            end
        elseif ~isCharOrString( inputs{1} )
            error( matlab.internal.validators.generateId( callingFunc, 'badFunctionName' ), ...
                '%s', createMessageString(callingFunc, 'badFunctionName') )
        end
    else
        if ~isCharOrString( inputs{1} )
            error( matlab.internal.validators.generateId( callingFunc, 'badFunctionNameString' ), ...
                '%s', createMessageString(callingFunc, 'badFunctionNameString') );
        end
    end
    
    if isCharOrString( inputs{1} )
        if ~isstring( inputs{1} ) || ~ismissing( inputs{1} )
            fname = char(inputs{1});
        end
    else
        argpos = inputs{1};
    end
end

if numel( inputs ) > 1
    if ~isCharOrString( inputs{2} )
        error( matlab.internal.validators.generateId( callingFunc, 'badVariableName' ), ...
            '%s', createMessageString(callingFunc, 'badVariableName') )
    end
    
    if ~isstring( inputs{2} ) || ~ismissing( inputs{2} )
        argname = char(inputs{2});
    end
end

if numel( inputs ) > 2
    % cascade the checks to get specific error messages
    if isnumeric(inputs{3}) && ...
            ( isscalar(inputs{3}) || isempty(inputs{3}) )
        % any empty is ok
        if ~isempty(inputs{3}) && ...
                (~isfinite(inputs{3}) || ~(floor(inputs{3})==inputs{3}) || inputs{3} < 1)
            error( matlab.internal.validators.generateId( callingFunc, 'badArgPosition' ), ...
                '%s', createMessageString(callingFunc, 'badArgPosition') )
        end
    else
        error( matlab.internal.validators.generateId( callingFunc, 'badArgPositionClass' ), ...
            '%s', createMessageString(callingFunc, 'badArgPositionClass') )
    end
            
    argpos = inputs{3};
end

% build the argument descriptor based on which inputs were specified
% by the user
if isempty( argpos )
    if isempty( argname )
        msgId = 'NoNameNoNumber';
    else
        msgId = 'NameNoNumber';
    end
else
    if isempty( argname )
        msgId = 'NoNameNumber';
    else
        msgId = 'NameNumber';
    end
end    

end

function str = createMessageString(callingFunc, messageId)
% See if the calling function has a message for the messageid.  If not, fall
% back to validateattributes's message (which is known to exist)
try
    str = getString(message(strjoin({'MATLAB', callingFunc, messageId}, ':')));
catch
    str = getString(message(strjoin({'MATLAB', 'validateattributes', messageId}, ':')));
end
end

function yesno = isCharOrString(in)
yesno = ischar( in ) || isstring( in );
end
