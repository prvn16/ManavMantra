function indentedText = indentcode(text,language)
%indentcode Indents code.
%   indentcode(T) indents text T according to user's preferences specified
%   for the MATLAB language. Indented text retains the same line separator
%   style as specified by the input text.
%
%   indentcode(T,L) specifies language L and must be one of the following:
%       'c', 'java', 'matlab', 'plain', 'simscape', 'tlc', 'verilog',
%       'vhdl', 'xml'.
%
%   This file is for internal use only and is subject to change without
%   notice.

%   Copyright 2012 The MathWorks, Inc.

error(javachk('swing'));
narginchk(1,2);
if ~ischar(text)
    error(message('MATLAB:INDENTCODE:NotString'));
end
if nargin < 2
    language = 'matlab';
end
switch language
    case 'c'
        langInst = com.mathworks.widgets.text.cplusplus.CLanguage.INSTANCE;
    case 'java'
        langInst = com.mathworks.widgets.text.java.JavaLanguage.INSTANCE;
    case 'matlab'
        langInst = com.mathworks.widgets.text.mcode.MLanguage.INSTANCE;
    case 'simscape'
        langInst = com.mathworks.widgets.text.simscape.SimscapeLanguage.INSTANCE;
    case 'xml'
        langInst = com.mathworks.widgets.text.xml.XMLLanguage.INSTANCE;
    otherwise
        error(message('MATLAB:INDENTCODE:InvalidLanguage'));
end
indentedText = char(com.mathworks.widgets.text.EditorLanguageUtils.indentText(...
    langInst,text));
end
