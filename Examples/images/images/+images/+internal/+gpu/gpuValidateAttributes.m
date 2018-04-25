function gpuValidateAttributes(a, attributes, callerName, varName, varPosition)
%gpuValidateAttributes   GPU-version of validateattributes.
%   gpuValidateAttributes(A, ATTRIBUTES, CALLERNAME, VARNAME, VARPOSITION)
%   performs attribute validation on the gpuArray object A using
%   the characteristics in the cell array of strings ATTRIBUTES. (A
%   is assumed to be a gpuArray, which implies automatically that
%   it is either numeric or logical and nonsparse.)  The
%   CALLERNAME, VARNAME, VARPOSITION arguments are used to build
%   error messages.
%
%   Supported attributes: 2d, real, vector, nonempty, scalar, finite,
%   nonnan, nonnegative, numeric, uint8, uint16, int16, single, double

% Copyright 2015 The MathWorks, Inc.

% This function attempts to match error IDs emitted by MATLAB's validateattributes.

if ~isa(a,'gpuArray')
    error(message('images:validate:imageNotGPUArray'));
end

% Set invalid datatype flag
invalidDTFlag = 1;
checkDTFlag   = 0;
validDTStrs   = {};

classA = classUnderlying(a);

% 64 bit integers are not supported
if(strcmp(classA(end-1:end),'64'))
    validDTStrs = {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'};
    validDTMsg = [sprintf('\n\n') sprintf('%s',validDTStrs{1}) sprintf(', %s',validDTStrs{2:end}) sprintf('\n\n')];
    msg = message('images:validate:gpuInvalidType', varPosition, varName, validDTMsg, classA);
    ME = MException(['MATLAB:' callerName ':invalidType'],...
        msg.getString() );
    throwAsCaller(ME);
end

for ix = 1:numel(attributes)
    switch attributes{ix}
        case 'real'
            if ~isreal(a)
                msg = message('images:validate:gpuExpectedReal', varPosition, varName);
                ME = MException(['MATLAB:' callerName ':expectedReal'],...
                    msg.getString() );
                throwAsCaller(ME);
            end
        case '2d'
            if ~ismatrix(a)
                msg = message('images:validate:gpuExpected2d', varPosition, varName);
                ME = MException(['MATLAB:' callerName ':expected2D'],...
                    msg.getString() );
                throwAsCaller(ME);
            end
        case 'vector'
            if ~isvector(a)
                msg = message('images:validate:gpuExpectedVector', varPosition, varName);
                ME = MException(['MATLAB:' callerName ':expectedVector'],...
                    msg.getString() );
                throwAsCaller(ME);
            end
        case 'nonempty'
            if isempty(a)
                msg = message('images:validate:gpuExpectedNonempty', varPosition, varName);
                ME = MException(['MATLAB:' callerName ':expectedNonempty'],...
                    msg.getString() );
                throwAsCaller(ME);
            end
        case 'scalar'
            if ~isscalar(a)
                msg = message('images:validate:gpuExpectedScalar', varPosition, varName);
                ME = MException(['MATLAB:' callerName ':expectedScalar'],...
                    msg.getString() );
                throwAsCaller(ME);
            end
        case 'numeric'
            invalidDTFlag = 0;
            if ~isnumeric(a)
                msg = message('images:validate:gpuExpectedNumeric', varPosition, varName);
                ME = MException(['MATLAB:' callerName ':expectedNumeric'],...
                    msg.getString() );
                throwAsCaller(ME);
            end
        case 'logical'
            checkDTFlag = 1;
            validDTStrs = [validDTStrs,attributes{ix}]; %#ok<*AGROW>
            if strcmp(classA,'logical')
                invalidDTFlag = 0;
            end
        case 'uint8'
            checkDTFlag = 1;
            validDTStrs = [validDTStrs,attributes{ix}]; %#ok<*AGROW>
            if strcmp(classA,'uint8')
                invalidDTFlag = 0;
            end
        case 'int8'
            checkDTFlag = 1;
            validDTStrs = [validDTStrs,attributes{ix}]; %#ok<*AGROW>
            if strcmp(classA,'int8')
                invalidDTFlag = 0;
            end
        case 'uint16'
            checkDTFlag = 1;
            validDTStrs = [validDTStrs,attributes{ix}];
            if strcmp(classA,'uint16')
                invalidDTFlag = 0;
            end
        case 'int16'
            checkDTFlag = 1;
            validDTStrs = [validDTStrs,attributes{ix}];
            if strcmp(classA,'int16')
                invalidDTFlag = 0;
            end
        case 'uint32'
            checkDTFlag = 1;
            validDTStrs = [validDTStrs,attributes{ix}];
            if strcmp(classA,'uint32')
                invalidDTFlag = 0;
            end
        case 'int32'
            checkDTFlag = 1;
            validDTStrs = [validDTStrs,attributes{ix}];
            if strcmp(classA,'int32')
                invalidDTFlag = 0;
            end
        case 'double'
            checkDTFlag = 1;
            validDTStrs = [validDTStrs,attributes{ix}];
            if strcmp(classA,'double')
                invalidDTFlag = 0;
            end
        case 'single'
            checkDTFlag = 1;
            validDTStrs = [validDTStrs,attributes{ix}];
            if strcmp(classA,'single')
                invalidDTFlag = 0;
            end
            
        otherwise
            error(message('images:validate:invalidSyntax'));
    end
end

if invalidDTFlag && checkDTFlag
    if numel(validDTStrs) == 1
        validDTMsg = [sprintf('\n\n') sprintf('%s',validDTStrs{1}) sprintf('\n\n')];
    else
        validDTMsg = [sprintf('\n\n') sprintf('%s',validDTStrs{1}) sprintf(', %s',validDTStrs{2:end}) sprintf('\n\n')];
    end
    msg = message('images:validate:gpuInvalidType', varPosition, varName, validDTMsg, classA);
    ME = MException(['MATLAB:' callerName ':invalidType'],...
        msg.getString() );
    throwAsCaller(ME);
end
