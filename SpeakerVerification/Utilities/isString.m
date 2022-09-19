function tf = isString(x)
%ISSTRING  True for a character string.
%   ISSTRING(S) returns true if S is a row character array and false
%   otherwise.
%
%   See also ISCELLSTRING.

%   Copyright 2012 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2012/10/15 20:10:07 $

tf = ischar(x) && ( isrow(x) || isequal(x, '') );

end
