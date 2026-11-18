%% -*- prolog -*-

%% TODO: Include your name and course information below.
%! name(Name) is det.
%%
%% Name of the submitter.
name("Rainbow Martin").

%! semester(Semester) is det.
%%
%% Semester submitted in.
semester("2026 Fall").

%! class(Class) is det.
%%
%% Class student is enrolled in.
class("CSC-461-DT1").

%! typecheck(+Code, +InEnv, -OutEnv) is semidet.
%% TODO: Implement the typechecker below; a basecase is provided for you.

%% ----------------------------------------------------------------------------------
%% Typechecker code reader

%% Empty/base case
typecheck([], X, X).

%% Continue reading code
typecheck([H|T], I, O) :-
    %% Read head of list, using I as next InEnv, M as updated list of env
    typecheck(H, I, M),

    %% Recursively read remainder of list, using M as updated list for I and OutEnv
    %% as updated list for OutEnv
    typecheck(T, M, O).

%% Inferred type declaration
typecheck((vardecl, Var, Expr), I, [(Var, Type)|I]) :-
    \+ member((Var, _), I), %% The variable doesn't already exist in the environment
    litType(Expr, I, Type), %% Determine the variable type
    Type \= void. %% Type returned from litType is not void
    %% Returns true if all conditions met, adds Var to the environment.

%% Explicit type declaration
typecheck((vardecltype, Var, Expr, Type), I, [(Var, Type)|I]) :-
    \+ member((Var, _, _), I), %% The variable doesn't already exist in the environment
    litType(Expr, I, EType), %% Get the expression Type
    compatible(EType, Type), %% Check for compatibility
    Type \= void. %% Type is not declared as a void
    %% Returns true if all conditions are met, adds Var to the environment.

%%-----------------------------------------------------------------------------------
%% Lookup
lookup(Variable, Environment, Type) :-
    atom(Variable), % The variable name can be used as an identifier
    member((Variable, Type), Environment). % The variable/type exists in the environment
    %% Returns true if variable exists in the environment
%%-----------------------------------------------------------------------------------
%% Types

%% Integers
litType(X, _, int) :-
    integer(X),
    !.

%% Reals
litType(X, _, real) :-
    float(X),
    !.

%% Single-character string
litType(X, _, char) :-
    atom(X), %% the literal name can be used as an identifier
    atom_length(X, 1). %% It is made of one character

%% Boolean
litType(true, _, bool) :-
    !.
litType(false, _, bool) :-
    !.

%%

%%-------------------------------------------------------------------------------------
%% Type rules
%% Base rules
compatible_rule(int, real). %% integers are compatible with reals
compatible_rule(float, real). %% floats are compatible with reals

compatible(T, T). %% Each type is compatible with itself

compatible(T1, T2) :-
    compatible_rule(T1, T3), %% If T1 is compatible with T3
    T1 \= T3,
    compatible(T3, T2). %% T3 is also compatible with T2
    %% Returns true because T1 is compatible with T2
%%-------------------------------------------------------------------------------------




