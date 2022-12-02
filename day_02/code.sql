-- Put everything in a schema so it's easy to reset and re-run many times
drop schema if exists day_02 cascade;
create schema day_02;

-- use enums to validate the inputs
CREATE TYPE day_02.opponent AS ENUM (
  'A', 'B', 'C'
);
CREATE TYPE day_02.self AS ENUM (
  'X', 'Y', 'Z'
);

create table day_02.inputs (
  id        serial,
  opponent  day_02.opponent not null,
  self      day_02.self not null
);

-- DEV NOTE:
-- Use `\copy`[1] rather than `copy`[2] so its client-side in psql. It does mean that
-- everything has to be on one line though.
-- 1: https://www.postgresql.org/docs/current/app-psql.html#APP-PSQL-META-COMMANDS-COPY
-- 2: https://www.postgresql.org/docs/8.0/sql-copy.html
/*
 * TEST INPUTS
 * Answer A: 15
 * Answer B: 12
*/
-- \copy day_02.inputs (opponent, self) from 'day_02/test_input.txt' with delimiter as ' ';

/*
 * ACTUAL CHALLENGES
 * Puzzle A answer: 8933
 * Puzzle B answer: 11998
*/
\copy day_02.inputs (opponent, self) from 'day_02/input.txt' with delimiter as ' ';

-- Puzzle A Scoring
-----------------------
-- X = A = Rock     = 1
-- Y = B = Paper    = 2
-- Z = C = Scissors = 3
--
-- Win              = 6
-- Tie              = 3
-- Loss             = 0
with basic_scores as (
    select
            i.*,
            case
                when i.self = 'X' then 1
                when i.self = 'Y' then 2
                when i.self = 'Z' then 3
            end choice_score,
            case
                when i.self = 'X' and i.opponent = 'A' then 3
                when i.self = 'X' and i.opponent = 'B' then 0
                when i.self = 'X' and i.opponent = 'C' then 6

                when i.self = 'Y' and i.opponent = 'A' then 6
                when i.self = 'Y' and i.opponent = 'B' then 3
                when i.self = 'Y' and i.opponent = 'C' then 0

                when i.self = 'Z' and i.opponent = 'A' then 0
                when i.self = 'Z' and i.opponent = 'B' then 6
                when i.self = 'Z' and i.opponent = 'C' then 3
            end victory_score
      from
            day_02.inputs i
)
, round_score as (
    select
            *,
            (bs.choice_score + bs.victory_score) total_score
      from
            basic_scores bs
)

-- Puzzle A answer
-- select sum(rs.total_score) puzzle_a_answer from round_score rs;


-- Puzzle B Scoring
-----------------------
-- A = Rock     = 1
-- B = Paper    = 2
-- C = Scissors = 3
--
-- Z = Win      = 6
-- Y = Tie      = 3
-- X = Loss     = 0
, basic_scores_b as (
    select
            i.*,
            case
                when i.self = 'X' and i.opponent = 'A' then 3 -- Lose against Rock = Scissors
                when i.self = 'X' and i.opponent = 'B' then 1 -- Lose against Paper = Rock
                when i.self = 'X' and i.opponent = 'C' then 2 -- Lose against Scissors = Paper

                when i.self = 'Y' and i.opponent = 'A' then 1 -- Tie with Rock = Rock
                when i.self = 'Y' and i.opponent = 'B' then 2 -- Tie with Paper = Paper
                when i.self = 'Y' and i.opponent = 'C' then 3 -- Tie with Scissors = Scissors

                when i.self = 'Z' and i.opponent = 'A' then 2 -- Win against Rock = Paper
                when i.self = 'Z' and i.opponent = 'B' then 3 -- Win against Paper = Scissors
                when i.self = 'Z' and i.opponent = 'C' then 1 -- Win against Scissors = Rock
            end choice_score,
            case
                when i.self = 'X' then 0
                when i.self = 'Y' then 3
                when i.self = 'Z' then 6
            end victory_score
      from
            day_02.inputs i
)
, round_score_b as (
    select
            *,
            (bsb.choice_score + bsb.victory_score) total_score
      from
            basic_scores_b bsb
)

-- Puzzle B answer
select sum(rsb.total_score) puzzle_b_answer from round_score_b rsb;
