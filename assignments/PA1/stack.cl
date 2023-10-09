(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)

class Stack{

    isNil() : Bool { true };

    head()  : String { { abort(); ""; } };

    pop()  : Stack { { abort(); self; } };

    push(i : String) : Stack {
        (new Cons).init(i, self)
    };

};

class Cons inherits Stack {

    car : String;	-- The element in this list cell

    cdr : Stack;	-- The rest of the list

    isNil() : Bool { false };

    head()  : String { car };

    pop()  : Stack { cdr };

    init(i : String, rest : Stack) : Stack
    {
        {
            car <- i;
            cdr <- rest;
            self;
        }
    };

};

class Main inherits IO {

    s : Stack;
    now : String;
    first : String;
    second : String;
    a2i : A2I <- new A2I;

    stack_print(s : Stack) : Object {
        if s.isNil() then
            out_string("\n")
        else {
            out_string(s.head());
            out_string(" ");
            stack_print(s.pop());
        }
        fi
    };

    stack_add(s : Stack) : Stack {
        {
            s <- s.pop();
            first <- s.head();
            s <- s.pop();
            second <- s.head();
            s <- s.pop();
            s <- s.push(a2i.i2c(a2i.c2i(first) + a2i.c2i(second)));
        }
    };

    stack_swap(s : Stack) : Stack {
        {
            s <- s.pop();
            first <- s.head();
            s <- s.pop();
            second <- s.head();
            s <- s.pop();
            s <- s.push(first);
            s <- s.push(second);
        }

    };

    stack_machine(s : Stack) : Object {
        {
            now <- in_string();
            while (not now = "x") loop
                {
                    if now = "e" then {
                        if s.isNil() then {
                            self;
                        } else {
                            if s.head() = "+" then {
                                s <- stack_add(s);
                            } else {
                                if s.head() = "s" then {
                                    s <- stack_swap(s);
                                } else {
                                    self;
                                } fi;
                            } fi;
                        } fi;
                    } else {
                        if now = "d" then {
                            stack_print(s);
                        } else {
                            s <- s.push(now);
                        } fi;
                    } fi;
                    now <- in_string();
                }
            pool;
        }
    };

    main() : Object
    {
        {
            s <- new Stack;
            stack_machine(s);
        }
    };

};
