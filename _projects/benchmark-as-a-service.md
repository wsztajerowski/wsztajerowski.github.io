---
title: Benchmark as a Service (BaaS)
repo: https://github.com/wsztajerowski/benchmark-as-a-service
order: 1
tags: [JMH, jcstress, AWS]
---
Run JMH and JCStress benchmarks on throwaway EC2 instances, from one command, on
hardware that isn't your laptop. The `baas` CLI provisions its own AWS
infrastructure, launches the runner, polls for completion and prints the
numbers; measurements land in DynamoDB, raw results and profiling artifacts in
S3.
