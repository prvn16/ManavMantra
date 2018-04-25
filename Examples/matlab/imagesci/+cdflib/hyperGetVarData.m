function data = hyperGetVarData(cdfId,varNum,recSpec,dimSpec)
%cdflib.hyperGetVarData Read hyperslab
%   data = cdflib.hyperGetVarData(cdfId,varNum,recSpec,dimSpec) reads a 
%   hyperslab of data from the variable specified by varNum in the CDF
%   identified by cdfId.  The hyperslab is described by the record 
%   specification recSpec and the dimension specification dimSpec.  recSpec 
%   is a three-element array described by [RSTART RCOUNT RSTRIDE], where 
%   RSTART, RCOUNT, and RSTRIDE are scalar values giving the start, number 
%   of records, and sampling interval or stride between records.  dimSpec 
%   is a three-element cell array described by {DSTART DCOUNT DSTRIDE}, 
%   where DSTART, DCOUNT, and DSTRIDE are n-element vectors that describe 
%   the start, number of values along each dimension, and sampling interval 
%   along each dimension.
%
%   data = cdflib.hyperGetVarData(cdfId,varNum,recSpec) reads a hyperslab
%   of data for a zero-dimensional variable.
%
%   All record numbers and dimension indices are zero-based numbers.
%
%   This function corresponds to the CDF library C API routine 
%   CDFhyperGetzVarData.  
%
%   Example:  Retrieve the first element in the first six records of the
%   'Temperature' variable.
%       cdfid = cdflib.open('example.cdf');
%       varnum = cdflib.getVarNum(cdfid,'Temperature');
%       recspec = [0 6 1];
%       dimspec = {[0 0], [1 1], [1 1]};
%       data = cdflib.hyperGetVarData(cdfid,varnum,recspec,dimspec);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.hyperPutVarData.

%   Copyright 2009-2013 The MathWorks, Inc.


validateattributes(recSpec,{'double'},{'real','finite','size',[1 3]},'','recSpec');

recstart = recSpec(1);
reccount = recSpec(2);
recstride = recSpec(3);

info = cdflib.inquireVar(cdfId,varNum);

if nargin == 4
    validateattributes(dimSpec,{'cell'},{'real','size',[1 3]},'','dimSpec');

    dstart = dimSpec{1};
    dcount = dimSpec{2};
    dstride = dimSpec{3};
    validateattributes(dstart,{'double'},{'real','nonempty','finite'},'','DSTART');
    validateattributes(dcount,{'double'},{'real','nonempty','finite','numel',numel(dstart)},'','DCOUNT');
    validateattributes(dstride,{'double'},{'real','nonempty','finite','numel',numel(dstart)},'','DSTRIDE');

    if isempty(info.dimVariance)
        error(message('MATLAB:imagesci:cdflib:unwantedDimSpec', info.name));
    end


else
    if ( ~isempty(info.dims) )
        error(message('MATLAB:imagesci:cdflib:missingDimensionSpecification', info.name, numel( info.dims )));
    end
    dstart = [];
    dcount = [];
    dstride = [];
end

data = cdflibmex('hyperGetVarData',cdfId,varNum, ...
    recstart, reccount, recstride, ...
    dstart, dcount, dstride );

