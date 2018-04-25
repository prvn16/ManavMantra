function B = eps(A)
%EPS    Quantized relative accuracy
%
%   See also EMBEDDED.QUANTIZER/EPS

% 
% Copyright 2003-2012 The MathWorks, Inc.

if isscaledtype(A)
    B = A.fieps;
    % xxx Calling the builtin fieps method using the dot notation somehow
    % xxx or the embedded.fi constructor here seems to disregard the fimath-less-ness of the fi on the output.
    % xxx This is only here: in functions in the @embedded/@fi directory.
    % xxx A way to fix this is to call fieps using the functional notation: fieps(A)
    % xxx or to explicitly set the fimathless'ness here. Choosing to do the latter
    % xxx because its difficult to remember when to call a builtin using dot notation
    % xxx or functional form.
    B.fimathislocal = isfimathlocal(A);
elseif isdouble(A)
    B = embedded.fi(eps(double(A)),A.numerictype,A.fimath);
    B.fimathislocal = false;
elseif issingle(A)
    B = embedded.fi(eps(single(A)),A.numerictype,A.fimath);
    B.fimathislocal = false;
elseif isboolean(A)
    B = embedded.fi(1,A.numerictype,A.fimath);
    B.fimathislocal = false;
else
    error(message('fixed:fi:invalidSyntax','eps'));
end

% LocalWords:  fieps ness fimathless'ness
