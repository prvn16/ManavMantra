%% Implement Fixed-Point Log2 Using Lookup Table
% This example shows how to implement fixed-point |log2| using a lookup table.
% Lookup tables generate efficient code for embedded devices.
%
% Copyright 2012-2013 The MathWorks, Inc.
%% 
% *Setup*
%
% To assure that this example does not change your preferences or settings, this
% code stores the original state, and you will restore it at the end.
originalFormat = get(0, 'format'); format long g
originalWarningState = warning('off','fixed:fi:underflow');
originalFiprefState = get(fipref); reset(fipref)
%% Log2 Implementation
% The |log2| algorithm is summarized here.
%
% # Declare the number of bits in a byte, |B|, as a constant.  In this example, |B=8|.
% # Use function |fi_normalize_unsigned_8_bit_byte()| described in
% example <fi_normalize_unsigned_8_bit_byte_example.html Normalize Data for
% Lookup Tables> to normalize the input |u>0| such that |u = x * 2^n| and
% |1 <= x < 2|. 
% # Extract the upper |B|-bits of |x|.
% Let |x_B| denote the upper |B|-bits of |x|. 
% # Generate lookup table, LOG2LUT, such that the integer 
% |i = x_B - 2^(B-1) + 1| is used as an index to
% LOG2LUT so that |log2(x_B)| can be evaluated by looking up
% the index |log2(x_B) = LOG2LUT(i).|
% # Use the remainder, |r = x - x_B|, interpreted as a fraction,
%  to linearly interpolate between |LOG2LUT(i)| 
% and the next value in the table |LOG2LUT(i+1)|. The remainder, |r|,
% is created by extracting the lower |w - B| bits of |x|, where |w| denotes
% the word length of |x|.  It is interpreted as a fraction by using function
% |reinterpretcast()|.
% # Finally, compute the output using the lookup table and linear interpolation:
%
%   log2( u ) = log2( x * 2^n )
%             = n + log2( x )
%             = n + LOG2LUT( i ) + r * ( LOG2LUT( i+1 ) - LOG2LUT( i ) )
%
%
%   function y = fi_log2lookup_8_bit_byte(u) %#codegen
%       % Load the lookup table
%       LOG2LUT = log2_lookup_table();
%       % Remove fimath from the input to insulate this function from math
%       % settings declared outside this function.
%       u = removefimath(u);
%       % Declare the output
%       y = coder.nullcopy(fi(zeros(size(u)), numerictype(LOG2LUT), fimath(LOG2LUT)));
%       B = 8; % Number of bits in a byte
%       w = u.WordLength;
%       for k = 1:numel(u)
%           assert(u(k)>0,'Input must be positive.');
%           % Normalize the input such that u = x * 2^n and 1 <= x < 2
%           [x,n] = fi_normalize_unsigned_8_bit_byte(u(k));
%           % Extract the high byte of x
%           high_byte = storedInteger(bitsliceget(x, w, w - B + 1));
%           % Convert the high byte into an index for LOG2LUT
%           i = high_byte - 2^(B-1) + 1;
%           % Interpolate between points.
%           % The upper byte was used for the index into LOG2LUT
%           % The remaining bits make up the fraction between points.
%           T_unsigned_fraction = numerictype(0, w-B, w-B);
%           r = reinterpretcast(bitsliceget(x,w-B,1), T_unsigned_fraction);
%           y(k) = n + LOG2LUT(i) + ...
%                  r*(LOG2LUT(i+1) - LOG2LUT(i)) ;
%       end
%       % Remove fimath from the output to insulate the caller from math settings
%       % declared inside this function.
%       y = removefimath(y);
%   end

