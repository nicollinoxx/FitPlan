# Ranking

## Existing flow

Manual sheet completions and automatic workout/diet item completions create a
`SheetCompletion`. The create/destroy callbacks recalculate `User#ranking_score`
and `current_streak`; `User.refresh_rankings!` still runs daily through Solid
Queue in `config/recurring.yml`. There is no ranking-specific cache.

## Monthly ranking

The calculation uses server-side `Time.current` and the application time zone,
`America/Sao_Paulo`. It considers completions between the start of the month and
the moment of the recalculation. The formula is unchanged: distinct active days
/ 30 × 70, plus the current streak / 30 × 30; rounded to two decimals. Both
components are restricted to the current month.

Both components are capped at 30 days, so a 31-day month cannot push the score
past 100. The window is the month itself rather than a rolling 30-day cutoff
measured from `Time.current`: a cutoff relative to the current clock would drop
part of the first day of the month during the 31st, making the score fall on its
own between two recalculations on the same day, with no completion created or
removed.

`users.ranking_month` identifies the period of the existing aggregate. Queries
and score/streak readers treat aggregates from other months (or with no month)
as zero, including before the daily job runs. The reset is logical — no new job
and no history deletion. `sheet_completions` remains the source for rebuilds; no
score copies or monthly standings snapshots are created.

On deploy, run `bin/rails db:migrate` and
`bin/rails runner 'User.refresh_rankings!'` in the target environment to rebuild
the aggregates of existing users. Without that recalculation, legacy aggregates
stay logically zeroed until a completion or the daily job. The existing daily
refresh remains responsible for streak decay and for the 30-day window within
the month.

## The nightly run

Consistency counts distinct days in the month, so it only moves when a
completion is created or removed, and both already refresh the user. A streak
is consecutive days ending today, so it is the only part of the score that
decays with time, and time passing is not an event this application sees. That
is the whole job of the scheduled run: zero the streak of everyone who did not
complete anything today.

Once the streak is zero the score is its consistency half, which is stored in
`users.consistency_score` for exactly this reason. The run is then a single
statement that copies one column into another, with no formula in SQL to drift
from the Ruby one:

    UPDATE users SET current_streak = 0, ranking_score = consistency_score
    WHERE current_streak <> 0 AND id NOT IN (completions today)

For 200 users that is one statement instead of 801, and no row locks at all.
The result is identical to recalculating every user, which a test asserts by
running both and comparing the aggregates. Being one statement is also why it
runs at 00:05 rather than at 3am: the stored streak is stale between midnight
and the run, and closing that window was not affordable when it cost four
statements and a lock per user.

`User.refresh_rankings!` remains the full recalculation, for deploys and for
rebuilding after a formula change. It reports a failing user through
`Rails.error` and carries on, so one bad row cannot stall the rest.

## Anti-fraud

- All three completion endpoints already assign `completed_at` on the backend
  and reject client-supplied timestamps, time zones or scores. That protection
  is preserved and covered by request tests.
- The ranking ignores completions in the future at calculation time and
  completions from previous months.
- The already-installed Groupdate groups days in the application time zone,
  preventing UTC midnight from turning a single local day into two scorable days.
- Scoring still counts distinct days. Retries and legitimate repeated rounds on
  the same day do not add extra points. Rounds are not deduplicated: the domain
  and the existing tests allow several completions per day.
- A refresh runs two statements: the lock and one grouped read of the month.
  Days come back newest first, so the streak reads off the same list the
  consistency counts instead of grouping twice. `avatar_size` only validates
  when an avatar is actually being attached, so a write of three derived
  columns no longer queries ActiveStorage while holding the lock.
- `with_lock("FOR NO KEY UPDATE")` on the user serializes reads and writes of
  concurrent recalculations, including those triggered by callbacks and by the
  daily job. `FOR NO KEY UPDATE` does not conflict with the `FOR KEY SHARE`
  locks that PostgreSQL takes when inserting rows referencing `users`, so a
  recalculation no longer blocks unrelated completions or follows.
