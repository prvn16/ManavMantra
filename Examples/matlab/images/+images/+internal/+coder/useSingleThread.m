function TF = useSingleThread() %#codegen
%USESINGLETHREAD Flag indicating if codegen solution needs to use single thread.
%

% Copyright 2014-2015 The MathWorks, Inc.

% Query the number of threads used at compile time
myfun      = 'feature';
coder.extrinsic('eml_try_catch');
[errid, errmsg, numThreads] = eml_try_catch(myfun, 'numthreads');
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
numThreads = coder.internal.const(numThreads);

eml_lib_assert(isempty(errmsg), errid, errmsg);

TF = (numThreads==1);
