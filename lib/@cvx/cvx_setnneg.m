function cvx_setnneg( x )

global cvx___
x  = x.basis_;
xc = x(1,:);
x  = x(2:end,:);
tt = ( xc <= 0 ) & ( sum( x ~= 0 ) == 1 );
[ tx, dummy ] = find( x(:,tt) ); %#ok
tx = tx + 1;
persistent mpos;
if isempty( mpos ),
    mpos = int8([2,2,3,19,2,7,7,2,10,10,2,13,13,19,15,16,17,18,19]);
end
cvx___.classes(tx) = mpos(cvx___.classes(tx));

% Copyright 2005-2014 CVX Research, Inc.
% See the file LICENSE.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
