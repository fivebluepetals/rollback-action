# rollback-action
Github Action for rolling back commits from a certain branch.

The goal of this action is to make it possible to manually rollback
commit(s) from a branch by resetting the head of that branch to a
previous commit in that branch. For example, if the `main` branch
contains errand code and you want the code to be evicted from the
tip, then you can reset the tip to a previous checkpoint using
this action as part of a `workflow_dispatch`.

One can also include this as part of an automated workflow to
back out commits associated with failed builds, though a better 
approach might be to never include those builds as part of your branch 
in the first place.

## Usage

The following creates a dispatch-driven Github action:

```yaml
name: Manually rollback
on:
  workflow_dispatch:
    inputs:
      revision:
        description: 'The revision to rollback to'
        required: true

      branch:
        description: 'The branch that the rollback affects'
        required: true

jobs:
  Rollback:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
           ref: ${{ github.event.inputs.branch }}
           fetch-depth: 0

      - name: Rolls back to a certain version
        uses: fivebluepetals/rollback-action@v1.0.0
        with:
          branch: ${{ github.event.inputs.branch }}
          revision: ${{ github.event.inputs.revision }}
```

When you run this Github action, you will be prompted with the
`branch` and `revision` parameters, formally defined below.

Once successfully run, the tip of your branch will be reset to the value
provided in `revision`.

So if I kick off my workflow dispatch with

- **revision**: `d095ed54576b5af779bec9f1c06745e81ed2e259`
- **branch**: `main`

if the workflow successfully terminates, you will notice that the tip
of `main` is reset to point `d095ed54576b5af779bec9f1c06745e81ed2e259`.

There are two main parameters:

* `branch` - this is the name of a branch in your repository, e.g.
  `main`

* `revision` - this can be a commit hash or a tag pointing to a
  commit in your `branch`

For more information, please see `action.yml`.

## Slightly Deeper Dive

In a nutshell, this is a Docker-based action, whose entrypoint (`entrypoint.sh`)
checks out the branch specified by `branch`,
resets the pointer to the value provided by `revision` and does a
force push.

The script does perform two checks before doing a `--hard` reset:

1. is revision pointer a commit within the branch
2. is the revision pointer an ancestor of the branch

For (1), the action uses `git branch $branch --contains $revision`, with the
explicit assumption that if the revision is not in the branch, then
the command returns nothing.

For (2), it uses `git merge-base --is-ancestor $revision HEAD` with the 
assumption that if $revision is an ancestor, then the expression returns
0; otherwise, the expression returns 1.

If both of these checks succeed, then the script will perform the hard
reset and the force push. Otherwise, it will terminate with a non-zero
exit code.

## Be Really Careful!

### Gotcha #1: Resetting is not the same as Deleting

When you back out commits from branches, all that happens is that the pointer of branches
are reset. Those commits that you have rolled back remain in `.git` and
and can be accessed directly by the commit hash or browsed. The only redress
offered here is that the commit is now obscured a very small bit because the revision itself 
is not pointed to by a named branch.

For example, one might be tempted to use rollback to remove secrets that have
been accidentally checked into Github. DON'T.

If one of your 
developers accidentally checked in a secret and you wanted the world not to see 
the secret, then the best approach at this point is to rotate the secret, monitor access 
and possibly delete the credentialed user in the first place.

### Gotcha #2: Do not rely on this as a trigger for other Github Actions

A limitation of Github actions is that it will not trigger other Github actions.
So if you want to use this to trigger a subsequent workflow by triggering on the
resulting `push` event, then that workflow design will not work.

Instead, design this action to be the first step, and run the downstream
actions not as a triggered workflow, but dependent steps. 

## TODO

- If there are any tags and releases that have been created between the
  target revision and the HEAD, then we want to delete those tags and
  revisions once the rollback is completed

- We are considering Convert this into a JS action so we can test the
  action better. As it stands, it is likely that there might be some bugs
  from corner cases.
