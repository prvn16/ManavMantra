function varargout = validateSource(this, source)
%VALIDATESOURCE Validate the source

%   Copyright 2010-2016 The MathWorks, Inc.

if nargin < 2
    source = this.Application.DataSource;
end

% Define the default outputs.
b         = true;
exception = MException.empty;

% If any of the inputs have complex data, return false.
if any(isInputComplex(source))
    b = false;
    id  = 'Spcuilib:scopes:ErrorComplexValuesNotSupported';
    msg = getString(message(id)); 
    exception = MException(id, msg);
    varargout = {b, exception};
    return;
end

% Get the MaxDimensions for all inputs
maxDims = getMaxDimensions(source);
nInputs = getNumInputs(source);

if nInputs == 3
    
    sampleTimes = getSampleTimes(source);
    if numel(unique(sampleTimes)) ~= 1
        b = false;
        msg = getString(message('Spcuilib:scopes:VideoSampleTimeConflict'));
        exception = MException('Spcuilib:scopes:VideoSampleTimeConflict', msg);
    end
    
    % For 3x2 data, if there are more than 2 columns of data in any dimension, then this is not a video signal.
    % Or for 1x3 data, if there are more than 3 columns in the dimension, then this is not a video signal
    if (size(maxDims, 1) == 3 && (size(maxDims, 2) > 2 && any(maxDims(:, 3) ~= 1))) || ...
            size(maxDims, 1) == 1 && (numel(maxDims) > 3 || ((size(maxDims, 2) > 2) && (maxDims(3) ~= 1 && maxDims(3) ~= 3)))
        b = false;
        exception = MException('Spcuilib:Video:InvalidSignalDimensions', getString(message('Spcuilib:scopes:ErrorVidComponentsSelected')));
    end
    
    % When we have more than 1 input, make sure that all the datatypes make
    % sense together.
    dataTypes = getDataTypes(source);
    if numel(unique(dataTypes)) > 1
        b = false;
        exception = MException('Spcuilib:Video:DataTypeMismatch', getString(message('Spcuilib:scopes:ErrorVidDataType')));
    end
    
    maxDims = unique(maxDims, 'rows');
    if size(maxDims, 1) ~= 1
        b = false;
        exception = MException('Spcuilib:Video:InvalidSignalDimensions', getString(message('Spcuilib:scopes:ErrorVidComponentsSelected')));
    end
elseif nInputs == 1
    if numel(maxDims) > 2
        
        if numel(maxDims) > 3 || (maxDims(3) ~= 1 && maxDims(3) ~= 3)
            b = false;
            exception = MException('Spcuilib:Video:InvalidSignalDimensions', getString(message('Spcuilib:scopes:ErrorVidComponentsSelected')));
        end
    end
else
    b = false;
    exception = MException('Spcuilib:Video:InvalidSignalDimensions', getString(message('Spcuilib:scopes:ErrorVidComponentsSelected')));
end

if nargout
    varargout = {b, exception};
elseif ~b
    throw(exception);
end

% [EOF]
