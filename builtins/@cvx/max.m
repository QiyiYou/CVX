function z = max( varargin )

%   Disciplined convex/geometric programming information:
%       MAX is convex, log-log-convex, and nondecreasing in its first 
%       two arguments. Thus when used in disciplined convex programs, 
%       both arguments must be convex (or affine). In disciplined 
%       geometric programs, both arguments must be log-convex/affine.

if nargin == 2,
    
    %
    % max( X, Y )
    %

    persistent bparam %#ok
    if isempty( bparam ),
        bparam.map = cvx_remap( ...
            { { 'real' } }, ...
            { { 'nonnegative', 'p_nonconst' }, { 'nonpositive', 'n_nonconst' } }, ...
            { { 'nonpositive', 'n_nonconst' }, { 'nonnegative', 'p_nonconst' } }, ...
            { { 'l_convex', 'positive' } }, ...
            { { 'convex' } } );
        bparam.funcs = { @max_b1, @max_b2, @max_b3, @max_b4, @max_b5 };
        bparam.name = 'max';
        bparam.constant = 1;
    end
    
    try
        z = binary_op( bparam, varargin{:} );
    catch exc
        if strncmp( exc.identifier, 'CVX:', 4 ), throw( exc ); 
        else rethrow( exc ); end
    end

elseif nargin > 1 && ~isempty( y ),

    error( 'MAX with two matrices to compare and a working dimension is not supported.' );
        
else
    
    %
    % max( X, [], dim )
    %

    persistent params %#ok
    if isempty( params ),
        params.map      = cvx_remap( { 'real' ; 'l_convex' ; 'convex' } );
        params.funcs    = { @max_r1, @max_r2, @max_r3 };
        params.constant = 1;
        params.zero     = [];
        params.reduce   = true;
        params.reverse  = false;
        params.dimarg   = 3;
        params.name     = 'max';
    end

    try
        z = cvx_reduce_op( params, varargin{:} );
    catch exc
        if strncmp( exc.identifier, 'CVX:', 4 ), throw( exc ); 
        else rethrow( exc ); end
    end
   
end    

function z = max_b1( x, y )
% constant
z = builtin( 'max', x, y );

function z = max_b2( x, y )
% max( positive, negative ) (pass through x)
z = x;

function z = max_b3( x, y )
% max( negative, positive ) (pass through y)
z = y;

function z = max_b4( x, y )
% geometric
z = [];
sz = [ max(numel(x),numel(y)), 1 ]; %#ok
cvx_begin gp
    epigraph variable z( sz );
    x <= z; %#ok
    y <= z; %#ok
cvx_end

function z = max_b5( x, y )
persistent nneg npos
if isempty( nneg ),
    nneg = cvx_remap( 'nonnegative', 'p_nonconst' );
    npos = cvx_remap( 'nonpositive', 'n_nonconst' );
end
% linear
z = [];
sz = [ max(numel(x),numel(y)), 1 ]; %#ok
vx = cvx_classify( x );
vy = cvx_classify( y );
nn = nneg(vx)|nneg(vy);
np = npos(vx)&npos(vy);
cvx_begin
    epigraph variable z( sz );
    x <= z; %#ok
    y <= z; %#ok
    cvx_setnneg( cvx_subsref( z, nn ) );
    cvx_setnpos( cvx_subsref( z, np ) );
cvx_end

function x = max_r1( x, y ) %#ok
x = builtin( 'max', x, [], 1 );

function x = max_r2( x, y ) %#ok
nx = x.size_(1);
if nx > 1,
    nv = x.size_(2); %#ok
    cvx_begin gp
        epigraph variable z( 1, nv )
        x <= repmat( z, nx, 1 ); %#ok
    cvx_end
    x = cvx_optval;
end

function x = max_r3( x, y ) %#ok
persistent nneg npos
if isempty( nneg ),
    nneg = cvx_remap( 'nonnegative', 'p_nonconst' );
    npos = cvx_remap( 'nonpositive', 'n_nonconst' );
end
nx = x.size_(1);
if nx > 1,
    nv = x.size_(2); %#ok
    vx = cvx_classify(x);
    nn = any(nneg(vx),1);
    np = all(npos(vx),1);
    cvx_begin
        epigraph variable z( 1, nv )
        x <= repmat( z, nx, 1 ); %#ok
        cvx_setnneg( cvx_subsref( z, nn ) );
        cvx_setnpos( cvx_subsref( z, np ) );
    cvx_end
    x = cvx_optval;
end

% Copyright 2005-2014 CVX Research, Inc.
% See the file LICENSE.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.
