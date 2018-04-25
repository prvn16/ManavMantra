function B = morphop(varargin)
%MORPHOP Dilate or erode image.
%  B = morphop(A,SE,OP_TYPE,FUNC_NAME,...) computes the erosion or
%  dilation of A depending on whether OP_TYPE is 'erode' or 'dilate'. SE is
%  a STREL object, array of STREL objects or an NHOOD gpuArray. MORPHOP
%  is intended to be called only by IMDILATE or IMERODE. Any additional
%  arguments passed to IMDILATE or IMERODE should be passed into MORPHOP
%  following FUNC_NAME. See the help entries for IMDILATE and IMERODE for
%  more details about the allowable syntaxes.

%   Copyright 2012-2013 The MathWorks, Inc.

[A,se,padfull,unpad,op_type] = morphopInputParser(varargin{:});

B = morphopAlgo(A,se,padfull,unpad,op_type);
