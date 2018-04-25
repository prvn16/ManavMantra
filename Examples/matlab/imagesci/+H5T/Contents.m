% Contents for H5T:  Datatype interface
%
%   To use these functions, you must be familiar with the information about
%   the Datatype Interface contained in the User's Guide and Reference
%   Manual for HDF5 version 1.8.12. This documentation may be obtained from
%   The HDF Group at <http://www.hdfgroup.org>.
%
%  General Datatype Operation
%   close             - Closes a datatype object
%   commit            - Commits a transient datatype
%   committed         - Queries if a datatype is transient or not
%   copy              - Copies an existing datatype
%   create            - Creates a new datatype
%   detect_class      - Detects a given datatype class in a datatype
%   equal             - Determines equality for two datatypes
%   get_class         - Returns the datatype class identifier
%   get_create_plist  - Returns a copy of the creation property list
%   get_native_type   - Returns the native datatype of a given datatype
%   get_size          - Returns the size of a datatype
%   get_super         - Returns a derived datatype's base datatype
%   lock              - Locks a datatype
%   open              - Opens a named datatype
%
%  Array Datatype
%   array_create      - Creates an array datatype object
%   get_array_dims    - Retrieves sizes of array dimensions
%   get_array_ndims   - Returns the rank of an array datatype
%
%  Atomic Datatype Properties
%   get_cset          - Returns the character set type
%   get_ebias         - Retrieves the exponent bias
%   get_fields        - Queries floating point datatypes
%   get_inpad         - Gets the floating points internal padding type
%   get_norm          - Queries floating point mantissa normalization
%   get_offset        - Gets bit offset of the first significant bit
%   get_order         - Returns the byte order of an atomic datatype
%   get_pad           - Queries the least significant bit padding type
%   get_precision     - Returns the precision of an atomic datatype
%   get_sign          - Retrieves the sign type for an integer type
%   get_strpad        - Queries a string datatype's storage mechanism
%   set_cset          - Sets character set to be used
%   set_ebias         - Sets the exponent bias of a floating-point type
%   set_fields        - Sets floating point bit field locations, sizes
%   set_inpad         - Fills unused internal floating point bits
%   set_norm          - Sets floating point mantissa normalization
%   set_offset        - Sets the first significant bit's bit offset
%   set_order         - Sets the byte ordering of an atomic datatype
%   set_pad           - Sets least, most-significant bit padding types
%   set_precision     - Sets the precision of an atomic datatype
%   set_sign          - Sets the sign property for an integer type
%   set_size          - Sets the total size for an atomic datatype
%   set_strpad        - Sets the character string storage mechanism
%
%  Compound Datatype
%   get_member_class  - Gets the datatype class of a compound field
%   get_member_index  - Gets index of a compound or enumeration field
%   get_member_name   - Gets name of a compound or enumeration field
%   get_member_offset - Gets the offset of a compound field datatype
%   get_member_type   - Returns the datatype of a specified member
%   get_nmembers      - Retrieves the number of members in a datatype
%   insert            - Adds a new member to a compound datatype
%   pack              - Recursively removes compound datatype padding
%
%  Enumeration Datatype
%   enum_create       - Creates a new enumeration datatype
%   enum_insert       - Inserts a new enumeration datatype member
%   enum_nameof       - Gets the name for an enumeration member
%   enum_valueof      - Gets the value for an enumeration member
%   get_member_value  - Gets the value of an enumeration member
%
%  Opaque Datatype Properties
%   get_tag           - Gets the tag associated with an opaque datatype
%   set_tag           - Tags an opaque datatype
%
%  Variable-length Datatype
%   is_variable_str   - Checks if a string datatype has variable-length
%   vlen_create       - Creates a new variable-length datatype
%

%   Copyright 2009-2014 The MathWorks, Inc.

