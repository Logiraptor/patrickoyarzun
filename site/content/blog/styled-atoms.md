+++
tags = [
  "typescript",
  "webpack",
  "css"
]
title = "Typesafe Atomic Design with Typescript & Webpack"
date = "2017-06-26T21:00:00-04:00"
slug = ""
+++


## Background

With webpack and typings-for-css-modules-loader, we can generate types for css files. `styled-atoms` allows you to define atomic (as in atomic design) components with minimal effort.

## Getting Started

Follow the instructions for [typings-for-css-modules-loader][tfcml]. Then install the module:

```bash
npm install styled-atoms
```

Import some css, construct a new Styled instance, and write your atoms:

```typescript
import * as styles from 'atoms.css';
import { Styled } from 'styled-atoms';

const Atomic = new Styled(styles);

const Button = Atomic.atom("button", null, {});
```

This defines a React component called `Button` which behaves exactly like the native `button` element. The second and third arguments allow us to override the behavior of the element by giving it custom properties which control what css classes get applied.




Thanks for reading!


[tfcml]: https://github.com/Jimdo/typings-for-css-modules-loader
[atomic design]:  http://bradfrost.com/blog/post/atomic-web-design/
[sc]: https://github.com/styled-components/styled-components
[sa]: https://github.com/Logiraptor/styled-atoms
