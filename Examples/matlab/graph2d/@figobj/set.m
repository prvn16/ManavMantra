function A = set(A, varargin)
%FIGOBJ/SET Set figobj property
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2005 The MathWorks, Inc. 

%don't pass on IsSelected
badValues = strcmp(varargin,'IsSelected');
badIndices = find(badValues);
badValues(badIndices+1)=ones(1,length(badIndices));
okValues = ~badValues;
varargin=varargin(okValues);

if (length(varargin)==2) && strcmp(varargin{1},'IsSelected')
    %do nothing for now
else
    figHG = get(A.aChild, 'Parent');
    set(figHG, varargin{:});
end
