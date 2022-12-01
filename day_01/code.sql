-- Put everything in a schema so it's easy to reset and re-run many times
drop schema if exists day_01 cascade;
create schema day_01;

create table day_01.inputs (
  id        serial,
  calories  integer default null
);

-- DEV NOTE:
-- Use `\copy`[1] rather than `copy`[2] so its client-side in psql. It does mean that
-- everything has to be on one line though.
-- 1: https://www.postgresql.org/docs/current/app-psql.html#APP-PSQL-META-COMMANDS-COPY
-- 2: https://www.postgresql.org/docs/8.0/sql-copy.html
/*
 * TEST - answer A: 24000, answer B: 45000
*/
-- \copy day_01.inputs (calories) from 'day_01/test_input.txt' with null as '';

/*
 * ACTUAL CHALLENGES
 * Puzzle A answer: 70698
 * Puzzle B answer: 206643
*/
\copy day_01.inputs (calories) from 'day_01/input.txt' with null as '';

/* A misguided approach...
 *
 * with all_bounds_except_the_final_one as (
 *     select
 *             lag(
 *                 i.id,   -- column
 *                 1,          -- offset (defaults to 1)
 *                 0           -- default value (defaults to null)
 *             ) over (
 *                 -- default partition: entire result set
 *                 -- default order: existing order
 *                 -- default window frame (for window with no order):
 *                 --    rows between unbounded preceding and unbounded following
 *             ) start_idx,
 *             i.id end_idx
 *       from
 *             day_01.inputs i
 *     where
 *             i.calories is null
 * )
 * -- There's probably a cleaner way to do this... all this nonsense just for the
 * -- final elf. It's a special case since there's no trailing blank line
 * , final_bound as (
 *     select
 *             start_idx,
 *             end_idx
 *       from (
 *             select
 *                     1 key,
 *                     max(abetfo.end_idx) start_idx
 *               from
 *                     all_bounds_except_the_final_one abetfo
 *       ) s
 *       join (
 *             select
 *                     1 key,
 *                     (count(i.id) + 1) end_idx
 *             from
 *                     day_01.inputs i
 *       ) e on s.key = e.key
 * )
 * , bounds as (
 *     select * from all_bounds_except_the_final_one abetfo
 *     union
 *     select * from final_bound fb
 *     order by start_idx
 * )
*/

with input_with_elves as (
    select
            i.*,
            count(i.calories is null or null) over (
                order by i.id
            ) elf
      from
            day_01.inputs i
)
, sums as (
    select distinct
            sum(iwe.calories) over (
                partition by iwe.elf
            ) total_cals
      from
            input_with_elves iwe
  order by
            total_cals
)
, max_cals as (
    select
            s.total_cals puzzle_a_answer
      from
            sums s
  order by
            s.total_cals desc
     limit
            1
)
, top_three_cals as (
    select
            s.total_cals
      from
            sums s
  order by
            s.total_cals desc
     limit
            3
)
, summed_top_three_cals as (
    select
            sum(ttc.total_cals) puzzle_b_answer
      from
            top_three_cals ttc
)

-- Puzzle A answer
-- select * from max_cals;

-- Puzzle B answer
select * from summed_top_three_cals;
