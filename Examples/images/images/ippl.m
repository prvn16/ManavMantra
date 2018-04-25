function [a, b] = ippl
%IPPL Check for presence of Intel Performance Primitives Library (IPPL).
%   The IPPL provides a collection of basic functions used in signal and
%   image processing. It takes advantage of the parallelism of the
%   Single-Instruction, Multiple-Data (SIMD) instructions that comprise
%   the core of the MMX technology and Streaming SIMD Extensions. These
%   instructions are available only on the Intel Architecture processors.
%   IPPL is used by some of the Image Processing Toolbox functions to
%   accelerate their execution time.
%
%   A = IPPL returns true if IPPL is available and false otherwise.
%
%   [A B] = IPPL returns an additional column cell array B. Each row
%   of B contains a string describing a specific IPPL module.
%
%   When IPPL is available, the following Image Processing Toolbox functions
%   take advantage of it: IMABSDIFF, IMADD, IMSUBTRACT, IMDIVIDE, IMMULTIPLY,
%   IMLINCOMB and IMFILTER. Functions in the Image Processing Toolbox that use
%   these routines also benefit from the use of IPPL.
%
%   Notes
%   -----
%   - IPPL is utilized only for some data types and only under specific
%     conditions. See the help sections of the functions listed above for
%     detailed information on when IPPL is activated.
%
%   - To disable IPPL, use this command:
%
%         iptsetpref('UseIPPL', false)
%
%     To enable IPPL, use:
%
%         iptsetpref('UseIPPL', true)
%
%     Note that enabling or disabling IPPL has the effect of clearing all
%     loaded MEX-files.
%
%   - IPPL function is likely to change in the near future.
%
%   See also IMABSDIFF, IMDIVIDE, IMMULTIPLY, IMFILTER, IPTSETPREF.

%   Copyright 1993-2016 The MathWorks, Inc.

narginchk(0,0);

a = false;
b = {'IPP is disabled'};

if images.internal.useIPPLibrary()
    a = true;
    if nargout==2
        b = ipplmex;
    end
end