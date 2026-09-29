---
title: Lynx Journal
repo: https://github.com/wsztajerowski/lynx-journal
order: 3
tags: [Storage, NIO, JMH]
description:
  pl: |-
    Dziennik typu append-only dla Javy: rekordy zapisywane partiami do kanału
    pliku, każdy z nagłówkiem i sumą kontrolną, odczytywane po lokalizacji.
    Zawiera testy współbieżności i read-your-own-writes oraz benchmarki JMH
    dla samego zapisu, odczytu ostatniego rekordu i pełnego cyklu zapis–odczyt.
  en: |-
    An append-only journal for Java: records written to a file channel in
    batches, each with a header and checksum, readable back by location. Comes
    with concurrency and read-your-own-writes tests, and JMH benchmarks for
    write-only, read-last-record and round-trip workloads.
---
