function addPostChildFunction(hThis,hFunc)
%addPostChildFunction Add a function object after child generation
%
%  addPostChildFunction(hCodeBlock, hFunc) adds a code function that will
%  be generated and inserted into the output after the children of
%  hCodeBlock have been added.

%  Copyright 2015 The MathWorks, Inc.

hThis.PostChildFunctions = [hThis.PostChildFunctions, hFunc];
