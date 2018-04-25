function [R,G,B] = delinearizeAdobeRGB(linearR,linearG,linearB) %#codegen
%delinearizeAdobeRGB Convert linear Adobe RGB values to nonlinear Adobe RGB
%
%   The delinearization is done using a power function:
%
%     y = x^gamma,       if x >= 0
%     y = -(-x)^gamma,   otherwise
%
%   with gamma = 1/2.19921875. Reference: Section 4.3.4.2.,
%   Adobe RGB (1998) Color Image Encoding, May 2005, p.12.
%
%   The tristimulous input values are expected to be single or double.

%   Copyright 2015 The MathWorks, Inc.

gamma = cast(1/2.19921875,'like',linearR);

R = abs(linearR).^gamma .* sign(linearR);
G = abs(linearG).^gamma .* sign(linearG);
B = abs(linearB).^gamma .* sign(linearB);