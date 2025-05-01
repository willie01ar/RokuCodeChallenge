/** Fetches the current build configuration from the output directory. */
async function getConfig() {
    const c = require("ansi-colors");

    const fs = require("fs");
    const util = require("util");

    const constants = require("./constants");

    let config = {};
    try {
        let configString = await util.promisify(fs.readFile)(constants.config.path);
        config = JSON.parse(configString);
    } catch (err) {
        if (err.code !== "ENOENT") {
            throw err;
        }
    }

    if (config.version && config.version === constants.config.version) {
        return applyOverrides(config);
    } else {
        let msg = `Invalid build config detected!  Please execute ${c.cyan("`npm run configure`")}`;
        console.log(c.red("ERROR:"), msg);
        throw new Error(c.unstyle(msg));
    }
}

function applyOverrides(config) {
    const c = require("ansi-colors");
    const minimist = require("minimist");

    let args = minimist(process.argv.slice(2), { "--": true });
    if (args["--"].length > 0) {
        const net = require("net");

        let maybeIp = args["--"][0];
        if (net.isIP(maybeIp)) {
            config.ipAddr = maybeIp;
        } else {
            console.warn(
                `${c.yellow.bold("WARNING:")} Invalid IP address '${maybeIp}' provided on commandline.  Using configured IP.`
            );
        }
    }

    return config;
}

exports.getConfig = getConfig;
