# Suture

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
* eliminates (or at least minimizes) side effects

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

### 2. Create our suture

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
any calls to our suture will record the arguments passed to the legacy code path
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

* by generating a code coverage report (
  [simplecov](https://github.com/colszowka/simplecov) is a good one to start
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

## staging

Once you've changed the code, you still may not be confident enough to delete it
entirely. It's possible (even likely) that your local exploratory testing didn't
exercise every branch in the original code with the full range of potential
arguments and broader state.

Suture gives users a way to experiment with risky refactors by deploying them to
a staging environment and running both the original and new code paths
side-by-side, raising an error in the event they don't return the same value.
This is governed by the `:run_both` to `true`:

``` ruby
class MyWorker
  def do_work(id)
    MyMailer.send(Suture.create(:worker, {
      old: LegacyWorker.new,
      new: NewWorker.new,
      args: [id],
      run_both: true
    }))
  end
end
```

With this setting, the seam will call through to **both** legacy and refactored
implementations, and will raise an error if they don't return the same value.
Obviously, this setting is only helpful if the paths don't trigger major or
destructive side effects.

## production

You're _almost_ ready to delete the old code path and switch production over to
the new one, but fear lingers: maybe there's an edge case your testing to this
point hasn't caught.

Suture was written to minimize the inhibition to moving forward with changing
code, so it provides a couple features designed to be run in production when
you're yet unsure that your refactor or reimplementation is complete.

### Logging errors

While your application's logs aren't affected by Suture, it may be helpful for
Suture to maintain a separate log file for any errors that are raised by the
refactored code path. Setting the key `:log` to a path will prompt Suture to
append any errors to a log at that location.

``` ruby
class MyWorker
  def do_work(id)
    MyMailer.send(Suture.create(:worker, {
      old: LegacyWorker.new,
      new: NewWorker.new,
      args: [id],
      log: 'log/my_worker_seam.log'
    }))
  end
end
```

### Retrying failures

Since the legacy code path hasn't been deleted yet, there's no reason to leave
users hanging if the new code path explodes. By setting the `:retry` entry to
`true`, Suture will rescue any errors raised from the new code path and attempt
to invoke the legacy code path instead.

``` ruby
class MyWorker
  def do_work(id)
    MyMailer.send(Suture.create(:worker, {
      old: LegacyWorker.new,
      new: NewWorker.new,
      args: [id],
      retry: true
    }))
  end
end
```

Since this approach rescues errors, it's possible that errors in the new code
path will go unnoticed, so it's best used in conjunction with Suture's logging
feature. Before ultimately deciding to finally delete the legacy code path,
double-check that the logs aren't full of rescued errors!
