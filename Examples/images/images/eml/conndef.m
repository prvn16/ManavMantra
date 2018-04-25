function conn = conndef(num_dims,type) %#codegen
%CONNDEF Default connectivity array.

% Copyright 2012-2015 The MathWorks, Inc.

myfun = 'conndef';
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(num_dims,type);

[errid,errmsg,conn] = eml_try_catch(myfun,num_dims,type);

errid = coder.internal.const(errid); 
errmsg = coder.internal.const(errmsg); 
conn = coder.internal.const(conn); 

eml_lib_assert(isempty(errmsg),errid,errmsg);
