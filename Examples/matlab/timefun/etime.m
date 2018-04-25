function t = etime(t1,t0)
%ETIME  Elapsed time.
%   ETIME(T1,T0) returns the time in seconds that has elapsed between
%   vectors T1 and T0.  The two vectors must be six elements long, in
%   the format returned by CLOCK:
%
%       T = [Year Month Day Hour Minute Second]
%
%   Time differences over many orders of magnitude are computed accurately.
%   The result can be thousands of seconds if T1 and T0 differ in their
%   first five components, or small fractions of seconds if the first five
%   components are equal.
%
%   Note: When timing the duration of an event, use the TIC and TOC
%   functions instead of CLOCK or ETIME. These latter two functions are
%   based on the system time which can be adjusted periodically by the
%   operating system and thus might not be reliable in time comparison
%   operations.
%
%   Example:
%     This example shows two ways to calculate how long a particular FFT 
%     operation takes. Using TIC and TOC is preferred, as it can be 
%     more reliable for timing the duration of an event:
%
%     x = rand(800000, 1);
%     
%     t1 = tic;  fft(x);  toc(t1)             % Recommended
%     Elapsed time is 0.097665 seconds.
%     
%     t = clock;  fft(x);  etime(clock, t)
%     ans =
%         0.1250
%
%   See also TIC, TOC, CLOCK, CPUTIME, DATENUM.

%   Copyright 1984-2002 The MathWorks, Inc. 

% Compute time difference accurately to preserve fractions of seconds.

t = 86400*(datenummx(t1(:,1:3)) - datenummx(t0(:,1:3))) + ...
    (t1(:,4:6) - t0(:,4:6))*[3600; 60; 1];
