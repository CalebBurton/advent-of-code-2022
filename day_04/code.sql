-- Put everything in a schema so it's easy to reset and re-run many times
drop schema if exists day_04 cascade;
create schema day_04;

create table day_04.inputs (
  id        serial,
  text      text not null
);

-- DEV NOTE:
-- Use `\copy`[1] rather than `copy`[2] so its client-side in psql. It does mean that
-- everything has to be on one line though.
-- 1: https://www.postgresql.org/docs/current/app-psql.html#APP-PSQL-META-COMMANDS-COPY
-- 2: https://www.postgresql.org/docs/8.0/sql-copy.html
/*
 * TEST INPUTS
 * Answer A: 2
 * Answer B: 4
*/
-- \copy day_04.inputs (text) from 'day_04/test_input.txt';

/*
 * ACTUAL CHALLENGES
 * Puzzle A answer: 464
 * Puzzle B answer: 770
*/
\copy day_04.inputs (text) from 'day_04/input.txt';

with elves as (
    select
            i.*,
            split_part(i.text, ',', 1) first_elf,
            split_part(i.text, ',', 2) second_elf
            -- substring(i.text for (length(i.text) / 2)) first_compartment,
            -- substring(i.text from (length(i.text) / 2) + 1) second_compartment
      from
            day_04.inputs i
)
, start_and_end as (
    select
            e.*,
            cast(split_part(e.first_elf, '-', 1) as int) first_elf_start,
            cast(split_part(e.first_elf, '-', 2) as int) first_elf_end,
            cast(split_part(e.second_elf, '-', 1) as int) second_elf_start,
            cast(split_part(e.second_elf, '-', 2) as int) second_elf_end
      from
            elves e
)
, containment as (
    select
            sae.*,
            (
                (sae.first_elf_start <= sae.second_elf_start) and
                (sae.first_elf_end >= sae.second_elf_end)
            ) first_contains_second,
            (
                (sae.first_elf_start >= sae.second_elf_start) and
                (sae.first_elf_end <= sae.second_elf_end)
            ) second_contains_first
      from
            start_and_end sae
)
, number_contained as (
    select
            count(*) puzzle_a_answer
      from
            containment c
     where
            c.first_contains_second or c.second_contains_first
)

-- Puzzle A answer
-- select * from number_contained;

/**/
, any_overlap as (
    select
            sae.*,
            (
                (sae.first_elf_end >= sae.second_elf_start) and
                (sae.second_elf_end >= sae.first_elf_start)
            ) first_overlaps_second
      from
            start_and_end sae
)
, number_overlapping as (
    select
            count(*) puzzle_b_answer
      from
            any_overlap ao
     where
            ao.first_overlaps_second
)

-- Puzzle B answer
select * from number_overlapping;
/**/