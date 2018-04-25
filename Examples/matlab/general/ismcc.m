%ISMCC tests if the code is running during compilation process (using MCC).
%    X = ISMCC returns true when the function is being executed by the MCC  
%    dependency checker and false otherwise.
%    
%    When this function is executed by the compilation process started by 
%    MCC, it will return true. This function will return false when 
%    executed within MATLAB as well as in deployed mode. To test for 
%    deployed mode execution, use ISDEPLOYED.
%
%    This function should be used to guard code in startup files like
%    MATLABRC, or HGRC or startup.m (if it exists) from being executed
%    by MATLAB Compiler or any of the Builder products when MCC is called.
%
%    A typical use case is where a user has ADDPATH calls in their 
%    startup.m. These can be guarded from being executed using ISMCC for
%    the compilation process and ISDEPLOYED for the deployed application
%    or component as follows:
%
%        % startup.m
%        % Add path only if we are neither mcc nor deployed.
%        if ~(ismcc || isdeployed)
%          addpath(fullfile(matlabroot,'work'));
%        end
%
%    
%    See also MCC, ISDEPLOYED, MATLABRC, HGRC
 
%    Copyright 1984-2008 The MathWorks, Inc.
%    Built-in function. 
