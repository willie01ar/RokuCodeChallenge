#!/usr/bin/env node
/**
 * Attempts to check a user's running environment to ensure they've got what they need set up.
 * Because they may be running an *ancient* version of node and we want to be able to tell users
 * about that, this script should:
 *
 * 1. Use the most primitive JavaScript language features possible (e.g. no async/await nor let/const)
 * 2. Minimize the number of non-node dependencies
 * 3. Minimize the reliance of newer-but-included node modules (e.g. don't use `util.promisify`)
 * 4. Output everything to stdout, to make sharing its output as simple as possible
 */
var fs = require("fs");
var path = require("path");
var child_process = require("child_process");

var compareVersions;

process.exitCode = 0;

try {
    compareVersions = require("compare-versions");
} catch (e) {
    console.log("[NOT-OK] Unable to load dependencies.  Did you run `npm install`?");
    process.exitCode++;
    return;
}

fs.readFile(path.join(__dirname, "..", "package.json"), function(err, packageJsonString) {
    if (err) {
        console.error(err);
        process.exitCode++;
        return;
    }

    var packageJson = JSON.parse(packageJsonString);
    if (compareVersions.compare(process.version, packageJson.engines.node, ">=")) {
        console.log("[OK] Running known-good version of node.js: " + process.version);
    } else {
        console.log("[NOT OK] Running unverified version of node.js: " + process.version);
        process.exitCode++;
    }

    child_process.exec("npm -v", function(err, stdout, stderr) {
        var npmVersion = stdout.trim();
        if (compareVersions.compare(npmVersion, packageJson.engines.npm, ">=")) {
            console.log("[OK] Running known-good version of npm: " + npmVersion);
        } else {
            console.log("[NOT OK] Running unverified version of npm: " + npmVersion);
            process.exitCode++;
        }
    });
});

