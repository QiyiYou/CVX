function v = cvx_classify( x )

% Classifications:
% 1  - negative constant
% 2  - zero
% 3  - positive constant
% 4  - complex constant
% 5  - negative concave
% 6  - concave
% 7  - positive concave
% 8  - negative affine
% 9  - real affine
% 10 - positive affine
% 11 - negative convex
% 12 - convex
% 13 - positive convex
% 14 - complex affine
% 15 - log concave
% 16 - log affine
% 17 - log convex monomial
% 18 - log convex posynomial
% 19 - invalid

global cvx___
v = cvx_classify_mex( x.basis_, cvx___.classes );
v = reshape( v, size( x ) );

% Copyright 2005-2014 CVX Research, Inc.
% See the file LICENSE.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
