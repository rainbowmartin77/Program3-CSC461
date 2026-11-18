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
typecheck((vardecl, Var, Expr), I, [(Var, T)|I]) :-
    \+ member((Var, _), I), %% The variable doesn't already exist in the environment
    litType(Expr, I, T), %% Determine the variable type
    T \= void. %% Type returned from litType is not void
    %% Returns true if all conditions met, adds Var to the environment.

%% Explicit type declaration
typecheck((vardecltype, Var, Expr, Type), I, [(Var, Type)|I]) :-
    \+ member((Var, _), I), %% The variable doesn't already exist in the environment
    aType(Expr, I, Type), %% Get the expression Type
    Type \= void. %% Type is not declared as a void
    %% Returns true if all conditions are met, adds Var to the environment.
%%-----------------------------------------------------------------------------------
%% Types

%% Verify all elements in an array are the same type
%% Base - array is empty
aType([], _, _).

%% Recursive
aType([H|T], E, Type) :-
    litType(H, E, Type),
    aType(T, E, Type).

%% Integers
litType(X, _, int) :-
    integer(X),
    !.

%% Reals
litType(X, _, real) :-
    float(X),
    !.

%% Floats
litType(X, _, float) :-
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

%% Strings
litType(X, _, (array, char)) :-
    string(X).

%% Arrays
litType([H|T], E, (array, Type)) :-
    litType(H, E, Type), %% Determine the type of the first element
    aType(T, E, Type). %% Check for remaining elements to be of the same type
    %% Returns true and type of array

%%-------------------------------------------------------------------------------------
%% Compatibility rules
%% Base rules
compatible_rule(int, real). %% integers are compatible with reals
compatible_rule(float, real). %% floats are compatible with reals
compatible_rule(char, (array, char)). %% characters are compatible with strings

%% Reflexive
compatible(T, T). %% Each type is compatible with itself

%% Check for different type compatibility
compatible(T1, T2) :-
    compatible_rule(T1, T2).

%% Check array compatibility
compatible((array, T1), (array, T2)) :-
compatible(T1, T2).

%% Transitive compatibility
compatible(T1, T2) :-
    compatible_rule(T1, T3),
    compatible(T3, T2).
%%-------------------------------------------------------------------------------------




