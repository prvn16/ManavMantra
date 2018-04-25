function copyprops(this,other)
%COPYPROPS(this,other)
%    COPYPROPS(THIS,OTHER) Copy all properties except for the data from
%    fi object THIS to fi object OTHER.  This is a way to get the same
%    data-type information without copying the data.

%   Thomas A. Bryan
%   Copyright 2003-2012 The MathWorks, Inc.

this.DataType            = other.DataType;
this.Scaling             = other.Scaling;
this.Signed              = other.Signed;
this.WordLength          = other.WordLength;
this.FractionLength      = other.FractionLength;
this.Fimath              = fimath(other);
