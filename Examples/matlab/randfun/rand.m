%RAND Uniformly distributed pseudorandom numbers.
%   R = RAND(N) returns an N-by-N matrix containing pseudorandom values drawn
%   from the standard uniform distribution on the open interval(0,1).  RAND(M,N)
%   or RAND([M,N]) returns an M-by-N matrix.  RAND(M,N,P,...) or
%   RAND([M,N,P,...]) returns an M-by-N-by-P-by-... array.  RAND returns a
%   scalar.  RAND(SIZE(A)) returns an array the same size as A.
%
%   Note: The size inputs M, N, P, ... should be nonnegative integers.
%   Negative integers are treated as 0.
%
%   R = RAND(..., CLASSNAME) returns an array of uniform values of the 
%   specified class. CLASSNAME can be 'double' or 'single'.
%
%   R = RAND(..., 'like', Y) returns an array of uniform values of the 
%   same class as Y.
%
%   The sequence of numbers produced by RAND is determined by the settings of
%   the uniform random number generator that underlies RAND, RANDI, and RANDN.
%   Control that shared random number generator using RNG.
%
%   Examples:
%
%      Example 1: Generate values from the uniform distribution on the
%      interval (a, b).
%         r = a + (b-a).*rand(100,1);
%
%      Example 2: Use the RANDI function, instead of RAND, to generate
%      integer values from the uniform distribution on the set 1:100.
%         r = randi(100,1,5);
%
%      Example 3: Reset the random number generator used by RAND, RANDI, and
%      RANDN to its default startup settings, so that RAND produces the same
%      random numbers as if you restarted MATLAB.
%         rng('default')
%         rand(1,5)
%
%      Example 4: Save the settings for the random number generator used by
%      RAND, RANDI, and RANDN, generate 5 values from RAND, restore the
%      settings, and repeat those values.
%         s = rng
%         u1 = rand(1,5)
%         rng(s);
%         u2 = rand(1,5) % contains exactly the same values as u1
%
%      Example 5: Reinitialize the random number generator used by RAND,
%      RANDI, and RANDN with a seed based on the current time.  RAND will
%      return different values each time you do this.  NOTE: It is usually
%      not necessary to do this more than once per MATLAB session.
%         rng('shuffle');
%         rand(1,5)
%
%   See <a href="matlab:helpview([docroot '\techdoc\math\math.map'],'update_random_number_generator')">Replace Discouraged Syntaxes of rand and randn</a> to use RNG to replace
%   RAND with the 'seed', 'state', or 'twister' inputs.
%
%   See also RANDI, RANDN, RNG, RANDSTREAM, RANDSTREAM/RAND,
%            SPRAND, SPRANDN, RANDPERM.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.


% ================ Copyright notice for the Mersenne Twister ================
%
%    A C-program for MT19937, with initialization improved 2002/1/26.
%    Coded by Takuji Nishimura and Makoto Matsumoto.
%
%    Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
%    All rights reserved.
%
%    Redistribution and use in source and binary forms, with or without
%    modification, are permitted provided that the following conditions
%    are met:
%
%      1. Redistributions of source code must retain the above copyright
%         notice, this list of conditions and the following disclaimer.
%
%      2. Redistributions in binary form must reproduce the above copyright
%         notice, this list of conditions and the following disclaimer in the
%         documentation and/or other materials provided with the distribution.
%
%      3. The names of its contributors may not be used to endorse or promote
%         products derived from this software without specific prior written
%         permission.
%
%    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
%    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
%    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
%    A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
%    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
%    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
%    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
%    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
%    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
%    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%
%    Any feedback is very welcome.
%    http://www.math.keio.ac.jp/matumoto/emt.html
%    email: matumoto@math.keio.ac.jp

% ================ end ================
