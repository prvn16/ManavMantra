function callbackClass = getFFTWGpuCallbackName(aOption)
%   Get GPU FFTW Custom Callback class from config object if it exists

%   Copyright 2017 The MathWorks, Inc.
callbackClass = aOption.getConfigProp('CustomFFTCallback');
if ~isempty(callbackClass)
    if (~verifyCallbackClass(callbackClass))
        error(message('Coder:FE:FFTCallbackClassInvalid', callbackClass));
    end
end

end

function valid = verifyCallbackClass(aClassStr)
    classMeta = meta.class.fromName(aClassStr);

    if isempty(classMeta)
        error(message('Coder:FE:FFTCallbackClassNotExist', aClassStr));
    end

    class = feval(aClassStr);
    valid = isa(class, 'coder.CustomFFTCallback');
end
