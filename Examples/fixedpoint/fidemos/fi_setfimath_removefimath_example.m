%% Set Fixed-Point Math Attributes
% This example shows how to set fixed point math attributes in MATLAB(R) code.
%
% You can control fixed-point math attributes for assignment,
% addition, subtraction, and multiplication using the
% <matlab:helpview([docroot,'/fixedpoint/ref/fimath.html']); |fimath|> object.  You can attach a
% |fimath| object to a <matlab:helpview([docroot,'/fixedpoint/ref/fi.html']); |fi|> object using
% <matlab:helpview([docroot,'/fixedpoint/ref/setfimath.html']); |setfimath|>.  You can remove a
% |fimath| object from a |fi| object using
% <matlab:helpview([docroot,'/fixedpoint/ref/removefimath.html']); |removefimath|>.
%
% You can generate C code from the examples if you have MATLAB
% Coder(TM) software.
%
% Copyright 2012 The MathWorks, Inc.
%% Set and Remove Fixed Point Math Attributes
% You can insulate your fixed-point operations from global and local 
% <matlab:helpview([docroot,'/fixedpoint/ref/fimath.html']); |fimath|> settings by using the 
% <matlab:helpview([docroot,'/fixedpoint/ref/setfimath.html']); |setfimath|> and 
% <matlab:helpview([docroot,'/fixedpoint/ref/removefimath.html']); |removefimath|> functions.
% You can also return from functions with no |fimath| attached to output
% variables.  This gives you local control over fixed-point math settings
% without interfering with the settings in other functions.
%
% *MATLAB Code*
%
%   function y = user_written_sum(u)
%       % Setup
%       F = fimath('RoundingMethod','Floor',...
%           'OverflowAction','Wrap',...
%           'SumMode','KeepLSB',...
%           'SumWordLength',32);
%       u = setfimath(u,F);
%       y = fi(0,true,32,get(u,'FractionLength'),F);
%       % Algorithm
%       for i=1:length(u)
%           y(:) = y + u(i);
%       end
%       % Cleanup
%       y = removefimath(y);
%   end
%
% *Output has no Attached FIMATH*
%
% When you run the code, the |fimath| controls the arithmetic inside the
% function, but the return value has no attached |fimath|.  This is due to
% the use of |setfimath| and |removefimath| inside the function
% |user_written_sum|.
%
%   >> u = fi(1:10,true,16,11);
%   >> y = user_written_sum(u)
%
%   y =
%       55
%             DataTypeMode: Fixed-point: binary point scaling
%               Signedness: Signed
%               WordLength: 32
%           FractionLength: 11
%
% *Generated C Code*
%
% If you have MATLAB Coder software, you can generate C code using the following
% commands. 
%
%   >> u = fi(1:10,true,16,11);
%   >> codegen user_written_sum -args {u} -config:lib -launchreport
%
% Functions |fimath|, |setfimath| and |removefimath| control the fixed-point
% math, but the underlying data contained in the variables does not change and
% so the generated C code does not produce any data copies.
%
%  int32_T user_written_sum(const int16_T u[10])
%  {
%    int32_T y;
%    int32_T i;
%    /* Setup */
%    y = 0;
%    /* Algorithm */
%    for (i = 0; i < 10; i++) {
%      y += u[i];
%    }
%    /* Cleanup */
%    return y;
%  }
%
%% Mismatched FIMATH
%
% When you operate on |fi| objects, their |fimath| properties must be equal,
% or you get an error.
%
%   >> A = fi(pi,'ProductMode','KeepLSB');
%   >> B = fi(2,'ProductMode','SpecifyPrecision');
%   >> C = A * B
%
%  Error using embedded.fi/mtimes
%  The embedded.fimath of both operands must be equal.
%
% To avoid this error, you can remove |fimath| from one of the variables in
% the expression.  In this example, the |fimath| is removed from |B| in the
% context of the expression without modifying |B| itself, and the product is
% computed using the |fimath| attached to |A|.
%
%   >> C = A * removefimath(B)
%
%   C =
%    
%                  6.283203125
%   
%             DataTypeMode: Fixed-point: binary point scaling
%               Signedness: Signed
%               WordLength: 32
%           FractionLength: 26
%   
%           RoundingMethod: Nearest
%           OverflowAction: Saturate
%              ProductMode: KeepLSB
%        ProductWordLength: 32
%                  SumMode: FullPrecision
%
%
%% Changing FIMATH on Temporary Variables
% If you have variables with no attached |fimath|, but you want to control a
% particular operation, then you can attach a |fimath| in the context of the
% expression without modifying the variables.
%
% For example, the product is computed with the |fimath| defined by |F|.
%
%   >> F = fimath('ProductMode','KeepLSB','OverflowAction','Wrap','RoundingMethod','Floor');
%   >> A = fi(pi);
%   >> B = fi(2);
%   >> C = A * setfimath(B,F)
%
%   C =
%
%       6.2832
%
%             DataTypeMode: Fixed-point: binary point scaling
%               Signedness: Signed
%               WordLength: 32
%           FractionLength: 26
%
%           RoundingMethod: Floor
%           OverflowAction: Wrap
%              ProductMode: KeepLSB
%        ProductWordLength: 32
%                  SumMode: FullPrecision
%         MaxSumWordLength: 128
%
%
% Note that variable |B| is not changed.
%
%
%   >> B
%
%   B =
%
%        2
%
%             DataTypeMode: Fixed-point: binary point scaling
%               Signedness: Signed
%               WordLength: 16
%           FractionLength: 13
%
%
%
%% Removing FIMATH Conflict in a Loop
% You can compute products and sums to match the accumulator of a DSP with floor
% rounding and wrap overflow, and use nearest rounding and saturate overflow on
% the output.  To avoid mismatched |fimath| errors, you can remove the
% |fimath| on the output variable when it is used in a computation with the
% other variables.
%
% *MATLAB Code*
%
% In this example, the products are 32-bits, and the accumulator is 40-bits,
% keeping the least-significant-bits with floor rounding and wrap overflow like
% C's native integer rules.  The output uses nearest rounding and saturate
% overflow.
%
%   function [y,z] = setfimath_removefimath_in_a_loop(b,a,x,z)
%       % Setup
%       F_floor = fimath('RoundingMethod','Floor',...
%              'OverflowAction','Wrap',...
%              'ProductMode','KeepLSB',...
%              'ProductWordLength',32,...
%              'SumMode','KeepLSB',...
%              'SumWordLength',40);
%       F_nearest = fimath('RoundingMethod','Nearest',...
%           'OverflowAction','Wrap');
%       % Set fimaths that are local to this function
%       b = setfimath(b,F_floor);
%       a = setfimath(a,F_floor);
%       x = setfimath(x,F_floor);
%       z = setfimath(z,F_floor);
%       % Create y with nearest rounding
%       y = coder.nullcopy(fi(zeros(size(x)),true,16,14,F_nearest));
%       % Algorithm
%       for j=1:length(x)
%           % Nearest assignment into y
%           y(j) =  b(1)*x(j) + z(1);
%           % Remove y's fimath conflict with other fimaths
%           z(1) = (b(2)*x(j) + z(2)) - a(2) * removefimath(y(j));
%           z(2) =  b(3)*x(j)         - a(3) * removefimath(y(j));
%       end
%       % Cleanup: Remove fimath from outputs
%       y = removefimath(y);
%       z = removefimath(z);
%   end
%
% *Code Generation Instructions*
%
% If you have MATLAB Coder software, you can generate C code with the specificed hardware
% characteristics using the following commands.
%
%   N = 256;
%   t = 1:N;
%   xstep = [ones(N/2,1);-ones(N/2,1)];
%   num = [0.0299545822080925  0.0599091644161849  0.0299545822080925];
%   den = [1                  -1.4542435862515900  0.5740619150839550];
%
%   b = fi(num,true,16);
%   a = fi(den,true,16);
%   x = fi(xstep,true,16,15);
%   zi = fi(zeros(2,1),true,16,14);
%
%   B = coder.Constant(b);
%   A = coder.Constant(a);
%
%   config_obj = coder.config('lib');
%   config_obj.GenerateReport = true;
%   config_obj.LaunchReport = true;
%   config_obj.TargetLang = 'C';
%   config_obj.GenerateComments = true;
%   config_obj.GenCodeOnly = true;
%   config_obj.HardwareImplementation.ProdBitPerChar=8;
%   config_obj.HardwareImplementation.ProdBitPerShort=16;
%   config_obj.HardwareImplementation.ProdBitPerInt=32;
%   config_obj.HardwareImplementation.ProdBitPerLong=40;
%
%
%   codegen -config config_obj setfimath_removefimath_in_a_loop -args {B,A,x,zi} -launchreport
%
% *Generated C Code*
%
% Functions |fimath|, |setfimath| and |removefimath| control the fixed-point
% math, but the underlying data contained in the variables does not change and
% so the generated C code does not produce any data copies.
%
%  void setfimath_removefimath_in_a_loop(const int16_T x[256], int16_T z[2],
%    int16_T y[256])
%  {
%    int32_T j;
%    int40_T i0;
%    int16_T b_y;
%  
%    /* Setup */
%    /* Set fimaths that are local to this function */
%    /* Create y with nearest rounding */
%    /* Algorithm */
%    for (j = 0; j < 256; j++) {
%      /* Nearest assignment into y */
%      i0 = 15705 * x[j] + ((int40_T)z[0] << 20);
%      b_y = (int16_T)((int32_T)(i0 >> 20) + ((i0 & 524288L) != 0L));
%  
%      /* Remove y's fimath conflict with other fimaths */
%      z[0] = (int16_T)(((31410 * x[j] + ((int40_T)z[1] << 20)) - ((int40_T)(-23826
%        * b_y) << 6)) >> 20);
%      z[1] = (int16_T)((15705 * x[j] - ((int40_T)(9405 * b_y) << 6)) >> 20);
%      y[j] = b_y;
%    }
%  
%    /* Cleanup: Remove fimath from outputs */
%  }
%
%% Polymorphic Code
% You can write MATLAB code that can be used for both floating-point and
% fixed-point types using |setfimath| and |removefimath|.
%
%   function y = user_written_function(u)
%       % Setup
%       F = fimath('RoundingMethod','Floor',...
%           'OverflowAction','Wrap',...
%           'SumMode','KeepLSB');
%       u = setfimath(u,F);
%       % Algorithm
%       y = u + u;
%       % Cleanup
%       y = removefimath(y);
%   end
%
% *Fixed Point Inputs*
%
% When the function is called with fixed-point inputs, then |fimath| |F| is
% used for the arithmetic, and the output has no attached |fimath|.
%
%   >> u = fi(pi/8,true,16,15,'RoundingMethod','Convergent');
%   >> y = user_written_function(u)
%
%   y =
%    
%               0.785400390625
%   
%             DataTypeMode: Fixed-point: binary point scaling
%               Signedness: Signed
%               WordLength: 32
%           FractionLength: 15
%
% *Generated C Code for Fixed Point*
%
% If you have MATLAB Coder software, you can generate C code using the following
% commands. 
%
%   >> u = fi(pi/8,true,16,15,'RoundingMethod','Convergent');
%   >> codegen user_written_function -args {u} -config:lib -launchreport
%
% Functions |fimath|, |setfimath| and |removefimath| control the fixed-point
% math, but the underlying data contained in the variables does not change and
% so the generated C code does not produce any data copies.
%
%  int32_T user_written_function(int16_T u)
%  {
%    /* Setup */
%    /* Algorithm */
%    /* Cleanup */
%    return u + u;
%  }
%
%
% *Double Inputs*
%
% Since |setfimath| and |removefimath| are pass-through for
% floating-point types, the |user_written_function| example works with
% floating-point types, too.  
%
%   function y = user_written_function(u)
%       % Setup
%       F = fimath('RoundingMethod','Floor',...
%           'OverflowAction','Wrap',...
%           'SumMode','KeepLSB');
%       u = setfimath(u,F);
%       % Algorithm
%       y = u + u;
%       % Cleanup
%       y = removefimath(y);
%   end
%
% *Generated C Code for Double*
%
% When compiled with floating-point input, you get the
% following generated C code.
%
%   >> codegen user_written_function -args {0} -config:lib -launchreport
%
%  real_T user_written_function(real_T u)
%  {
%    return u + u;
%  }
%
% Where the |real_T| type is defined as a |double|:
%
%  typedef double real_T;
%
%
%% More Polymorphic Code
% This function is written so that the output is created to be the same type
% as the input, so both floating-point and fixed-point can be used with it.
%
%
%   function y = user_written_sum_polymorphic(u)
%       % Setup
%       F = fimath('RoundingMethod','Floor',...
%           'OverflowAction','Wrap',...
%           'SumMode','KeepLSB',...
%           'SumWordLength',32);
%
%       u = setfimath(u,F);
%
%       if isfi(u)
%           y = fi(0,true,32,get(u,'FractionLength'),F);
%       else
%           y = zeros(1,1,class(u));
%       end
%
%       % Algorithm
%       for i=1:length(u)
%           y(:) = y + u(i);
%       end
%
%       % Cleanup
%       y = removefimath(y);
%
%   end
%
% *Fixed Point Generated C Code*
%
% If you have MATLAB Coder software, you can generate fixed-point C code using the
% following commands. 
%
%   >> u = fi(1:10,true,16,11);
%   >> codegen user_written_sum_polymorphic -args {u} -config:lib -launchreport
%
% Functions |fimath|, |setfimath| and |removefimath| control the fixed-point
% math, but the underlying data contained in the variables does not change and
% so the generated C code does not produce any data copies.
%
%  int32_T user_written_sum_polymorphic(const int16_T u[10])
%  {
%    int32_T y;
%    int32_T i;
%  
%    /* Setup */
%    y = 0;
%  
%    /* Algorithm */
%    for (i = 0; i < 10; i++) {
%      y += u[i];
%    }
%  
%    /* Cleanup */
%    return y;
%  }
%
%
% *Floating Point Generated C Code*
%
% If you have MATLAB Coder software, you can generate floating-point C code using the
% following commands. 
%
%   >> u = 1:10;
%   >> codegen user_written_sum_polymorphic -args {u} -config:lib -launchreport
%
%  real_T user_written_sum_polymorphic(const real_T u[10])
%  {
%    real_T y;
%    int32_T i;
%  
%    /* Setup */
%    y = 0.0;
%  
%    /* Algorithm */
%    for (i = 0; i < 10; i++) {
%      y += u[i];
%    }
%  
%    /* Cleanup */
%    return y;
%  }
%
%
% Where the |real_T| type is defined as a |double|:
%
%  typedef double real_T;
%
%% SETFIMATH on Integer Types
%
% Following the established pattern of treating built-in integers
% like |fi| objects, |setfimath| converts integer input to the
% equivalent |fi| with attached |fimath|. 
%
%
%   >> u = int8(5);
%   >> codegen user_written_u_plus_u -args {u} -config:lib -launchreport
%
%   function y = user_written_u_plus_u(u)
%       % Setup
%       F = fimath('RoundingMethod','Floor',...
%           'OverflowAction','Wrap',...
%           'SumMode','KeepLSB',...
%           'SumWordLength',32);
%       u = setfimath(u,F);
%       % Algorithm
%       y = u + u;
%       % Cleanup
%       y = removefimath(y);
%   end
%
% The output type was specified by the |fimath| to be 32-bit.
%
%  int32_T user_written_u_plus_u(int8_T u)
%  {
%    /* Setup */
%    /* Algorithm */
%    /* Cleanup */
%    return u + u;
%  }
%
%%
displayEndOfDemoMessage(mfilename)

