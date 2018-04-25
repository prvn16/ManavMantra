function iptcheckconn(varargin)%#codegen
%IPTCHECKCONN Check validity of connectivity argument.

% Copyright 2012-2015 The MathWorks, Inc.

myfun = 'iptcheckconn';
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});
[errid,errmsg] = eml_try_catch(myfun,varargin{:});

errid = coder.internal.const(errid); 
errmsg = coder.internal.const(errmsg); 

eml_lib_assert(isempty(errmsg),errid,errmsg)