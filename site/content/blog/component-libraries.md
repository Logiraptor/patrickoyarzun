+++
title = "Component Libraries as a Communication Tool"
date = "2017-11-25T13:54:46-05:00"
draft = true
+++


In this document, I describe my experience using component libraries while developing web applications.

## Definitions

When talking about component libraries, especially with external stakeholders and teams, it's easy to talk past each other. In order to prevent some of that, I'll first define some terms as I use them.


1. A *style guide* is a document which defines a brand. This typically includes things like **colors**, **logos**, **fonts**, and *maybe* **form control styles**. They are useful when designing completely new assets and enforce a consistent look and feel.

2. A *component library* is literally a library of components. Inside you will find **self-contained**, **reusable**, **named** **components**. This may or may not include a style guide as one part of the library. A component library is a superset of a style guide in terms of functionality. An important characteristic is that the component library should reference the same code as the production system.

3. A _living style guide_ is the same thing as a component library.

3. A *design system* is a tool used by product teams to guide new visual design work and enable a consistent user experience. It typically takes the form of several artifacts including style guides, component libraries, mood boards, etc.

3. An *engineer* is a person who takes well-defined user stories and turns them into delivered software. I use engineer to mean full-stack developer.

4. A *designer* is a person who conducts qualitative user research, understands the user's needs, and produces visual designs that are attached to user stories in order to guide the engineer.

## Why build a component library?

To answer the question of "why", I'll describe a series of problematic scenarios and how component libraries help to mitigate those problems. 

### Scenario 1: "Designers can't make up their minds"

In this scenario, the designer has created a mockup with a new ui component and attached it to a user story. It's a 1-point story, and it's quickly finished. After the next round of user research, the designer wants to make a simple change to that component in order to make the product better. The change is made in the mockup and attached to the relevant user story. At the next estimation session, the engineer proclaims this change is 5 points! It turns out that what the designer thought was a simple change, was actually a fundamental restructuring of the code. The team spends the next few days working through a sizable refactor in order to support the new functionality.

 This happens often in product teams, especially if design and engineering aren't regularly collaborating on work in progress. By collaborating around a component library, the story looks a little different.

 Now, when a new ui component needs to be introduced, the designer and engineer pair on adding it to the component library *first*. The designer takes the opportunity to iron out any css styling issues in real time, and the engineer takes the opportunity to understand the expected behavior of the component, and if necessary test-drives the logic. Only after these steps are done, the component is dropped into the app. When the team needs to make a change to that component, the engineer and designer pair on the change. In doing this repeatedly over time, both team members gain empathy for each other. The engineer will learn to anticipate change in a health way by understanding the root cause. The designer will learn to weigh the cost of change by paying that cost personally.

 It's important to note that the component library is not really the point. What's important is the fact that it's forcing engineering and design to communicate _early and often_.

### Scenario 2: "Engineers just don't get it"

In this scenario, the designer has spent a few weeks doing research and developing a design system for the product. An engineer finishes a user story, but because they were working from mockups only, some details had to be filled in. Mockups are often static images which have little to no information about how an interface should react to changing screen size for example. During implementation, the engineer made an educated guess about the various layout constraints in the system. This goes on for a week on a few more stories as well. One morning, the designer opens a bug in the team's issue tracker. The product looks _terrible_ on mobile. The design system was ready for this. Care and thought was put into choosing just the right layout, fonts, padding... everything. Unfortunately, much of that information never made it out of the designer's head and into the code.

One solution that I've seen teams use here is to double down on tooling and documentation. There are plenty of tools which claim to solve the 'handoff' problem, ie Zeplin and Invision Inspect. These tools help, but they are only a piece of the solution. By sitting together and collaborating on the product regularly, as you would with a component library, you are forced to work through assumptions *together*. The pair has an opportunity to talk through it. Because they are pairing, not documenting, when something is unreasonably hard to pull off, there is almost no cost in changing the desired state.

### Scenario 3: "Why can't you just do _that_, but _over there_?"

In this scenario, the product has been in production for months. One day a user story comes along that seems simple to everyone except the engineers. Take an existing component on one page and move it to a different page. Because of the cascade in cascading style sheets, the component was written so that it's styles depend on the context in which it is rendered. This is a classic example of poor CSS architecture, but it happens often. 

By using a component library and defining components there first then in the app, the engineer is forced to make the component work in _two places_. This will almost always make the component less coupled to its environment and therefore easier to move later. I've noticed this to be even more profound of a factor when working on a team with limited CSS proficiency. 

This is analogous to the way that TDD forces engineers to use each component of a system in two places: the tests and the production code. Similarly, the result is less coupled, more modular code.


## Migrating to a component library

## What framework should I use?

