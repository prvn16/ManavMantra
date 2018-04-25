%EVENTS Display class event names.
%   EVENTS CLASSNAME displays the names of the public events for
%   the MATLAB class with the name CLASSNAME, including those
%   inherited from base classes.
%
%   Use the functional form of EVENTS, such as EVENTS(S), when 
%   CLASSNAME is a string scalar.
%
%   EVENTS(OBJECT) displays the names of the public events for the
%   class of OBJECT, where OBJECT is an instance of a MATLAB class.
%   OBJECT may be either a scalar object or an array of objects.
%
%   E = EVENTS(...) returns the event names in a cell array of 
%   character vectors.
%
%   The word EVENTS is also used in a MATLAB class definition to
%   denote the start of an events definition block.
%
%   %Example:
%   %Retrieve the names of the public events of class 'handle'
%   %and store the result in a cell array of character vectors.
%   eventnames = events('handle');
%
%   See also PROPERTIES, METHODS, CLASSDEF.

%   Copyright 2007-2017 The MathWorks, Inc.
%   Built-in function.
