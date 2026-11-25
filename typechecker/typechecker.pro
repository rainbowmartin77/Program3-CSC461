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
course("CSC-461-DT1").

%! typecheck(+Code, +InEnv, -OutEnv) is semidet.
%% TODO: Implement the typechecker below; a basecase is provided for you.

%% ----------------------------------------------------------------------------------
%% Typechecker code reader

%% Empty/base case
typecheck([], X, X).

%% Read list of commands
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

%% Control Structures
%% if
typecheck((if, Condition, Then), I, I) :-
    litType(Condition, I, bool), % Check that the condition is a bool
    typecheck(Then, I, _), %% Recursive call
    !.

%% Evaluate else command if Condition fails
typecheck((if, Condition, Then, Else), I, I) :-
    litType(Condition, I, bool),
    typecheck(Then, I, _),
    typecheck(Else, I, _).

%% for loop 
typecheck((for, Var, Iter, Body), I, I) :-
    \+ member((Var, _), I), %% The Var is not in the environment
    litType(Iter, I, (array, IterType)), %% Ensure iteration type
    typecheck(Body, [(Var, IterType)|I], _). %% Typecheck the body

%% Creating functions
typecheck((function, Name, Params, Body, ReturnType), I, [(Name, function, Params, ReturnType)|I]) :-
    \+ member((Name, _), I), %% The name does not exist in the environment
    append([(Name, function, Params, ReturnType)|Params], I, FunctionEnvironment), %% Set function environment
    bodyCheck(Body, FunctionEnvironment, BodyType), %% Typecheck body commands
    compatible(BodyType, ReturnType). %% Ensure return type matches


%% Setting array
typecheck((arraySet, Var, Index, Expr), I, I) :-
    member((Var, (array, ArrayType)), I),
    litType(Index, I, int), %% Ensure index is of type int
    litType(Expr, I, EType), %% Get expression type
    compatible(EType, ArrayType). %% Verify compatibility

%% Helper predicates
%% Check variable declarations
checkVarDecl(Var, Expr, I, [(Var, T)|I]) :-
    \+ member((Var, _), I), %% Check that the variable name doesn't already exist
    litType(Expr, I, T), %% Get the expression type
    T \= void. %% Ensure the type is not void

checkVarDeclType(Var, Expr, T, I, [(Var, T)|I]) :-
    \+ member((Var, _), I), %% The variable doesn't already exist in the environment
    litType(Expr, I, ET), %% Get the expression Type
    compatible(ET, T), %% Ensure compatibility
    T \= void, %% Type is not declared as a void
    !.
    %% Returns true if all conditions are met, adds Var to the environment.

%% Setting an existing variable to a matching type
setVar(Var, Expr, I, I) :-
    member((Var, ExistingType), I), %% Check that variable exists in the environment
    litType(Expr, I, T), %% Get the expression type
    sameType(ExistingType, T). %% Check that the types match

%% Verify function argument types match parameter types
%% Base case - all arguments evaluated
checkArgs([], [], _).

%% Recursively go through list
checkArgs([H|T], [(_,PType)|Params], I) :-
    litType(H, I, AType), %% Get the type of the argument
    compatible(AType, PType), %% Compare argument and parameter type
    checkArgs(T, Params, I). %% Recursively call to check next argument

%% Body helpers
bodyCheck([Expr], Env, T) :-
    litType(Expr, Env, T).

bodyCheck([Stmt, Expr], Env, T) :-
    typecheck(Stmt, Env, NewEnv),
    litType(Expr, NewEnv, T),
    !.

bodyCheck([Stmt|Rest], Env, T) :-
    typecheck(Stmt, Env, NewEnv),
    bodyCheck(Rest, NewEnv, T).


%%-----------------------------------------------------------------------------------
%% Evaluate types
litType([Expr], I, T) :-
    litType(Expr, I, T).

litType([_|Rest], I, T) :-
    litType(Rest, I, T).

%% Integers
litType(X, _, int) :-
    integer(X),
    !.

%% Floats
litType(X, _, float) :-
    float(X),
    !.

%% Variables
litType(X, Env, T) :-
    atom(X),
    member((X, T), Env). %% Check that X is in the environment

%% mkarray
litType((mkarray, T, L), Env, (array, T)) :-
    litType(L, Env, int), % Check that length is an int
    T \= void. % Ensure type is not void

%% Array index
litType((arrayInd, Var, Index), Env, EType) :-
    member((Var, (array, EType)), Env), %% Ensure that the array exists
    litType(Index, Env, int). %% Ensure that the index is an int

%% Single character string
litType(X, _, char) :-
    string(X), %% X is a string
    string_length(X, 1). %% String of length 1

%% Character string
litType(X, _, (array, char)) :-
    string(X), %% the literal name can be used as an identifier
    string_length(X, N), %% Get string length
    N > 1. %% Length is mor than one

%% Boolean
litType(true, _, bool) :-
    !.
