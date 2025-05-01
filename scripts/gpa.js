#!/usr/bin/env node
/**
 * Gulp with Positional Arguments (GPA): A very tiny wrapper around the `gulp` CLI that allows
 * positional arguments to be sent into gulp tasks *without* them being considered tasks to run.
 *
 * Updates to the `gulp-cli` package may break this behavior in the future.
 */

// Remove any arguments that follow a "--" (POSIX syntax indicating that that "any following
// arguments should be treated as operands, even if they begin with the '-' character."), because
// the default `gulp-cli` ignores that and assumes anything that follows is *also* a task to be run.
//
// POSIX guidelines: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html#tag_12_02
let oldArgv = process.argv;
let maybeDashDash = process.argv.indexOf("--");
if (maybeDashDash !== -1) {
    process.argv = process.argv.slice(0, maybeDashDash);
}

// Require `gulp-cli` after mangling process.argv, because it parses arguments immediately when
// it's required.
let gulp = require("gulp-cli");

// Restore the original argv so our scripts can use it to read positional arguments
process.argv = oldArgv;

// Execute the gulp command provided by users
gulp();
