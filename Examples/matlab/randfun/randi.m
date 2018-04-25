%RANDI Pseudorandom integers from a uniform discrete distribution.
%   R = RANDI(IMAX,N) returns an N-by-N matrix containing pseudorandom
%   integer values drawn from the discrete uniform distribution on 1:IMAX.
%   RANDI(IMAX,M,N) or RANDI(IMAX,[M,N]) returns an M-by-N matrix.
%   RANDI(IMAX,M,N,P,...) or RANDI(IMAX,[M,N,P,...]) returns an
%   M-by-N-by-P-by-... array.  RANDI(IMAX) returns a scalar.
%   RANDI(IMAX,SIZE(A)) returns an array the same size as A.
%
%   R = RANDI([IMIN,IMAX],...) returns an array containing integer
%   values drawn from the discrete uniform distribution on IMIN:IMAX.
%
%   Note: The size inputs M, N, P, ... should be nonnegative integers.
%   Negative integers are treated as 0.
%
%   R = RANDI(..., CLASSNAME) returns an array of integer values of class
%   CLASSNAME.
%
%   R = RANDI(..., 'like', Y) returns an array of integer values of the
%   same class as Y.
%
%   The arrays returned by RANDI may contain repeated integer values.  This
%   is sometimes referred to as sampling with replacement.  To get unique
%   integer values, sometimes referred to as sampling without replacement,
%   use RANDPERM.
%
%   The sequence of numbers produced by RANDI is determined by the settings of
%   the uniform random number generator that underlies RAND, RANDN, and RANDI.
%   RANDI uses one uniform random value to create each integer random value.
%   Control that shared random number generator using RNG.
%
%   Examples:
%
%      Example 1: Generate integer values from the uniform distribution on
%      the set 1:10.
%         r = randi(10,100,1);
%
%      Example 2: Generate an integer array of integer values drawn uniformly
%      from 1:10.
%         r = randi(10,100,1,'uint32');
%
%      Example 3: Generate integer values drawn uniformly from -10:10.
%         r = randi([-10 10],100,1);
%
%      Example 4: Reset the random number generator used by RAND, RANDI, and
%      RANDN to its default startup settings, so that RANDI produces the same
%      random numbers as if you restarted MATLAB.
%         rng('default');
%         randi(10,1,5)
%
%      Example 5: Save the settings for the random number generator used by
%      RAND, RANDI, and RANDN, generate 5 values from RANDI, restore the
%      settings, and repeat those values.
%         s = rng
%         i1 = randi(10,1,5)
%         rng(s);
%         i2 = randi(10,1,5) % i2 contains exactly the same values as i1
%
%      Example 6: Reinitialize the random number generator used by RAND,
%      RANDI, and RANDN with a seed based on the current time.  RANDI will
%      return different values each time you do this.  NOTE: It is usually
%      not necessary to do this more than once per MATLAB session.
%         rng('shuffle');
%         randi(10,1,5)
%
%   See also RAND, RANDN, RANDPERM, RNG, RANDSTREAM

%   Copyright 2008-2013 The MathWorks, Inc. 
%   Built-in function.
