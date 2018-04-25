function s = hashEquation(a)
% HASHEQUATION  Converts an arbitrary string into one suitable for a filename.
%   HASHEQUATION(A) returns a string usitable for a filename.

% Matthew J. Simoneau
% Copyright 1984-2013 The MathWorks, Inc. 

if isempty(a)
    a = ' ';
end

% Get the MD5 hash of the string as two UINT64s.
messageDigest = java.security.MessageDigest.getInstance('MD5');
h = messageDigest.digest(double(a));
q = typecast(h,'uint64');

% Use the zero-padded base 10 representation of the first UINT64.
t = sprintf('%lu',q(1));
nmax = numel(sprintf('%lu',intmax('uint64')));
s = ['eq' repmat('0',1,nmax-numel(t)) t];
