# Suture 🏥

[![Build Status](https://travis-ci.org/testdouble/suture.svg?branch=master)](https://travis-ci.org/testdouble/suture) [![Code Climate](https://codeclimate.com/github/testdouble/suture/badges/gpa.svg)](https://codeclimate.com/github/testdouble/suture) [![Test Coverage](https://codeclimate.com/github/testdouble/suture/badges/coverage.svg)](https://codeclimate.com/github/testdouble/suture/coverage)

A refactoring tool for Ruby, designed to make it safe to change code you don't
confidently understand. In fact, changing untrustworthy code is so fraught,
Suture hopes to make it safer to completely reimplement a code path.

Suture provides help to the entire lifecycle of refactoring poorly-understood
code, from local development, to a staging environment, and even in production.

Refactoring or reimplementing important code is an involved process! Instead of
listing out Suture's API without sufficient exposition, here is an example that
we'll take you through each stage of the lifecycle.

## development

Suppose you have a really nasty worker method:

``` ruby
class MyWorker
  def do_work(id)
    thing = Thing.find(id)
    # … 99 lines of terribleness …
    MyMailer.send(thing.result)
  end
end
```

### 1. Identify a seam

A seam serves as an artificial entry point that sets a boundary around the code
you'd like to change. A good seam is:

* easy to invoke in isolation
* takes arguments, returns a value
* eliminates (or at least minimizes) side effects (for more on side effects, see [this tutorial](https://semaphoreci.com/community/tutorials/isolate-side-effects-in-ruby))

Then, to create a seam, typically we create a new unit to house the code that we
excise from its original site, and then we call it. This adds a level of
indirection, which gives us the flexibility we'll need later.

In this case, to create a seam, we might start with this:

``` ruby
class MyWorker
  def do_work(id)
    MyMailer.send(LegacyWorker.new.call(id))
  end
end

class LegacyWorker
  def call(id)
    thing = Thing.find(id)
    # … Still 99 lines. Still terrible …
    thing.result
  end
end
```

As you can see, the call to `MyMailer.send` is left at the original call site,
since its effectively a void method being invoked for its side effect, and its
much easier to verify return values.

Since any changes to the code while it's untested are very dangerous, it's
important to minimize changes made for the sake of creating a clear seam.

### 2. Create our seam

Next, we introduce Suture to the call site so we can start analyzing its
behavior:

``` ruby
class MyWorker
  def do_work(id)
    MyMailer.send(Suture.create(:worker, {
      old: LegacyWorker.new,
      args: [id]
    }))
  end
end
```

Where `old` can be anything callable with `call` (like the class above, a
  method, or a Proc/lambda) and `args` is an array of the args to pass to it.

At this point, running this code will result in Suture just delegating to
LegacyWorker without taking any other meaningful action.

### 3. Record the current behavior

Next, we want to start observing how the legacy worker is actually called: what
arguments are sent to it and what values does it return? By recording the calls
as we use our app locally, we can later test that the old and new
implementations behave the same way.

First, we tell Suture to start recording calls by setting the environment
variable `SUTURE_RECORD_CALLS` to something truthy (e.g.
`SUTURE_RECORD_CALLS=true bundle exec rails s`). So long as this variable is set,
any calls to our seam will record the arguments passed to the legacy code path
and the return value.

As you use the application (whether it's a queue system, a web app, or a CLI),
the calls will be saved to a sqlite database. If the legacy code path relies on
external data sources or services, keep in mind that your recorded inputs and
outputs will rely on them as well. You may want to narrow the scope of your
seam accordingly (e.g. to receive an object as an argument instead of a database
id).

#### Hard to exploratory test the code locally?

If it's difficult to generate realistic usage locally, then consider running
this step in production and fetching the sqlite DB after you've generated enough
inputs and outputs to be confident you've covered most realistic uses. Keep in
mind that this approach means your test environment will probably need access to
the same data stores as the environment that made the recording, which may not
be feasible or appropriate in many cases.

### 4. Ensure current behavior with a test

Next, we should probably write a test that will ensure our new implementation
will continue to behave like the old one. We can use these recordings to help us
automate some of the drudgery typically associated with writing
[characterization tests](https://en.wikipedia.org/wiki/Characterization_test).

We could write a test like this:

``` ruby
class MyWorkerCharacterizationTest < Minitest::Test
  def setup
    super
    # Load the test data needed to resemble the environment when recording
  end

  def test_that_it_still_works
    Suture.verify(:worker, {
      :subject => LegacyWorker.new
      :fail_fast => true
    })
  end
end
```

`Suture.verify` will fail if any of the recorded arguments don't return the
expected value. It's a good idea to run this against the legacy code first,
for two reasons:

* running the characterization tests against the legacy code path will ensure
the test environment has the data needed to behave the same way as when it was
recorded (it may be appropriate to take a snapshot of the database before you
start recording and load it before you run your tests)

* by generating a code coverage report
  ([simplecov](https://github.com/colszowka/simplecov) is a good one to start
  with) from running this test in isolation, we can see what `LegacyWorker` is
  actually calling, in an attempt to do two things:
  * maximize coverage for code in the LegacyWorker (and for code that's
  subordinate to it) to make sure our characterization test sufficiently
  exercises it
  * identify incidental coverage of code paths that are outside the scope of
  what we hope to refactor, and in turn analyzing whether `LegacyWorker` has
  side effects we didn't anticipate and should additionally write tests for

### 5. Specify and test a path for new code

Once our automated characterization test of our recordings is passing, then we
can start work on a `NewWorker`. To get started, we can update our Suture
configuration:

``` ruby
class MyWorker
  def do_work(id)
    MyMailer.send(Suture.create(:worker, {
      old: LegacyWorker.new,
      new: NewWorker.new,
      args: [id]
    }))
  end
end

class NewWorker
  def call(id)
  end
end
```

Next, we specify a `NewWorker` under the `:new` key. For now,
Suture will start sending all of its calls to `NewWorker#call`.

Next, let's write a test to verify the new code path also passes the recorded
interactions:

``` ruby
class MyWorkerCharacterizationTest < Minitest::Test
  def setup
    super
    # Load the test data needed to resemble the environment when recording
  end

  def test_that_it_still_works
    Suture.verify(:worker, {
      subject: LegacyWorker.new,
      fail_fast: true
    })
  end

  def test_new_thing_also_works
    Suture.verify(:worker, {
      subject: NewWorker.new,
      fail_fast: false
    })
  end
end
```

Obviously, this should fail until `NewWorker`'s implementation covers all the
cases we recorded from `LegacyWorker`.

Remember, characterization tests aren't designed to be kept around forever. Once
you're confident that the new implementation is sufficient, it's typically better
to discard them and design focused, intention-revealing tests for the new
implementation and its component parts.

### 6. Refactor or reimplement the legacy code.

This step is the hardest part and there's not much Suture can do to make it
any easier. How you go about implementing your improvements depends on whether
you intend to rewrite the legacy code path or refactor it. Some comment on each
approach follows:

#### Reimplementing

The best time to rewrite a piece of software is when you have a better
understanding of the real-world process it models than the original authors did
when they first wrote it. If that's the case, it's likely you'll think of more
reliable names and abstractions than they did.

As for workflow, consider writing the new implementation like you would any other
new part of the system, with the added benefit of being able to run the
characterization tests as a progress indicator and a backstop for any missed edge
cases. The ultimate goal of this workflow should be to incrementally arrive at a
clean design that completely passes the characterization test run by
`Suture.verify`.

#### Refactoring

If you choose to refactor the working implementation, though, you should start
by copying it (and all of its subordinate types) into the new, separate code
path. The goal should be to keep the legacy code path in a working state, so
that `Suture` can run it when needed until we're supremely confident that it can
be safely discarded. (It's also nice to be able to perform side-by-side
comparisons without having to check out a different git reference.)

The workflow when refactoring should be to take small, safe steps using well
understood [refactoring patterns](https://www.amazon.com/Refactoring-Ruby-Addison-Wesley-Professional/dp/0321984137)
and running the characterization test suite frequently to ensure nothing was
accidentally broken.

Once the code is factored well enough to work with (i.e. it is clear enough to
incorporate future anticipated changes), consider writing some clear and clean
unit tests around new units that shook out from the activity. Having good tests
for well-factored code is the best guard against seeing it slip once again into
poorly-understood "legacy" code.

## Staging

Once you've changed the code, you still may not be confident enough to delete it
entirely. It's possible (even likely) that your local exploratory testing didn't
exercise every branch in the original code with the full range of potential
arguments and broader state.

Suture gives users a way to experiment with risky refactors by deploying them to
a staging environment and running both the original and new code paths
side-by-side, raising an error in the event they don't return the same value.
This is governed by the `:call_both` to `true`:

``` ruby
class MyWorker
  def do_work(id)
    MyMailer.send(Suture.create(:worker, {
      old: LegacyWorker.new,
      new: NewWorker.new,
      args: [id],
      call_both: true
    }))
  end
end
```

With this setting, the seam will call through to **both** legacy and refactored
implementations, and will raise an error if they don't return the same value.
Obviously, this setting is only helpful if the paths don't trigger major or
destructive side effects.

## Production

You're _almost_ ready to delete the old code path and switch production over to
the new one, but fear lingers: maybe there's an edge case your testing to this
point hasn't caught.

Suture was written to minimize the inhibition to moving forward with changing
code, so it provides a couple features designed to be run in production when
you're yet unsure that your refactor or reimplementation is complete.

### Logging errors

While your application's logs aren't affected by Suture, it may be helpful for
Suture to maintain a separate log file for any errors that are raised by the
refactored code path.

Suture has a handful of process-wide logging settings that can be set at any
point as your app starts up (if you're using Rails, then your
environment-specific (e.g. `config/environments/production.rb`) config file
is a good choice).

``` ruby
Suture.config({
  :log_level => "WARN", #<-- defaults to "INFO"
  :log_stdout => false, #<-- defaults to true
  :log_io => StringIO.new,      #<-- defaults to nil
  :log_file => "log/suture.log" #<-- defaults to nil
})
```

When your new code path raises an error with the above settings, it will
propogate and log the error to the specified file.

### Custom error handlers

Additionally, you may have some idea of what you want to do (i.e. phone home to
a reporting service) in the event that your new code path fails. To add custom
error handling before, set the `:on_error` option to a callable.

``` ruby
class MyWorker
  def do_work(id)
    MyMailer.send(Suture.create(:worker, {
      old: LegacyWorker.new,
      new: NewWorker.new,
      args: [id],
      on_error: -> (name, args) { PhonesHome.new.phone(name, args) }
    }))
  end
end
```

### Retrying failures

Since the legacy code path hasn't been deleted yet, there's no reason to leave
users hanging if the new code path explodes. By setting the `:fallback_on_error`
entry to `true`, Suture will rescue any errors raised from the new code path and
attempt to invoke the legacy code path instead.

``` ruby
class MyWorker
  def do_work(id)
    MyMailer.send(Suture.create(:worker, {
      old: LegacyWorker.new,
      new: NewWorker.new,
      args: [id],
      fallback_on_error: true
    }))
  end
end
```

Since this approach rescues errors, it's possible that errors in the new code
path will go unnoticed, so it's best used in conjunction with Suture's logging
feature. Before ultimately deciding to finally delete the legacy code path,
double-check that the logs aren't full of rescued errors!

## Public API Summary

* `Suture.create(name, opts)` - Creates a seam in your production source code
* `Suture.verify(name, opts)` - Verifies a callable subject can recreate recorded calls
* `Suture.config(config)` - Sets logging options, as well global defaults for other properties
* `Suture.reset!` - Resets all Suture configuration
* `Suture.delete!(id)` - Deletes a recorded call by `id`
* `Suture.delete_all!(name)` - Deletes all recorded calls for a given seam `name`

## Configuration

Legacy code is, necessarily, complex and hard-to-wrangle. That's why Suture comes
with a bunch of configuration options to modify its behavior, particularly for
hard-to-compare objects.

### Setting configuration options

In general, most configuration options can be set in several places:

* Globally, via an environment variable. The flag `record_calls` will translate
to an expected ENV var named `SUTURE_RECORD_CALLS` and can be set from the
command line like so: `SUTURE_RECORD_CALLS=true bundle exec rails server`, to
tell Suture to record all your interactions with your seams without touching the
source code.

* Globally, via the top-level `Suture.config` method. Most variables can be set
via this top-level configuration, like
`Suture.config(:database_path => 'my.db')`. Once set, this will apply to all your
interactions with Suture for the life of the process until you call
`Suture.reset!`.

* At a `Suture.create` or `Suture.verify` call-site as part of its options hash.
If you have several seams, you'll probably want to set most options locally
where you call Suture, like `Suture.create(:foo, { :comparator => my_thing })`

### Supported options

#### Suture.create

`Suture.create(name, [options hash])`

* _name_ (Required) - a unique name for the seam, by which any recordings will be
identified. This should match the name used for any calls to `Suture.verify` by
your automated tests

* _old_ - (Required) - something that responds to `call` for the provided `args`
of the seam and either is the legacy code path (e.g.
`OldCode.new.method(:old_path)`) or invokes it (inside an anonymous Proc or
lambda)

* _args_ - (Required) - an array of arguments to be passed to the `old` or `new`

* _new_ - like old, but either references or invokes the code path designed to
replace the `old` legacy code path. When set, Suture will default to invoking
the `new` path at the exclusion of the `old` path (unless a mode flag like
`record_calls`, `call_both`, or `fallback_on_error` suggests differently)

* _database_path_ - (Default: `"db/suture.sqlite3"`) - a path relative to the
current working directory to the Sqlite3 database Suture uses to record and
playback calls

* _record_calls_ - (Default: false) - when set to true, the `old` path is called
(regardless of whether `new` is set) and its arguments and result (be it a return
value or an expected raised error) is recorded into the Suture database for the
purpose of more coverage for calls to `Suture.verify`. [Read
more](#3-record-the-current-behavior)

* _call_both_ - (Default: false) - when set to true, the `new` path is invoked,
then the `old` path is invoked, each with the seam's `args`. The return value
from each is compared with the `comparator`, and if they are not equivalent, then
a `Suture::Error::ResultMismatch` is raised. Intended after the `new` path is
initially developed and to be run in pre-production environments. [Read
more](#staging)

* _fallback_on_error_ - (Default: false) - designed to be run in production after
the initial development of the new code path, when set to true, Suture will
invoke the `new` code path. If `new` raises an error that isn't an
`expected_error_type`, then Suture will invoke the `old` path with the same args
in an attempt to recover a working state for the user. [Read more](#production)

* _raise_on_result_mismatch_ - (Default: true) - when set to true, the
`call_both` mode will merely log incidents of result mismatches, as opposed to
raising `Suture::Error::ResultMismatch`.

* _comparator_ - (Default: `Suture::Comparator.new`) - determines how return
values from the Suture are compared when invoking `Suture.verify` or when
`call_both` mode is activated. By default, results will be considered equivalent
if `==` returns true or if they `Marshal.dump` to the same string. If this
default isn't appropriate for the return value of your seam, [read
on](#creating-a-custom-comparator)

* _expected_error_types_ - (Default: `[]`) - if the seam is expected to raise
certain types of errors, don't consider them to be exceptional cases. For
example, if your `:widget` seam is known to raise `WidgetError` objects in
certain cases, setting `:expected_error_types => [WidgetError]` will result in:
  * `Suture.create` will record expected errors when `record_calls` is enabled
  * `Suture.verify` will compare recorded and actual raised errors that are
    `kind_of?` any recorded error type (regardless of whether `Suture.verify` is
    passed a redundant list of `expected_error_types`)
  * `Suture.create`, when `fallback_on_error` is enabled, will allow expected
    errors raised by the `new` path to propogate, as opposed to logging &
    rescuing them before calling the `old` path as a fallback

* _disable_ - (Default: false) - when enabled, Suture will attempt to revert to
the original behavior of the `old` path and take no special action. Useful in
cases where a bug is discovered in a deployed environment and you simply want
to hit the brakes on any new code path experiments by setting
`SUTURE_DISABLE=true` globally

* _dup_args_ - (Default: false) - when enabled, Suture will call `dup` on each
of the args passed to the `old` and/or `new` code paths. Useful when the code
path(s) mutate the arguments in such a way as to prevent `call_both` or
`fallback_on_error` from being effective

* _after_new_ - a `call`-able hook that runs after `new` is invoked. If `new`
raises an error, it is not invoked

* _after_old_ - a `call`-able hook that runs after `old` is invoked. If `old`
raises an error, it is not invoked

* _on_new_error_ - a `call`-able hook that is invoked after `new` raises an
unexpected error (see `expected_error_types`).

* _on_old_error_ - a `call`-able hook that is invoked after `old` raises an
unexpected error (see `expected_error_types`).

#### Suture.verify

`Suture.verify(name, [options hash])`

Many of the settings for `Suture.verify` mirror the settings available to
`Suture.create`. In general, the two methods' common options should be configured
identically for a given seam; this is necessary, because the `Suture.verify` call
site doesn't depend on (or know about) any `Suture.create` call site of the same
name; the only resource they share is the recorded calls in Suture's database.

* _name_ - (Required) - should be the same name as a seam for which some number
of recorded calls exist

* _subject_ - (Required) - a `call`-able that will be invoked with each recorded
set of `args` and have its result compared to that of each recording. This is
used in lieu of `old` or `new`, since the subject of a `Suture.verify` test might
be either (or neither!)

* _database_path_ - (Default: `"db/suture.sqlite3"`) - as with `Suture.create`, a
custom database path can be set for almost any invocation of Suture, and
`Suture.verify is no exception`

* _verify_only_ - (Default: nil) - when set to an ID, Suture.verify` will only
run against recorded calls for the matching ID. This option is meant to be used
to focus work on resolving a single verification failure

* _fail_fast_ - (Default: false) - `Suture.verify` will, by default, run against
every single recording, aggregating and reporting on all errors (just like, say,
RSpec or Minitest would). However, if the seam is slow to invoke or if you
confidently expect all of the recordings to pass verification, `fail_fast` is an
appropriate option to set.

* _call_limit_ - (Default: nil) - when set to a number, Suture will only verify
up to the set number of recorded calls. Because Suture randomizes the order of
verifications by default, you can see this as setting Suture.verify to sample a
random smattering of `call_limit` recordings as a smell test. Potentially useful
when a seam is very slow

* _time_limit_ - (Default: nil) - when set to a number (in seconds), Suture will
stop running verifications against recordings once `time_limit` seconds has
elapsed. Useful when a seam is very slow to invoke

* _error_message_limit_ - (Default: nil) - when set to a number, Suture will only
print up to `error_message_limit` failure messages. That way, if you currently
have hundreds of verifications failing, your console isn't overwhelmed by them on
each run of `Suture.verify`

* _random_seed_ - (Default: it's random!) - a randomized seed used to shuffle
the recordings before verifying them against the `subject` code path. If set to
`nil`, the recordings will be invoked in insertion-order. If set to a specific
number, that number will be used as the random seed (useful when re-running a
particular verification failure that can't be reproduced otherwise)

* _comparator_ - (Default: `Suture::Comparator`) - If a custom comparator is used
by the seam in `Suture.create`, then the same comparator should probably be
used by `Suture.verify` to ensure the results are comparable. [Read
more](#creating-a-custom-comparator) on creating custom comparators
)

* _expected_error_types_ - (Default: `[]`) - this option has little impact on
`Suture.verify` (since each recording will either verify a return value or an
error in its own right), however it can be set to squelch log messages warning
that errors were raised when invoking the `subject`

* _after_subject_ - a `call`-able hook that runs after `subject` is invoked. If
`subject` raises an error, it is not invoked

* _on_new_subject_ - a `call`-able hook that is invoked after `subject` raises an
unexpected error (see `expected_error_types`)

### Creating a custom comparator

Out-of-the-box, Suture will do its best to compare your recorded & actual results
to ensure that things are equivalent to one another, but reality is often less
tidy than a gem can predict up-front. When the built-in equivalency comparator
fails you, you can define a custom one—globally or at each `Suture.create` or
`Suture.verify` call-site.

#### Extending the built-in comparator class

If you have a bunch of value types that require special equivalency checks, it
makes sense to invest the time to extend built-in one:

``` ruby
class MyComparator < Suture::Comparator
  def call(recorded, actual)
    if recorded.kind_of?(MyType)
      recorded.data_stuff == actual.data_stuff
    else
      super
    end
  end
end
```

So long as you return `super` for non-special cases, it should be safe to set an
instance of your custom comparator globally for the life of the process with:

``` ruby
Suture.config({
  :comparator => MyComparator.new
})
```

#### Creating a one-off comparator

If a particular seam requires a custom comparator and will always return
sufficiently homogeneous types, it may be good enough to set a custom comparator
inline at the `Suture.create` or `Suture.verify` call-site, like so:

``` ruby
Suture.create(:my_type, {
  :old => method(:old_method),
  :args => [42],
  :comparator => ->(recorded, actual){ recorded.data_thing == actual.data_thing }
})
```

Just be sure to set it the same way if you want `Suture.verify` to be able to
test your recorded values!

``` ruby
Suture.verify(:my_type, {
  :subject => method(:old_method),
  :comparator => ->(recorded, actual){ recorded.data_thing == actual.data_thing }
})
```

#### Comparing two ActiveRecord objects

Let's face it, a massive proportion of legacy Ruby code in the wild involves
ActiveRecord objects to some extent, and it's important that Suture be equipped
to compare them gracefully. If Suture's default comparator (`Suture::Comparator`)
detects two ActiveRecord model instances being compared, it will behave
differently, by this logic:

1. Instead of comparing the objects with `==` (which returns true so long as the
`id` attribute matdhes), Suture will compare the objects' `attributes` hashes
instead
2. The built-in `updated_at` and `created_at` will typically differ when code
is executed at different times and are usually not meaningful to application
logic, Suture will ignore these attributes by default

Other attributes may or may not matter (for instance, other timestamp fields,
or the `id` of the object), in those cases, you can instantiate the comparator
yourself and tell it which attributes to exclude, like so:

``` ruby
Suture.verify :thing,
  :subject => Thing.new.method(:stuff),
  :comparator => Suture::Comparator.new(
    :active_record_excluded_attributes => [
      :id,
      :quality,
      :created_at,
      :updated_at
    ]
  )
```

If `Thing#stuff` returns an instance of an ActiveRecord model, the four
attributes listed above will be ignored when comparing with recorded results.

In all of the above cases, `:comparator` can be set on both `Suture.create` and
`Suture.verify` and typically ought to be symmetrical for most seams.

## Examples

This repository contains these examples available for your perusal:

* [A Rails app of the Gilded Rose kata](example/rails_app)

## Troubleshooting

Some ideas if you can't get a particular verification to work or if you keep
seeing false negatives:

  * There may be a side effect in your code that you haven't found, extracted,
    replicated, or controlled for. Consider contributing to [this
    milestone](https://github.com/testdouble/suture/milestone/3), which specifies
    a side-effect detector to be paired with Suture to make it easier to see
    when observable database, network, and in-memory changes are made during a
    Suture operation
  * Consider writing a [custom comparator](#creating-a-custom-comparator) with
    a relaxed conception of equivalence between the recorded and observed results
  * If a recording was made in error, you can always delete it, either by
    dropping Suture's database (which is, by default, stored in
    `db/suture.sqlite3`) or by observing the ID of the recording from an error
    message and invoking `Suture.delete!(42)`
