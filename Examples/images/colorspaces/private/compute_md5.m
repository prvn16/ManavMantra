function chk_sum = compute_md5(input_bytes)
%COMPUTE_MD5 calculate MD5 checksum.
%   CHK_SUM = COMPUTE_MD5(INPUT_BYTES) computes the MD5 checksum on the
%   array INPUT_BYTES and returns it as a 16-element uint8 vector. The
%   algorithm is implemented in the java class:
%
%      java.security.MessageDigest
%
%   Class Support
%   -------------
%   INPUT_BYTES and CHK_SUM are both nonsparse uint8 arrays.

%   Copyright 2008 The MathWorks, Inc.

% validate input
validateattributes(input_bytes,{'uint8'},{'nonsparse'});

import java.security.MessageDigest;

% create MD5 MessageDigest object
md = MessageDigest.getInstance('MD5');

% initialize
md.reset();

% generate int8 checksum
if ~isempty(input_bytes)
    chk_sum = md.digest(input_bytes(:));
else
    chk_sum = md.digest();
end

% convert to uint8 row vector
chk_sum = typecast(chk_sum,'uint8')';
