function B = intlutmex(A, lut) %#codegen
% Copyright 2014 The MathWorks, Inc.

% Decision to call use single threaded library or not
if(images.internal.coder.useSingleThread())
    tsuffix         = '';
    useSingleThread = true;
else
    tsuffix         = '_tbb';
    useSingleThread = false;
end

B       = coder.nullcopy(zeros(size(A), 'like', A));

% Function name to be called in the shared library
ctype   = images.internal.coder.getCtype(A);
fcnName = ['intlut',tsuffix,'_',ctype];

if(useSingleThread)
    B = images.internal.coder.buildable.IntlutBuildable.intlut_core(...
        fcnName, ...
        A, lut, B);
else
    B = images.internal.coder.buildable.IntluttbbBuildable.intluttbb_core(...
        fcnName, ...
        A, lut, B);
end
