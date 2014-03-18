function y = norms( x, p, dim )

%NORMS   Internal cvx version.

%
% Size check
%

error( nargchk( 1, 3, nargin ) ); %#ok
try
    if nargin < 3, dim = []; end
    [ x, sx, sy, zx, zy, nx, nv, perm ] = cvx_reduce_size( x, dim ); %#ok
catch exc
    error( exc.message );
end
    
%
% Check second argument
%

if nargin < 2 || isempty( p ),
    p = 2;
elseif ~isnumeric( p ) || numel( p ) ~= 1 || ~isreal( p ),
    error( 'Second argument must be a real number.' );
elseif p < 1 || isnan( p ),
    error( 'Second argument must be between 1 and +Inf, inclusive.' );
end

%
% Quick exit for empty matrices
%

if isempty( x ),
    y = zeros( zy );
    return
end

%
% Type check
%

persistent remap1 remap2 remap3
if isempty( remap3 ),
    remap1 = cvx_remap( 'constant', 'log-convex' );
    remap2 = cvx_remap( 'affine' );
    remap3 = cvx_remap( 'nn-convex', 'np-concave', 'affine' );
end
xc = reshape( cvx_classify( x ), sx );
xv = xc( : );
if ~all( remap3( xv ) ),
    error( 'Disciplined convex programming error:\n   Invalid computation: norms( {%s}, ... )', cvx_class( x, true, true ) );
end

%
% Compute norms
%

if nx == 1,
	p = 0;
end
switch p,
	case 0,
		y = abs( x );
    case 1,
        y = sum( abs(x) );
    case Inf,  
        y = max( abs(x) );
    otherwise,
        tt = all( remap1( xc ) );
        if all( tt( : ) ),
            y = sum( abs(x) .^ p ) .^ (1/p);
        elseif any( tt( : ) ),
            y  = cvx( [ 1, nv ], [] );
            xt = cvx_subsref( x, ':', tt );
            y  = cvx_subsasgn( y, tt, norms( xt, p ) );
            tt = ~tt;
            xt = cvx_subsref( x, ':', tt );
            y  = cvx_subsasgn( y, tt, norms( xt, p ) );
        elseif p == 2,
        	y = [];
            if ~all( remap2( xv ) ),
                x = cvx_accept_convex( x );
                x = cvx_accept_concave( x );
            end
            cvx_begin
                epigraph variable y( 1, nv )
                { x, y } == lorentz( [ nx, nv ], 1, ~isreal( x ) ); %#ok
                cvx_setnneg(y);
            cvx_end
		else
			z = []; y = [];
            cvx_begin
                variable z( nx, nv )
                epigraph variable y( 1, nv )
                if isreal(x), cmode = 'abs'; else cmode = 'cabs'; end
                { cat( 3, z, y( ones(nx,1), : ) ), cvx_accept_convex(x) } ...
                    == geo_mean_cone( sw, 3, [1/p,1-1/p], cmode ); %#ok
                sum( z ) == y; %#ok
                cvx_setnneg(y);
            cvx_end
        end
end

%
% Reverse the reshaping and permutation steps
%

y = reshape( y, sy );
if ~isempty( perm ),
    y = ipermute( y, perm );
end

% Copyright 2005-2014 CVX Research, Inc.
% See the file LICENSE.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
