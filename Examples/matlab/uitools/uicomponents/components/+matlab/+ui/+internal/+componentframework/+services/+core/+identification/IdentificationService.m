% IDENTIFICATIONSERVICE is the abstract class which provides the interface to
% the Identification Service (IS), which is a core service of the Component
% Framework.
%
% This interface class provides the following capabilities:
%
%     1) Ability to uniquely identify individual web components so as to create
%        testers for them and conduct testing.
%     2) Special access interface to a limited number of predetermined software
%        entities. This capability eliminates the "public" exposure of the 
%        unique identifier for the web components. 
%
% Copyright 2014 The MathWorks, Inc.
classdef (Abstract)  IdentificationService < handle
end
