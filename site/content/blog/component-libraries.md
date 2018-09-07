+++
title = "Component Libraries as a Communication Tool"
date = "2018-09-06T19:24:46-05:00"
description = "In this document, I describe my experience using component libraries while developing web applications."
+++

# Definitions

When talking about component libraries, especially with external stakeholders and teams, it's easy to talk past each other. In order to prevent some of that, I'll first define some terms as I use them in this document.

Style Guide
: A document which defines a brand. This typically includes things like **colors**, **logos**, **fonts**, and *maybe* **form control styles**. They are useful when designing completely new assets and enforce a consistent look and feel.

Component
: A meaningful unit of an interface. It could be a single HTML element - e.g. a header, a collection of elements - e.g. a form, or a complete page. Components can and should contain other components when it makes sense.

Component Library
: A library of components. Inside you will find **self-contained**, **reusable**, **named** **components**. This may or may not include a style guide as one part of the library. An important characteristic is that the component library must reference the same code as the production system.

Living Style Guide
: The same thing as a component library.

Design System
: A tool used by product teams to guide visual design work and enable a consistent user experience. It typically takes the form of several artifacts including style guides, component libraries, mood boards, etc.

Engineer
: A person who turns user stories into code.

Designer
: A person who turns user research into visual designs.

# Why build a component library?

To answer the question of "why", I'll describe a series of problematic scenarios and how component libraries help to mitigate those problems. 

## Scenario 1: "Designers can't make up their minds"

In this scenario, the designer has created a mockup with a new UI component and attached it to a user story. It's a 1-point story, and it's quickly finished. After the next round of user research, the designer wants to make a simple change to that component in order to make the product better. The change is made in the mockup and attached to the relevant user story. At the next estimation session, the engineer proclaims this change is 5 points! It turns out that what the designer thought was a simple change, was actually a fundamental restructuring of the code. The team spends the next few days working through a sizable refactor in order to support the new functionality.

 This happens often in product teams, especially if design and engineering aren't regularly collaborating on work in progress. By collaborating around a component library, the story looks a little different.

 Now, when a new UI component needs to be introduced, the designer and engineer pair on adding it to the component library *first*. The designer takes the opportunity to iron out any styling issues in real time, and the engineer takes the opportunity to understand the expected behavior of the component, and if necessary test-drives the logic. Only after these steps are done, the component is dropped into the app. When the team needs to make a change to that component, the engineer and designer pair on the change. In doing this repeatedly over time, both team members gain empathy for each other. The engineer will learn to anticipate changes in a healthy way by understanding the root cause. The designer will learn to weigh the cost of change by paying that cost personally.

 It's important to note that the component library is not really the point. What's important is the fact that it's forcing engineering and design to communicate _early and often_.

## Scenario 2: "Engineers just don't get it"

In this scenario, the designer has spent a few weeks doing research and developing a design system for the product. An engineer finishes a user story, but because they were working from mockups only, some details had to be filled in. Mockups are often static images which have little to no information about how an interface should react to changing screen size for example. During implementation, the engineer made an educated guess about the various layout constraints in the system. This goes on for a week on a few more stories as well. One morning, the designer opens a bug in the team's issue tracker. The product looks _terrible_ on mobile. The design system was ready for this. Care and thought were put into choosing just the right layout, fonts, padding... everything. Unfortunately, much of that information never made it out of the designer's head and into the code.

One solution that I've seen teams use here is to double down on tooling and documentation. There are plenty of tools which claim to solve the 'handoff' problem, e.g. [Zeplin](https://zeplin.io/) and [Invision Inspect](https://www.invisionapp.com/feature/inspect). These tools help, but they are only a piece of the solution. By sitting together and collaborating on the product regularly, as you would with a component library, you are forced to work through assumptions *together*. The pair has an opportunity to talk through it. Because they are pairing, not documenting, when something is unreasonably hard to pull off, there is almost no cost in changing the desired state.

## Scenario 3: "Why can't you just do _that_, but _over there_?"

In this scenario, the product has been in production for months or years. One day a user story comes along that seems simple to everyone except the engineers. Take an existing component on one page and move it to a different page. Because of the cascade in cascading style sheets (CSS), the component was written such that its styles depend on the context in which it is rendered. This is a classic example of poor CSS architecture, but it happens often. 

By using a component library and defining components first in the isolated environment of the component library, the engineer is forced to make the component work in _two places_. This will almost always make the component less coupled to its environment and therefore easier to move later. I've noticed this to be even more profound when working on a team with limited CSS proficiency. 

This is analogous to the way that test-driven development (TDD) forces engineers to use each component of a system in two places: the tests and the production code. Similarly, the result is less coupled, more modular code. One way to think of a component library is interactive, visual TDD for your user interface.

# Migrating to a component library

If the scenarios above resonate with you and your team, you might be wondering how you can migrate to using a component library when you don't have one. Here's how I've done it:

First, print out whatever design assets you have - wireframes, mockups, etc. Have an engineer and a designer sitting next to each other and circle pieces of the mockup. Try to circle things that are _semantically related in the design system_[^1]. Then, give each circle a name. It's critical that the whole team commits to using that name from now on. If you aren't using the same names, then you aren't speaking the same language, and you might as well not have a component library.

Remember that whatever you come up with during this session, it's just a first pass. You will continue to change and refine your component library as well as your language throughout the life of the project.

Now that you have names associated with visual elements, you will need to start the hard work of separating each component from the context it currently lives in and placing it in the component library. While doing this part, you might find some opportunities to [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) up your code. You will need to know the "why" behind each component in order to determine if de-duplication is appropriate. Depending on your team, it might be productive to do this as an engineer/designer pair, but it might not. Don't be afraid to pair here though. I'd advise erring on the side of pairing.


[^1]: The process of deciding whether to group certain items is hard to define in general. I recommend reading up on [Atomic Design](http://bradfrost.com/blog/post/atomic-web-design/) for one source of inspiration, but there are many philosophies here.

# What framework should I use?

You may have heard of [storybook](https://storybook.js.org/). I've never used storybook or any other library to build my component libraries. Typically that decision starts with the desire to keep it simple. Then I simply have never needed any features beyond 'render this component with this state/props/whatever', and some simple tab-like navigation.

If I were to build a new component library today, I'd add a page to my app, maybe `/components`, which renders a white page with some components. This is as simple as:

```html
<h1>Primary Button</h1>
<Button primary>
<h1>Secondary Button</h1>
<Button secondary>
```

Eventually, I'll have enough components that it's annoying to scroll up and down. At that point, I'd add some links which go to `/components/thing-a-ma-bobs`, `/components/widgets`, etc. How do you decide where to split them? Move stuff around until it feels right.

To be clear, there's nothing necessarily wrong with using a library. But it's not the point. If you're using storybook and you're not spending most of your time on refining your communication, iterate until you are.

If nothing mentioned here sounds like a problem you have, you might not need a component library.
