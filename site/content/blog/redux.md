+++
date = "2017-11-27"
slug = ""
tags = ["", ""]
title = "Redux"
draft = true

+++


TLDR; I'm currently rewriting my scrabble AI's web frontend to use [redux](redux).
It turns out I was not understanding the full picture.

I've found it hard to convince myself in the past that redux is a good idea. 
Even after using it on a relatively large React codebase for six months, 
it felt like we were trying to force functional ideas into javascript for little benefit.
Don't get me wrong, I love the Elm architecture and I think it's a wonderful thing to learn and use,
but it really works well in Elm (at least in part) because the language is built around the same concepts.
In Javascript, we have all sorts of more 'mainstream' design patterns available. We can build factories,
repositories, services, serializers, etc. These patterns have stood the test of time by being used to 
deliver real user value for decades.

## RxJS

Recently I had the pleasure of working in a Vue codebase which enforced strict module separation between
the core domain logic and the vue code. We used RxJS to wire everything up between the core module and
the form inputs. It worked pretty well and generally made a few things (like input validations) really nice to work with.

Redux is like a wrench. It's simple, obvious design makes it easy to operate. It does one thing extremely well and is based on a solid mathematical foundation.

RxJS, on the other hand, is like the 248 piece tool set from the home improvement warehouse. It still has that handy wrench, but it also has a selection of other, differently sized wrenches, as well as screw drivers, a power drill, and a table saw. No matter what you're trying to do, odds are there's already a function in RxJS that does exactly that. You just need to know where to reach for it. The downside to this power is a relatively high barrier to entry.




[redux]: TODO