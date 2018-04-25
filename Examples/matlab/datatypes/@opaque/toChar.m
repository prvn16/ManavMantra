function str = toChar(javaObject)
%TOCHAR overload of java toChar so that it defaults to toString 
%
%  STR = TOCHAR(JAVAOBJECT)
%
% The @opaque/char method always uses the java toChar method to convert
% a java object into a character array. Since many java objects do not
% implement this method, we define a default toChar method here that
% redirects to toString(), a method that all java objects implement.
% Since this function is intended to overload the java toChar method
% we need not worry about array inputs.

%  Copyright 2000-2005 The MathWorks, Inc.


str = '';
if isjava(javaObject)
    str = toString(javaObject);
end