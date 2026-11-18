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
%%-----------------------------------------------------------------------------------
%% Lookup
lookup(Variable, Environment, Type) :-
    atom(Variable), % The variable name can be used as an identifier
    member((Variable, Type), Environment). % The variable/type exists in the environment
    %% Returns true if variable exists in the environment
%%-----------------------------------------------------------------------------------
%% Literals
litType(X, _, int) :-
    integer(X).
litType(X, _, real) :-
    real(X).
litType(X, _, float) :-
    float(X).
-------------------------------------------------------------------------------------
%% Type rules
%% Base rules
compatible_rule(int, real).
compatible_rule(float, real).

%% Reflexive
compatible(T, T).

%% Transitive
compatible(T1, T2) :-
    compatible_rule(T1, T3), %% If T1 is compatible with T3
    compatible(T3, T2). %% T3 is also compatible with T2
    %% Returns true because T1 is compatible with T2
-------------------------------------------------------------------------------------
%% Var-decl






