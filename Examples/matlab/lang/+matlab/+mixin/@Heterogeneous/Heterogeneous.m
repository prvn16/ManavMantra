%matlab.mixin.Heterogeneous  Superclass for heterogeneous array formation
%   matlab.mixin.Heterogeneous is an abstract class that provides support
%   for the formation of heterogeneous arrays. A heterogeneous array is an
%   array of objects that differ in their specific class, but are all 
%   derived from or are instances of a common root class.  The root class
%   derives directly from matlab.mixin.Heterogeneous.
%
%   The following class definition makes HierarchyRoot a direct subclass of 
%   matlab.mixin.Heterogeneous:
%   
%   classdef HierarchyRoot < matlab.mixin.Heterogeneous 
%
%   This class definition enables the formation of heterogeneous arrays
%   that combine instances of any classes derived from HierarchyRoot.
%   Only instances of classes derived from the same root class can be
%   combined together to form a heterogeneous array.
%
%   The class of a heterogeneous array is always that of the most specific
%   superclass common to all instances of the array.  For example, given 
%   the following class hierarchy:
%
%                      matlab.mixin.Heterogeneous
%                                  |
%                           HierarchyRoot
%                              /        \
%                           Middle       LeafD
%                         /    |   \ 
%                    LeafA   LeafB  LeafC
%
%    concatenating together an instance of LeafA with an instance of LeafB 
%    yields an array of class Middle.  
%    
%    Method invocation on heterogeneous arrays is based on the class of
%    the array at the time the method is invoked.  Only sealed methods can 
%    be invoked on a heterogeneous array.   
%
%    matlab.mixin.Heterogeneous methods:
%        cat     - Heterogeneous concatenation.
%        horzcat - Heterogeneous horizontal concatenation.
%        vertcat - Heterogeneous vertical concatenation.
%
%    matlab.mixin.Heterogeneous protected methods:
%         getDefaultScalarElement - Define default element for array operations.

%   Copyright 2008-2010 The MathWorks, Inc.
%   Built-in class.