%% Log2 Lookup Table
% Function |log2_lookup_table| loads the lookup table of |log2| values.  You
% can create the table by running:
%
%   B = 8;
%   log2_table = log2((2^(B-1) : 2^(B)) / 2^(B - 1))
%
%
%   function LOG2LUT = log2_lookup_table()
%       B = 8;  % Number of bits in a byte
%       % log2_table = log2((2^(B-1) : 2^(B)) / 2^(B - 1))
%       log2_table = [0.000000000000000   0.011227255423254   0.022367813028454   0.033423001537450 ...
%                     0.044394119358453   0.055282435501190   0.066089190457773   0.076815597050831 ...
%                     0.087462841250339   0.098032082960527   0.108524456778169   0.118941072723507 ...
%                     0.129283016944966   0.139551352398794   0.149747119504682   0.159871336778389 ...
%                     0.169925001442312   0.179909090014934   0.189824558880017   0.199672344836364 ...
%                     0.209453365628950   0.219168520462162   0.228818690495881   0.238404739325079 ...
%                     0.247927513443586   0.257387842692652   0.266786540694901   0.276124405274238 ...
%                     0.285402218862248   0.294620748891627   0.303780748177103   0.312882955284355 ...
%                     0.321928094887362   0.330916878114617   0.339850002884625   0.348728154231078 ...
%                     0.357552004618084   0.366322214245816   0.375039431346925   0.383704292474052 ...
%                     0.392317422778760   0.400879436282184   0.409390936137702   0.417852514885898 ...
%                     0.426264754702098   0.434628227636725   0.442943495848728   0.451211111832329 ...
%                     0.459431618637297   0.467605550082997   0.475733430966398   0.483815777264256 ...
%                     0.491853096329675   0.499845887083205   0.507794640198696   0.515699838284042 ...
%                     0.523561956057013   0.531381460516312   0.539158811108031   0.546894459887637 ...
%                     0.554588851677637   0.562242424221073   0.569855608330948   0.577428828035749 ...
%                     0.584962500721156   0.592457037268080   0.599912842187128   0.607330313749611 ...
%                     0.614709844115208   0.622051819456376   0.629356620079610   0.636624620543649 ...
%                     0.643856189774725   0.651051691178929   0.658211482751795   0.665335917185176 ...
%                     0.672425341971496   0.679480099505446   0.686500527183218   0.693486957499325 ...
%                     0.700439718141092   0.707359132080883   0.714245517666123   0.721099188707185 ...
%                     0.727920454563199   0.734709620225838   0.741466986401147   0.748192849589460 ...
%                     0.754887502163469   0.761551232444479   0.768184324776926   0.774787059601173 ...
%                     0.781359713524660   0.787902559391432   0.794415866350106   0.800899899920305 ...
%                     0.807354922057604   0.813781191217037   0.820178962415188   0.826548487290915 ...
%                     0.832890014164742   0.839203788096944   0.845490050944375   0.851749041416058 ...
%                     0.857980995127572   0.864186144654280   0.870364719583405   0.876516946565000 ...
%                     0.882643049361841   0.888743248898259   0.894817763307943   0.900866807980749 ...
%                     0.906890595608518   0.912889336229962   0.918863237274595   0.924812503605781 ...
%                     0.930737337562886   0.936637939002571   0.942514505339240   0.948367231584678 ...
%                     0.954196310386875   0.960001932068081   0.965784284662087   0.971543553950772 ...
%                     0.977279923499916   0.982993574694310   0.988684686772166   0.994353436858858 ...
%                     1.000000000000000];
%   
%       % Cast to fixed point with the most accurate rounding method
%       WL = 4*B;  % Word length
%       FL = 2*B;  % Fraction length
%       LOG2LUT = fi(log2_table,1,WL,FL,'RoundingMethod','Nearest');
%       % Set fimath for the most efficient math operations
%       F = fimath('OverflowAction','Wrap',...
%                  'RoundingMethod','Floor',...
%                  'SumMode','SpecifyPrecision',...
%                  'SumWordLength',WL,...
%                  'SumFractionLength',FL,...
%                  'ProductMode','SpecifyPrecision',...
%                  'ProductWordLength',WL,...
%                  'ProductFractionLength',2*FL);
%       LOG2LUT = setfimath(LOG2LUT,F);
%   end

%% Example
u = fi(linspace(0.001,20,100));

y = fi_log2lookup_8_bit_byte(u);

y_expected = log2(double(u));
%%3
clf
subplot(211)
plot(u,y,u,y_expected)
legend('Output','Expected output','Location','Best')

subplot(212)
plot(u,double(y)-y_expected,'r')
legend('Error')
figure(gcf)


%% 
% *Cleanup*
%
% Restore original state.
set(0, 'format', originalFormat);
warning(originalWarningState);
fipref(originalFiprefState);
displayEndOfDemoMessage(mfilename)

