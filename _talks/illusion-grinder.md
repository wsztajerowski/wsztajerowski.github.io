---
title: The Illusion Grinder
subtitle: Four circles of testing hell for concurrent Java
order: 1
slides: https://wsztajerowski.github.io/illusion-grinder/
pdf: https://wsztajerowski.github.io/illusion-grinder/slides.pdf
repo: https://github.com/wsztajerowski/illusion-grinder
tags: [JUnit, Fray, jcstress, JMH]
---
Is your concurrent code a solid structure, or a house of cards the wind simply
hasn't hit yet? In this talk we feed a piece of concurrent code into a machine
built for grinding illusions: four circles of testing hell, where every stage is
a gate you must pass before you're allowed any deeper — from naive unit tests,
through a flogging of interleavings in Fray and a brutal workout on real
hardware in jcstress, all the way to a performance examination of conscience in
JMH. No magic. Just brutal engineering and a touch of concurrent sadism.
