# Advent of Code 2022 in PostgreSQL

Solutions for the [Advent of Code 2022](https://adventofcode.com/2022) using
PostgreSQL.

Initialized from [mitchellh/advent-2021-sql](https://github.com/mitchellh/advent-2021-sql)
on GitHub.

## Usage

Bring up the Postgres database with `docker compose up -d`.

Drop into a Postgres console with `make`.

Run the day: `\i day_01/code.sql;`

## Approach

I'm following the same guidelines that Mitchell laid out in his 2021 version:

- Ingest input directly without any modification.
- Arrive at the solution using a single SQL statement. No UPDATE queries to transform the data prior to the statement. Huge CTEs to simulate temporary tables is totally fine.
- No custom functions (no plpgsql). It's too easy to think iteratively with custom functions and one of my goals is to think relationally.
