-- Put everything in a schema so it's easy to reset and re-run many times
drop schema if exists day_05 cascade;
create schema day_05;

create table day_05.input (
  id             serial,
  text           text not null
);

-- DEV NOTE:
-- Use `\copy`[1] rather than `copy`[2] so its client-side in psql. It does mean that
-- everything has to be on one line though.
-- 1: https://www.postgresql.org/docs/current/app-psql.html#APP-PSQL-META-COMMANDS-COPY
-- 2: https://www.postgresql.org/docs/8.0/sql-copy.html
/*
 * TEST INPUTS
 * Answer A: CMZ
 * Answer B: ?
*/
\copy day_05.input (text) from 'day_05/test_input.txt'

/*
 * ACTUAL CHALLENGES
 * Puzzle A answer: ?
 * Puzzle B answer: ?
*/
-- \copy day_05.inputs (text) from 'day_05/input.txt';

create table day_05.temp as
with raw_initial_state as (
    select
            i.*,
            -- Stack position: 1 is the bottom. Increments as you go higher.
            row_number() over(order by i.id desc) stack_position
    from
            day_05.input i
    where
            (
                -- ignore all the "move x from y to z" lines
                substring(i.text for 1) in (' ', '[') and
                -- ignore the line giving the stack numbers
                substring(i.text for 2) <> ' 1'
            )
)
, pivoted_initial_state as (
    select
            ris.*,
            row_number() over (partition by stack_position) stack_id,
            substring(ris.text from counter for 4) raw_letter
      from
            raw_initial_state ris,
            generate_series(1, length(ris.text), 4) counter
)
, initial_state as (
    select
            pis.stack_id,
            pis.stack_position,
            substring(pis.raw_letter from 2 for 1) letter
      from
            pivoted_initial_state pis
     where
            left(pis.raw_letter, 1) = '['
  order by
            stack_id,
            stack_position
)
select * from initial_state;

-- **********************
-- * vvv Repeat in a loop
-- **********************

with rearrangement_procedure as (
    select
            row_number() over (order by i.id) id,
            cast(split_part(i.text, ' ', 2) as int) num_to_move,
            cast(split_part(i.text, ' ', 4) as int) from_stack,
            cast(split_part(i.text, ' ', 6) as int) to_stack
      from
            day_05.input i
     where
            (
                length(i.text) <> 0 and
                substring(i.text for 1) not in (' ', '[')
            )
)
-- select * from rearrangement_procedure;
update
        day_05.temp t
   set
        -- Move to the desired new stack
        stack_id = rp.to_stack,
        -- Put it on the top of the new stack
        stack_position = (
            select max(t.stack_position)
            from   day_05.temp t
            where  t.stack_id = rp.to_stack
        ) + 1
  from
        rearrangement_procedure rp
 where
        -- Just do this on the first one for now
        rp.id = 1 and
        -- Only move from the desired stack
        t.stack_id = rp.from_stack and
        -- Only move from the top of the stack
        t.stack_position = (
            select max(t.stack_position)
            from   day_05.temp t
            where  t.stack_id = rp.from_stack
        )
;
select * from day_05.temp;

-- **********************
-- * ^^^ Repeat in a loop
-- **********************

with top_letters as (
    select
            t.*,
            (t.stack_position = max(t.stack_position) over (partition by t.stack_id)) is_top
      from
            day_05.temp t
)
-- Puzzle A answer
select
        string_agg(tl.letter, '' order by tl.stack_id) puzzle_a_answer
  from
        top_letters tl
 where
        tl.is_top = true
;

-- create function day_05.some_function()
--   returns void as
-- $body$
-- declare
--   result int;
-- begin
--   -- r is a structure that contains an element for each column in the select list
--   for r in select * from table_name
--   loop
--     if r.id = 'a' then
--       result := r.a * r.b;
--     end if;
--     if r.id = 'b' then
--       result := r.a + r.b;
--     end if;

--     update table
--       set c = result
--     where id = r.id; -- note the where condition that uses the value from the record variable
--   end loop;
-- end
-- $body$
-- language plpgsql

/**
-- Puzzle B answer
select * from number_overlapping;
**/