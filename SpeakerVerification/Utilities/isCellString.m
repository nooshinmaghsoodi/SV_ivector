function tf = isCellString(x)
%ISCELLSTRING  True for a cell array of strings.
%   ISSTRING(C) returns true if C is a cell array containing only row
%   character arrays and false otherwise.
%
%   See also ISSTRING.

%   Copyright 2012 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2012/10/15 20:10:06 $

tf = iscell(x) && ( isrow(x) || isequal(x, {}) ) && ...
     all(cellfun(@isString, x));

end
