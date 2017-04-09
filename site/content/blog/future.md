+++
date = "2016-05-21T09:38:47-04:00"
draft = false
title = "The Future of Development (If I get my way)"
+++

**These ideas are very incomplete, but I'll never publish them if I wait for that**


I've been thinking about this for a couple years now, and it's about time I write some of my ideas down. What I'm talking about is the proliferation of so called 'codeless' tools. These are tools that allow you to build real, working applications without writing a single line of code. I believe in these tools. For context, I have been writing code professionally for about 5 years now, and non professionally for 11 years. I love programming and I don't want to see it go. However, we want more software, and we need more people to build it. There are several ways to solve this problem:

1. Teach more people to code
2. Make coding easier
3. Something more creative

I haven't come up with an answer for 3 yet, and lots of people are working on number 1. Let's talk about number 2.

We've come a long long way from where we began. New languages and tools have allowed huge new waves of people to become programmers by lowering the barrier to entry. I believe there is much more work to be done before we've exhausted our options.


I think it's time we consider graphical programming as a serious solution to most application development. When I tell people this, especially other developers, the typical reaction is something like "We tried that and it sucked, it's a waste of time". They cite things like visual basic and smalltalk as examples of failed attempts in the past. I agree that tools of the past and many existing tools are lacking in one way or another. However, I don't believe that there is any fundamental reason why application development can't be accessible to everyone.


In software, there are two forms of complexity: incidental complexity, and domain complexity. Domain complexity is the complexity that comes from the problem you're trying to solve. Incidental complexity just appears out of nowhere based on how you choose to solve the problem. For example, if I want to build a twitter clone, I have to worry about users, tweets, and a few other things at a minimum. There is no fundamental reason why I should have to understand the subtle rules around how css rules are applied or how to provision a vm on aws. Yet somehow, as application developers we deal with these problems every day. Sure, in practice it's really not that big of a deal because we've learned to avoid problems ahead of time with _design patterns_. My question to other developers is this: __Why did I have to spend the first few years of my programming experience just learning what to avoid?__


This feeling is only made stronger by the fact that most routine work I do involves redoing work that has been done hundred or thousands of times before. At this point in my career, I've implemented something like 5-8 complete authentication flows. This means register, login, logout, forgot password, etc. In some cases, it was easy because I used devise in a rails project. In other cases it was hard because I didn't have a web app framework to support me, and thus had to implement it mostly from scratch. In reality, authentication is complex and difficult to get right, but there are clear best practices around user experience and security. I wish that all I had to do was toggle a checkbox in order to enable authentication in my app. Am I being overly optimistic? I don't think so. Imagine for a moment the state of software development in the year 2500. Are we still writing code in plain text files and sending them through a program to convert it into something useful? Do we still deal with dependency hell? In my vision of the future, the answer is no.


I don't claim to have any real solutions to this problem, but I would like to make a call to the open source community to start thinking and talking about this.