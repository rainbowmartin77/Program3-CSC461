# Reflection about Type Checker Assignment (YOUR NAME HERE)

## Before

### How do you plan to begin this assignment?
Step 1: Write out the type rules on paper to ensure some consistency in my program's design and implementation. I have attempted to go right to coding before and usually have to go back and redesign my projects. With this being a language I've never done anything substantial with, I think a solid design is necessary.

Following, I hope to work from the bottom up, meaning the simplest and most necessary code will be written and tested first. From looking at the assignment, that includes variable type lookup, checking for a name existing in the environment, new bindings, and updates to existing bindings - in that order. These predicates make other rules possible, so I'll put a lot of focus here in the beginning.

Next, I think type compatibility could be implemented. With foundational rules written and functioning properly, these rules shouldn't be too difficult to write and test. Following this, expressions, mkarray, binary operations, control structures,  etc. This last chunk is the most complicated and difficult to predict the flow of my implementation, but I'm hoping it will somehow intuitively come to me as I approach this point in the project.

### What do you think will be the hardest part about this assignment?
I am afraid of a majority of this project. It feels very large and very daunting. The concepts individually seem simple, but writing a cohesive project implementing all of the requirements is hard to imagine. 

### How can you find solutions for the hardest part of the assignment?
I will use the approved resources and perhaps some research of typechecker examples if I get too overwhelmed. Additionally, I intend to keep in regular contact with Dr. Flint in the case of questions that I cannot find answers to.
 
## After

### What resources did you find helpful when completing this assignment?
The Prolog WikiBook seemed the most helpful for me because I really  struggled through this whole section to understand First Order Logic and  how Recursion worked. The semantics page from Wikipedia helped a lot too. Once I ran the fourth test in the assignment, I got scared because I had no idea how to debug my program. I quickly googled how to debug prolog and was immediately reminded of the trace functionality. That was the greatest help in understanding what my code was doing since I couldn't use print statements.

### How did your plan align with your actual experience writing the typechecker?
My plan was too inexperienced and rather pitiful. A lot of my first  attempts seem to go that way though. I go in with an idea, and then I realize that plans fail more often. Before I knew it, I wasn't looking at my plan at all. I was just coding until I realized I needed something to support a predicate I was working on. Toward the end, I was quite overwhelmed with the mess of my code, but cleaning up wasn't that bad. I also had to keep reminding myself that this language is a completely different paradigm than what I'm used to. I spent a lot of time reminding myself that I am just writing logic, not the 'how' a problem is solved.

### Did you find this assignment interesting? Did it help you to understand Prolog better?
I feel much more confident about my understanding of Prolog now. I don't like it any more than I did when we started, but as I kept working, I knew what I was looking at and it got easier. The assignment was definitely interesting, to say the least. I would have loved to have more time (concerning my personal circumstances), to create a cleaner program. The hardest part was understanding the recursion and what seemed, to me, like random variables introduced in predicate bodies. As I continued and read, that concept became clear, although it still feels awkward and hard to remember.