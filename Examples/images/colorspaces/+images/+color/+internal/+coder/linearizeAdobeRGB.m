function [linearR,linearG,linearB] = linearizeAdobeRGB(R,G,B) %#codegen
%linearizeAdobeRGB Linearize unencoded Adobe RGB 1998 tristimulous values
%
%   The linearization is done using a power function:
%
%     y = x^gamma
%
%   with gamma = 2.19921875. Reference: Section 4.3.5.2.,
%   Adobe RGB (1998) Color Image Encoding, May 2005, p.12.
%
%   The tristimulous input values are expected to be single or double.

%   Copyright 2015 The MathWorks, Inc.

gamma = cast(2.19921875,'like',R);

linearR = R.^gamma;
linearG = G.^gamma;
linearB = B.^gamma;