---
title: Lynx Journal
repo: https://github.com/wsztajerowski/lynx-journal
order: 3
tags: [Storage, NIO, JMH]
---
An append-only journal for Java: records written to a file channel in batches,
each with a header and checksum, readable back by location. Comes with
concurrency and read-your-own-writes tests, and JMH benchmarks for write-only,
read-last-record and round-trip workloads.
