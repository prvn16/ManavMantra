function varargout = validateSource(this, source)
%VALIDATESOURCE Validate the source
%   OUT = VALIDATESOURCE(ARGS) <long description>

%   Copyright 2010-2017 The MathWorks, Inc.

if nargin < 2
    source = this.Application.DataSource;
end

msg = MException.empty;
b = true;

nInputs = getNumInputs(source);
if nInputs > 1
    msg_ID = 'Spcuilib:scopes:ErrorIncorrectNumberOfSignalsNTX';
    msg = MException(msg_ID,getString(message(msg_ID)));
    b = false;
else
    % Make sure the data type on the signal is supported.
    dataTypes = getDataTypes(source);
    if any(~cellfun(@isempty,dataTypes))
        if numel(unique(dataTypes)) > 1
            b = false;
            msg_ID = 'Spcuilib:scopes:ErrorSignalsDataTypeMismatchNTX';
            msg = MException( msg_ID,getString(message(msg_ID)));
        else
            try
                dataTypeObj = fixdt(dataTypes{1});
                if ~isfixed(dataTypeObj) && ~isfloat(dataTypeObj)
                    b = false;
                    msg_ID = 'fixed:NumericTypeScope:incorrectInputType';
                    msg = MException(msg_ID,getString(message(msg_ID)));
                end
            catch nts_exception %#ok<NASGU>
                % fixdt() probably errored out since the dataType was
                % fixed-point string. Consume the error.
            end
        end
        
    end
    if source.isDataLoaded
        rawData = getRawData(source, 1);
        if ~isempty(rawData) && this.InputNeedsValidation
            if all(isinf(rawData(:))) || all(isnan(rawData(:))) || issparse(rawData)
                b = false;
                msg_ID = 'fixed:NumericTypeScope:invalidData';
                msg = MException(msg_ID,getString(message(msg_ID)));
            end
            this.InputNeedsValidation = false;
        end
    end

end
if nargout
    varargout = {b, msg};
elseif ~isempty(msg)
    throw(msg);
end

% Make sure 

% [EOF]
