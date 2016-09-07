# Gilded Rose Web App

This is the Gilded Rose kata applied to a little Rails app. A Suture seam has
been created right at the point where `update_quality` is called from the
`ItemsController.

A few things you might play with:

## Running the app

Run the app as you would any other Rails app and at the [root
path](http://localhost:3000), you should be able to create gilded rose items,
see them listed, and batch update their quality.

## Recording calls

You can enable recording calls by uncommenting `:record_calls` in the
[ItemsController](app/controllers/items_controller.rb)'s
`#update_all` method. Once set, any calls will capture each item's
initial state and mutated state in the database (due to the design of the seam
to take a void method and wrap it in a lambda that makes it resemble a pure
function with an input and output.

## Verifying calls

In [the characterization test](test/suture/update_quality_test.rb), you can see
the calls to `Suture.verify` as providing test automation for both the old code
path (in [Item](app/models/item.rb)) and the new code path (in
[QualityUpdater](lib/quality_updater.rb). Once verifying the tests pass, you
might consider tweaking the implementation of either code path to see how
Suture's verification failure messages will look in response.

## Wiring the new implementation to the Seam

At present, the seam in the controller is pointing at the old implementation in
`Item#update_quality`, but the new code path is ready to be wired up via Suture's
`:new` option.

If `:new` is set and `:record_calls` is *not* enabled, then all calls will by
default be routed to the `:new` code path.

### Trying the `call_both` strategy

To continuously validate the new code path against the old path with whatever
data you can throw at it via the web interface, enable the `:call_both` option
in the seam in `ItemsController`.

To see what a Suture mismatch result error looks like, try intentionally breaking
the new code path in `QualityUpdater`.

### Trying the `fallback_on_error` strategy

Try setting `:fallback_on_error` on the seam and then change the new code path
to raise an error in some case. You should see some chatty logs warning you of
the error in the new code path, but they ought to be invisible to the end user,
because Suture will rescue the error and call the old code path instead.

This is a useful setting when putting a risky change into production for the
first time and you want to add an extra layer of protection to the user's
experience in the event that a bug exists.

Additionally, you might try setting the `:expected_error_types` option to compare
the behavior of this feature when an expected error type is raised versus some
other error type of error.



