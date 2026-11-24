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
typecheck((vardecl, Var, Expr), I, O) :-
    checkVarDecl(Var, Expr, I, O).

%% Explicit type declaration
typecheck((vardecltype, Var, Expr, Type), I, O) :-
    checkVarDeclType(Var, Expr, Type, I, O).

%% Setting variables
typecheck((set, Var, Expr), I, O) :-
    setVar(Var, Expr, I, O).

typecheck((mkarray, T, Length), I, O) :-
    createArray(T, Length, I, O).

%% Setting array
% typecheck((arraySet, Var, Index, Expr), I, O) :-
%     setArray(Var, Index, Expr, I, O).

%% Helper predicates
%% Execute vardecl?
checkVarDecl(Var, Expr, I, [(Var, T)|I]) :-
    \+ member((Var, _), I), %% Check that the variable name doesn't already exist
    litType(Expr, I, T), %% Get the expression type
    T \= void. %% Ensure the type is not void

checkVarDeclType(Var, Expr, T, I, [(Var, T)|I]) :-
    \+ member((Var, _), I), %% The variable doesn't already exist in the environment
    litType(Expr, I, T), %% Get the expression Type
    T \= void. %% Type is not declared as a void
    %% Returns true if all conditions are met, adds Var to the environment.

setVar(Var, Expr, I, I) :-
    member((Var, ExistingType), I), %% Check that variable exists in the environment
    litType(Expr, I, T), %% Get the expression type
    sameType(ExistingType, T). %% Check that the types match

createArray(T, Length, I, [(array, T)|I]) :-
    litType(Length, _, LengthType), %% Get type of the length argument
    sameType(LengthType, int), %% Ensure length is of type int
    T \= void. %% Type declared is not void

% setArray(Var, Index, Expr, I, O) :-
%     memeber((Var, ExistingType), I), %% Check that the variable exists
%     litType(Expr, I, T), %% Get the expression type
% Need to create arrays first


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

%% Strings - needed?
litType(X, _, (array, char)) :-
    array(X).

%% Arrays
litType([H|T], E, (array, Type)) :-
    litType(H, E, Type), %% Determine the type of the first element
    aType(T, E, Type). %% Check for remaining elements to be of the same type
    %% Returns true and type of array

%% Arrays
%% Verify all elements in an array are the same type
%% Base - array is empty
arrayType([], _, _).

%% Recursive
aType([H|T], E, Type) :-
    litType(H, E, Type),
    aType(T, E, Type).

%% Divide


%%-------------------------------------------------------------------------------------
%% Compatibility rules
%% Base rules
compatible_rule(int, real). %% integers are compatible with reals
compatible_rule(float, real). %% floats are compatible with reals
compatible_rule(char, (array, char)). %% characters are compatible with strings
compatible_rule((array, T), (array, T)). %% arrays of the same type are compatible

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

sameType(T, T). %% Matching types
%%-------------------------------------------------------------------------------------