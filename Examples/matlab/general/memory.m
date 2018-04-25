%MEMORY Memory information.
%   See 'doc memory' for more information on how to make the
%   best use of memory when running MATLAB.
%
%   MEMORY when called without an output argument displays
%   information about how much memory is available and how
%   much is currently being used by MATLAB. All values are double
%   precision and in units of bytes.
%
%   USERVIEW = MEMORY returns information about how much memory is
%   available and how much is currently being used by MATLAB. USERVIEW
%   is a structure that contains the following fields:
%      MaxPossibleArrayBytes -- The largest contiguous free memory block.
%         It is an upper bound on the largest single array that MATLAB can
%         currently create. This field is the smaller of these two values:
%            a) The largest contiguous memory block found in the
%               MATLAB virtual address space, or
%            b) The total available system memory.
%         To find the number of elements, divide MaxPossibleArrayBytes
%         by the size of each element in bytes. For example, divide by
%         eight for a double matrix. The actual number of elements that
%         that can be created is always less than this number.
%      MemAvailableAllArrays -- The total amount of memory available
%         for data. This field is the smaller of these two values:
%            a) The total available MATLAB virtual address space, or
%            b) The total available system memory.
%         The amount of memory available is guaranteed to be at least
%         as large as this field.
%      MemUsedMATLAB -- The total amount of system memory reserved for the
%         MATLAB process. This is the sum of the physical memory and
%         potential swap file usage.
%
%   [USERVIEW, SYSTEMVIEW] = MEMORY returns additional, and more detailed
%   information about the current state of memory usage.  SYSTEMVIEW is a 
%   structure containing the following:
%      VirtualAddressSpace -- A 2-field structure that contains the
%         amount of available memory and the total amount of virtual
%         memory for the MATLAB process.
%      SystemMemory -- A 1-field structure that contains the amount of
%         available system memory. This number includes the amount of
%         available physical memory and the amount of available swap file 
%         space on the computer running MATLAB.
%      PhysicalMemory -- A 2-field structure that contains the amount of
%         available physical memory and the total amount of physical memory
%         on the computer running MATLAB.  It can be useful as a measure
%         of how much data can be accessed quickly.
%
%   The MEMORY function is currently available on PCWIN and PCWIN64 only.
%   Results will vary depending on the computer running MATLAB, the load
%   on the computer, and what MATLAB is doing at the time.
%
%   Example 1: Run the MEMORY command on a 32-bit Windows system:
%
%       >> memory
%       Maximum possible array:             677 MB (7.101e+008 bytes) *
%       Memory available for all arrays:   1602 MB (1.680e+009 bytes) **
%       Memory used by MATLAB:              327 MB (3.425e+008 bytes)
%       Physical Memory (RAM):             3327 MB (3.489e+009 bytes)
%
%       *  Limited by contiguous virtual address space available.
%       ** Limited by virtual address space available.
%       >>
%        
%   Example 2: Run the MEMORY command on a 64-bit Windows system:
%
%       >> memory
%       Maximum possible array:               4577 MB (4.800e+009 bytes) *
%       Memory available for all arrays:      4577 MB (4.800e+009 bytes) *
%       Memory used by MATLAB:                 330 MB (3.458e+008 bytes)
%       Physical Memory (RAM):                3503 MB (3.674e+009 bytes)
%
%       *  Limited by System Memory (physical + swap file) available.
%       >> 
%
%   Example 3: Run the MEMORY command with two outputs on a 32-bit Windows
%              system:
%
%       >> [uV sV] = memory
%
%       uV = 
%
%           MaxPossibleArrayBytes: 710127616
%           MemAvailableAllArrays: 1.6797e+009
%                   MemUsedMATLAB: 345354240
%
%
%       sV = 
%
%           VirtualAddressSpace: [1x1 struct]
%                  SystemMemory: [1x1 struct]
%                PhysicalMemory: [1x1 struct]
%
%       >> sV.VirtualAddressSpace
%
%       ans = 
%
%           Available: 1.6797e+009
%               Total: 2.1474e+009
%
%       >> sV.SystemMemory
%
%       ans = 
%
%           Available: 4.4288e+009
%
%       >> sV.PhysicalMemory
%
%       ans = 
%
%           Available: 2.5376e+009
%               Total: 3.4889e+009

%   Copyright 1984-2009 The MathWorks, Inc.
%     $Date: 2007/10/15 13:44:13
%   Built-in function.
