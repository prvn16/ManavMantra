function u = createNormalizedFrequencyVector(N) %#codegen
%createNormalizedFrequencyVector N-sample normalized frequency vector.
%
% createNormalizedFrequencyVector generates an N-point normalized frequency
% vector for use in defining filters directly in the frequency domain with
% meshgrid. Mathematically, this function defines the samples of the DFT
% grid in the range [0,N-1]. We then scale and shift this grid roughly
% between [-0.5,0.5], accounting for the necessary odd/even bookkeeping.

% Copyright 2015 The MathWorks, Inc.

if mod(N,2)
    u = linspace(-0.5+1/(2*N),0.5-1/(2*N),N);
else
    u = linspace(-0.5,0.5-1/N,N); 
end

end