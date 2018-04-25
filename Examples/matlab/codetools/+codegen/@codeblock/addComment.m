function addComment(hThis, varargin)
%addComment Add a comment line to the pre-constructor block
%
%  addComment(hCodeBlock, text1, text2, ...) adds the string defined by the
%  given sequence of text items as a comment line that starts with a "% ".
%  The provided text items should not themselves include a comment
%  character.

% Copyright 2015 The MathWorks, Inc.

addText(hThis, '% ', varargin{:});
