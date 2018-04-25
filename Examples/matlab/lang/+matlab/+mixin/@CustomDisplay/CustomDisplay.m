%CustomDisplay    Display customization interface class
%   This class provides a display customization interface that defines a
%   set of utilities for customizing the appearance of a class display.
%
%   Derive your class from matlab.mixin.CustomDisplay to add the custom
%   display functionality to your class.  
%
%   The class provides three public sealed display methods: DISP, DISPLAY,
%   and DETAILS.  The DISP and DISPLAY methods provide a simple object
%   display, and DETAILS provides the detailed formal display.  These
%   methods are marked as hidden.
%
%   An object array is displayed in one of four possible formats depending
%   on the state of the array.  Those formats are:
%       - deleted object (scalar handles only) 
%       - empty object array
%       - scalar object
%       - non-scalar object array
%   Each of these formats can be customized.  Customize a particular
%   format when your class must display in a manner that differs from the
%   standard layout.  Default implementations of each format are
%   provided.
%
%   For each format, the display is broken into three sections:  a header,
%   a list of properties, and a footer.  Overridable methods correspond 
%   to each section; each section may therefore be customized as needed.
%   This allows a class display to follow the standard layout while still
%   customizing the content of a particular section.
%    
%   For example, a class that requires a custom header only when
%   displaying a scalar instance can customize the getHeader method 
%   without needing to customize the entire displayScalarObject method.
%
%   Override one or more of the following methods to implement a fully
%   custom display when your object array is in the corresponding state.  
%   These methods must be implemented as protected methods.
%
%   CustomDisplay methods:
%    displayEmptyObject            - Display for empty object arrays
%    displayScalarObject           - Display format for scalar objects
%    displayNonScalarObject        - Display format for non-scalar object
%                                    arrays 
%
%   Override the following methods to create pieces of a customized
%   display. For classes that utilize the standard layout but require
%   customized content in a particular section, only these methods need to
%   be implemented.  These methods must be implemented as protected
%   methods.
%
%   CustomDisplay methods:
%    getHeader         - Build and return display header text
%    getPropertyGroups - Construct an array of property groups 
%    getFooter         - Build and return display footer text
%    
%   See also matlab.mixin.util.PropertyGroup, disp, display, details        

%   Copyright 2013-2015 The MathWorks, Inc.
%   Built-in class.   