- A completion only refreshes the ranking when it is the earliest one of its
  local day. Extra rounds on a day that already scored cannot change a distinct
  day count, so they take no lock at all: 50 completions on one day acquire one
  lock instead of 50. Comparing by id keeps the lowest one always refreshing, so
  concurrent completions on the same day never all skip. Deletions always
  refresh, since removing the last completion of a day does change the score.

The system records completions declared by the user; it does not physically
verify that the workout happened. Internal writes from models can preserve
historical dates and should stay restricted to trusted sources.

## Streaks on the dashboard and in the ranking

They are different quantities and the labels say so. The dashboard card counts
consecutive days over the whole history, next to total completions and best
weekday, which are also all-time. The ranking card counts the streak that
scores, which the month restricts, and is labelled as the month's.

Making the dashboard monthly would have matched the numbers by discarding the
one users care about: a 50-day streak would read as one day on the 1st. The
monthly reset exists to let a newcomer reach the top of a leaderboard, not to
erase training history.

## Friends ranking

Reuses the existing `friends_ranking` and `User#friends`: the current user plus
mutual followers. This model has no approval or block states; one-way and undone
relationships are left out. Friends with no points and the user themselves still
appear; the global ranking still shows only positive scores.

Both order by descending score and ascending id, and the position honours the
same tie-breaker. The existing routes, pagination, avatar loading and templates
were preserved.

The position is counted on the ranking being displayed, not on a fixed one:
`position_in_ranking` takes the ranking as a required argument, so each tab
reports its own number and there is no implicit one to fall back to. The summary card on the friends tab used
to show the global position, contradicting the list right below it, where a
newcomer can lead their friends while sitting far down the global ranking. The
count is restricted to the current month because aggregates from other months
are displayed as zero and must not count as ahead of anyone.

Both use `by_current_score`, which orders by the two stored columns rather than
by an expression: a month is never in the future, so the current one always
sorts first and aggregates from other months fall behind it, which is where a
score that reads as zero belongs. `ranking_month` is nullable for users who
were never refreshed, and those sort last too. `ranked` constrains the month to
a single value, so the planner drops it from the sort and
`index_users_on_ranking_month_and_ranking_score_and_id` serves the global page
as an index scan, with no sort of the whole table.

## ORM and tests

The month, positive-score and tie-breaker filters use ActiveRecord relations,
ranges and `or`, with no new SQL strings. `by_current_score` orders stale aggregates behind the current ones without
updating them, using only the stored columns. The existing Groupdate
handles the dates and the day ordering, with no extra conversion or sorting in
Ruby.

The month, scoring, friendship and concurrency rules are tested in the models.
The request tests only cover client-controlled parameters, reuse of the diet
completion on retries, and ranking presentation. There are no new browser/E2E
tests and no simulation of a full workout to test dates.

## Relevant files

- `app/models/user/rankable.rb`: monthly aggregate, ordering and locked refresh.
- `app/models/sheet_completion.rb`: history, callbacks and daily grouping.
- `app/models/user/followable.rb`: existing friends definition.
- `app/controllers/rankings_controller.rb`: global and friends endpoints, each passing its own ranking to the summary.
- `db/migrate/20260909160000_add_ranking_month_to_users.rb`: reversible monthly column.
- `db/migrate/20260909160001_index_users_on_ranking_month.rb`: index backing the global ranking.
- `db/migrate/20260918130000_remove_ranking_score_index_from_users.rb`: drops the index no ranking reads any more.
- `config/locales/{pt,en}.yml`: period explanation on the screens.
- `test/models/{user/rankable,sheet_completion}_test.rb`: month, time zone,
  duplication, concurrency, history, friends and tie-breaker.
- `test/controllers/rankings_controller_test.rb` and
  `test/controllers/{sheets,workouts,diets}/completions_controller_test.rb`:
  queries and parameter tampering attempts.
