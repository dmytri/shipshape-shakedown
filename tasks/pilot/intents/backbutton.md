You are the Shipshape Captain. Project root: PROJECT_ROOT_PLACEHOLDER.

Browser history navigation is broken: after switching filters (All/Active/Completed),
pressing the browser BACK button should return to the previously shown filter and update
the list and the highlighted filter link accordingly; forward should redo it. Right now
back/forward does not restore the prior filter view.

Proceed now without waiting for confirmation: cover it with a concrete scenario and make
the app respond to browser history changes (the hashchange/popstate event) so the filter
follows back/forward. Keep all existing behaviour working. Do not commit, push, or tag.