litType(false, _, bool) :-
    !.

%% Comparison operations
litType((lt, X, Y), Env, bool) :-
    litType(X, Env, TX), %% GEt type of X
    litType(Y, Env, TY), %% Get type of Y
    compatible(TX, real), %% Ensure X type is compatible with real
    compatible(TY, real), %% Ensure Y type is compatible with real
    !.

litType((lte, X, Y), Env, bool) :-
    litType(X, Env, TX), %% GEt type of X
    litType(Y, Env, TY), %% Get type of Y
    compatible(TX, real), %% Ensure X type is compatible with real
    compatible(TY, real), %% Ensure Y type is compatible with real   
    !.

litType((gt, X, Y), Env, bool) :-
    litType(X, Env, TX), %% GEt type of X
    litType(Y, Env, TY), %% Get type of Y
    compatible(TX, real), %% Ensure X type is compatible with real
    compatible(TY, real), %% Ensure Y type is compatible with real
    !.

litType((gte, X, Y), Env, bool) :-
    litType(X, Env, TX), %% GEt type of X
    litType(Y, Env, TY), %% Get type of Y
    compatible(TX, real), %% Ensure X type is compatible with real
    compatible(TY, real), %% Ensure Y type is compatible with real   
    !.

litType((equiv, X, Y), Env, bool) :-
    litType(X, Env, TX), %% Get type of X
    litType(Y, Env, TY), %% Get type of Y
    compatible(TX, TY), %% Ensure that type of X and Y are compatible
    !.

%% Logic operations
litType((and, X, Y), Env, bool) :-
    litType(X, Env, bool), %% Check that X is a bool
    litType(Y, Env, bool). %% Check that Y is a bool

litType((or, X, Y), Env, bool) :-
    litType(X, Env, bool), %% Check that X is a bool
    litType(Y, Env, bool). %% Check that Y is a bool

litType((xor, X, Y), Env, bool) :-
    litType(X, Env, bool), %% Check that X is a bool
    litType(Y, Env, bool). %% Check that Y is a bool

%% Arithmetic operators
litType((add, X, Y), Env, T) :-
    litType(X, Env, TX), %% Get type of X
    litType(Y, Env, TY), %% Get type of Y
    lowestCompatible(TX, TY, T). %% Check compatibility and get type

litType((sub, X, Y), Env, T) :-
    litType(X, Env, TX), %% Get type of X
    litType(Y, Env, TY), %% Get type of Y
    lowestCompatible(TX, TY, T). %% Check compatibility and get type

litType((mul, X, Y), Env, T) :-
    litType(X, Env, TX), %% Get type of X
    litType(Y, Env, TY), %% Get type of Y
    lowestCompatible(TX, TY, T). %% Check compatibility and get type
    
litType((div, X, Y), Env, real) :-
    litType(X, Env, int), %% Ensure X is of type int
    litType(Y, Env, int), %% Ensure Y is of type int
    !.

litType((div, X, Y), Env, T) :-
    litType(X, Env, TX), %% Get type of X
    litType(Y, Env, TY), %% Get type of Y
    lowestCompatible(TX, TY, T). %% Check compatibility and get type

%% Arrays
litType([H|T], E, (array, Type)) :-
    litType(H, E, Type), %% Determine the type of the first element
    aType(T, E, Type). %% Check for remaining elements to be of the same type
    %% Returns true and type of array

%% Function call
litType((call, Name, Args), Env, ReturnType) :-
    member((Name, function, Params, ReturnType), Env), %% Check that function exists
    checkArgs(Args, Params, Env). %% Use helper predicate to compare argument and parameter types

%% Arithmetic helper predicates
lowestCompatible(int, real, real). %% Args are int and real, return real
lowestCompatible(real, int, real). %% Args are real and int, return real
lowestCompatible(real, real, real). %% Args are real, return real.
lowestCompatible(int, int, int).


%% Arrays
%% Verify all elements in an array are the same type
%% Base - array is empty
aType([], _, _).

%% Recursive
aType([H|T], E, Type) :-
    litType(H, E, Type),
    aType(T, E, Type).

%%-------------------------------------------------------------------------------------
%% Compatibility rules
%% Base rules
compatible_rule(int, real). %% integers are compatible with reals
compatible_rule(float, real). %% floats are compatible with reals
compatible_rule(char, (array, char)). %% characters are compatible with strings
compatible_rule((array, T), (array, T)). %% arrays of the same type are compatible

%% Check for different type compatibility
compatible(T1, T2) :-
    compatible_rule(T1, T2),
    !.

%% Reflexive
compatible(T, T) :- %% Each type is compatible with itself
    !.

%% Check array compatibility
compatible((array, T1), (array, T2)) :-
    compatible(T1, T2),
    !.

%% Transitive compatibility
compatible(T1, T2) :-
    compatible_rule(T1, T3),
    compatible(T3, T2).

sameType(T, T). %% Matching types
%%-------------------------------------------------------------------------------------
