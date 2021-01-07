# Vendored GitHub Action scripts

This repository contains copies of all GitHub Action projects/libraries/scripts
that get access to sensitive environment or input variables.

The purpose of vendoring those actions is:
 - Avoid automatic updates by pinning down an exact commit to use.
 - Put focus on auditability by checking in the full code of all actions.
 - Every version update requires a PR where the full diff can be reviewed.

## How to add/update actions

There is a shell script (`vendor.sh`) that performs the following steps for each
action:
 - Download source archive of specified commit from GitHub.
 - Extract source into `@<action-name>` directory.
 - Run `npm install` and `npm build` (or `npm package` for some actions).
 - Copy all files necessary to run the action into the folder `<action-name>`.

To add a new action, simply add a new line to the bottom of the `vendor.sh`
script:

```shell
vendor "<gh-org-name>" "<gh-repo-name>" "<commit-hash>" "<npm-action-name>"
```

To update an action, simply replace the git commit hash with a new version.

## How to audit an action

Whenever the `vendor.sh` is updated, it should also be executed. That will
produce the full diff against what was last used.

The following steps should then be performed to review the code in the actions
(these are the absolute minimum steps, more review can always be performed if
deemed necessary):
 - Check the `dependencies` section of the `package.json` file. Is there an
   unreasonable amount of 3rd party dependencies? Do the dependencies have
   known vulnerabilities?
 - Look through the main code of the action. Does it have hard coded URLs that
   are used and look suspicious?
 - Look through the diff of the `dist/index.js` file. Any weird changes?
