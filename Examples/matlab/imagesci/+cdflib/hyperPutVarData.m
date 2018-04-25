function hyperPutVarData(cdfId,varNum,recSpec,dimSpec,data)
%cdflib.hyperPutVarData Write variable hyperslab
%   cdflib.hyperPutVarData(cdfId,varNum,recSpec,dimSpec,data) writes a 
%   hyperslab of data to the variable specified by varNum in the CDF
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
%   All record numbers and dimension indices are zero-based numbers.
%
%   This function corresponds to the CDF library C API routine 
%   CDFhyperzPutVarData.  
%
%   Example:  Rewrite the first element in each of the first six records of
%   the 'Temperature' variable.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.cdf');
%       copyfile(srcFile,'myfile.cdf');
%       fileattrib('myfile.cdf','+w');
%       cdfid = cdflib.open('myfile.cdf');
%       varnum = cdflib.getVarNum(cdfid,'Temperature');
%       recspec = [0 6 1];
%       dimspec = {[0 0],[1 1],[1 1]};
%       newdata = int16([5:-1:0]);
%       cdflib.hyperPutVarData(cdfid,varnum,recspec,dimspec,newdata);
%       cdflib.close(cdfid);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also cdflib, cdflib.hyperGetVarData.

%   Copyright 2009-2013 The MathWorks, Inc.

validateattributes(recSpec,{'double'},{'real','finite','size',[1 3]},'hyperPutVarData','recSpec');
validateattributes(dimSpec,{'cell'},{'real','size',[1 3]},'hyperPutVarData','dimSpec');

recstart = recSpec(1);
reccount = recSpec(2);
recstride = recSpec(3);

dstart = dimSpec{1};
dcount = dimSpec{2};
dstride = dimSpec{3};

validateattributes(dstart,{'double'},{'real','nonempty','finite'},'hyperPutVarData','DSTART');
validateattributes(dcount,{'double'},{'real','nonempty','finite'},'hyperPutVarData','DCOUNT');
validateattributes(dstride,{'double'},{'real','nonempty','finite'},'hyperPutVarData','DSTRIDE');
if (numel(dstart) ~= numel(dcount)) || (numel(dstart) ~= numel(dstride))
	error(message('MATLAB:imagesci:cdflib:badHyperslabDimSpec'));
end

cdflibmex('hyperPutVarData',cdfId,varNum, ...
	recstart, reccount, recstride, ...
	dstart, dcount, dstride, ...
	data);

