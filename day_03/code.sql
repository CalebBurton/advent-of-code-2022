-- Put everything in a schema so it's easy to reset and re-run many times
drop schema if exists day_03 cascade;
create schema day_03;

create table day_03.inputs (
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
 * Answer A: pLPvts = 157
 * Answer B: rZ = 70
*/
-- \copy day_03.inputs (text) from 'day_03/test_input.txt';

/*
 * ACTUAL CHALLENGES
 * Puzzle A answer: 8493
 * Puzzle B answer: 2552
*/
\copy day_03.inputs (text) from 'day_03/input.txt';

with compartments as (
    select
            i.*,
            substring(i.text for (length(i.text) / 2)) first_compartment,
            substring(i.text from (length(i.text) / 2) + 1) second_compartment
      from
            day_03.inputs i
)
, compartment_comparison as (
    select distinct
            c.*,
            common.fc common_letter
      from
            compartments c,
            (
                    string_to_table(c.first_compartment, null) fc
              join
                    string_to_table(c.second_compartment, null) sc on fc = sc
            ) common
)
, letter_priorities as (
    select
            -- ascii() converts an ascii character into its codepoint representation
            -- chr() converts an ascii codepoint back into its character representation
            chr(sq.letter_codepoint) letter,
            sq.priority
    from
            (
                -- lowercase
                select
                        generate_series(ascii('a'), ascii('z')) letter_codepoint,
                        generate_series(1, 26) priority
                union
                -- uppercase
                select
                        generate_series(ascii('A'), ascii('Z')) letter_codepoint,
                        generate_series(27, 52) priority
            ) sq
)
, compartment_priorities as (
    select
            cc.*,
            lp.priority letter_priority
      from
            compartment_comparison cc
      join
            letter_priorities lp on cc.common_letter = lp.letter
)
, summed_compartment_priorities as (
    select
            sum(cp.letter_priority) puzzle_a_answer
      from
            compartment_priorities cp
)

-- Puzzle A answer
-- select * from summed_compartment_priorities;

/**/
, elf_groups as (
    select
            i.*,
            count((i.id - 1) % 3 = 0 or null) over (
                order by i.id
            ) group_number,
            ((i.id - 1) % 3 + 1) position_in_group
    from
            day_03.inputs i
)
-- I'm trying to pivot the table here... I guess there's an extension for it
-- called crosstab, but I didn't want to mess with that so I hacked together my
-- own two-step version
, loose_pivoted_groups as (
    select
            eg.group_number,
            eg.text elf_1,
            null elf_2,
            null elf_3
      from
            elf_groups eg
     where
            eg.position_in_group = 1

    union all

    select
            eg.group_number,
            null elf_1,
            eg.text elf_2,
            null elf_3
      from
            elf_groups eg
     where
            eg.position_in_group = 2

    union all

    select
            eg.group_number,
            null elf_1,
            null elf_2,
            eg.text elf_3
      from
            elf_groups eg
     where
            eg.position_in_group = 3
)
, tight_pivoted_groups as (
    select
            group_number,
            max(elf_1) elf_1,
            max(elf_2) elf_2,
            max(elf_3) elf_3
      from
            loose_pivoted_groups lpg
    group by
            group_number
)
, elf_comparison as (
    select distinct
            tpg.*,
            common.e1 common_letter
      from
            tight_pivoted_groups tpg,
            (
                    string_to_table(tpg.elf_1, null) e1
              join
                    string_to_table(tpg.elf_2, null) e2 on e2 = e1
              join
                    string_to_table(tpg.elf_3, null) e3 on e3 = e1
            ) common
)
, elf_priorities as (
    select
            ec.*,
            lp.priority letter_priority
      from
            elf_comparison ec
      join
            letter_priorities lp on ec.common_letter = lp.letter
)
, summed_elf_priorities as (
    select
            sum(ep.letter_priority) puzzle_b_answer
      from
            elf_priorities ep
)

-- Puzzle B answer
select * from summed_elf_priorities;
/**/