function cvx_begin_set

% CVX_BEGIN_SET    Starts a new cvx set specification.
%
% The command
%    CVX_BEGIN_SET
% can be used to mark the beginning of a set definition---a cvx feasibility
% problem intended to describe a set for use in other models. See the files
% in the cvx subdirectory sets/ for examples. It has actually been
% deprecated in favor of
%    CVX_BEGIN SET
% (two separate words). However, it will continue to be available for back-
% compatability reasons, so you are free to use either.

% Copyright 2005 Michael C. Grant and Stephen P. Boyd.
% See the file COPYING.txt for full copyright information.
% The command 'cvx_where' will show where this file is located.

cvx_problem = evalin( 'caller', 'cvx_problem', '[]' );
cvx_setpath( 1 );
cvx_create_problem( 'set' );
assignin( 'caller', 'cvx_problem', cvx_problem );
