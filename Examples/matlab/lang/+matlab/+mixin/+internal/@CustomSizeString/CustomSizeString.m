classdef (Abstract, HandleCompatible, Hidden) CustomSizeString
    %CustomSizeString  Abstract interface for computing nonstandard sizes
    %    The CustomSizeString class provides an interface for objects that
    %    have a nonnumeric size to report their size to introspective
    %    functions such as WHOS.  The methods implemented by clients of
    %    this class will only change the output of WHOS and utilities that
    %    rely on WHOS such as the Workspace Browser.  In particular,
    %    different utilities use different methods to determine the size of
    %    objects.
    %
    %    CustomSizeString methods:
    %        sizeAsString - Return size to be displayed by WHOS
    %        sizeAsDouble - Return size to be stored by programmatic calls
    %                       to WHOS
    %
    %    INTERNATIONALIZATION: WHOS does not support the display of
    %    characters outside of the standard ASCII character set, so the
    %    CustomSizeString class cannot be used to display characters
    %    outside of the standard ASCII character set.
    %
    %    WARNING: Because introspective utilities such as the Workspace
    %    Browser call WHOS frequently, inefficient implementations of the
    %    methods sizeAsString and sizeAsDouble have the potential to
    %    significantly impact the performance of MATLAB.
    %
    %    Note: CustomSizeString is intended for internal use only and is
    %    subject to change at any time without warning.
    %
    %    Copyright 2016-2017 The MathWorks, Inc.
    
    methods (Abstract)
        
        %sizeAsString  Return size to be displayed by WHOS
        %    s = sizeAsString(obj) should return a MATLAB string that
        %    describes the size of the object obj.  The elements of s will
        %    be placed in the size column displayed by WHOS.  For example,
        %    if s = sizeAsString(obj) returns s = ["M", "N", "P"], WHOS
        %    will display MxNxP in the size column.  The string s must
        %    contain at least 2 elements, none of which are <missing>, and
        %    each element of s must contain only printable characters from
        %    the standard ASCII character set.  Otherwise WHOS will ignore
        %    the output of sizeAsString and display the output from
        %    sizeAsDouble (below) in the size column.  If s contains more
        %    than 4 elements, WHOS will display 5-D in the size column.
        s = sizeAsString(obj);
        
        %sizeAsDouble Return size to be stored by programmatic calls to WHOS
        %    d = sizeAsDouble(obj) should return a double array that
        %    describes the size of the object obj.  The elements of d will
        %    be stored in the size field of the struct returned by
        %    programmatic calls to WHOS (i.e., w = whos).  The array d must
        %    contain at least 2 elements; otherwise WHOS will ignore the
        %    output of sizeAsDouble and store a default size.  If
        %    sizeAsString (above) is not properly overloaded, WHOS will
        %    utilize the output of sizeAsDouble to populate the size
        %    column.
        %
        %    Note: Currently, the Workspace Browser utilizes the size field
        %    of the struct returned by programmatic calls to WHOS.  This
        %    means the output of sizeAsDouble will be displayed in the
        %    Workspace Browser.
        d = sizeAsDouble(obj);
        
    end
    
end
