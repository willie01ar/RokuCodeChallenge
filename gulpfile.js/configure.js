/** Prompts for a build configuration from users, or accepts one via commandline arguments. */
module.exports = async function configure() {
    const fs = require("fs");
    const net = require("net");
    const path = require("path");
    const util = require("util");

    const prompts = require("prompts");
    const minimist = require("minimist");
    const { mkdirp } = require("mkdirp");

    const constants = require("./constants");
    const { getConfig } = require("./getConfig");

    let args = minimist(process.argv.slice(2), { "--": true });
    if (args["--"].length > 0 || args.h || args.help) {
        console.log("put help here");
        return;
    }

    if (Object.keys(args).filter(k => k !== "_" && k !== "--").length > 0) {
        console.log(args);
        console.log("skipping interactive config");
        return;
    }

    let existingConfig = {};
    try {
        let existingConfigString = await util.promisify(fs.readFile)(constants.config.path);
        existingConfig = JSON.parse(existingConfigString);
    } catch (err) {
        if (err.code !== "ENOENT") {
            throw err;
        }
    }

    function validateIpAddr(maybeIpAddr) {
        if (net.isIP(maybeIpAddr.trim()) === 0) {
            return "Invalid IPv4 or IPv6 address"
        }
        return true;
    }

    function getBsProfSetting(setting, defaultValue = false) {
        if (existingConfig.bsProfSettings == null) {
            return defaultValue;
        }
        return existingConfig.bsProfSettings[setting];
    }

    let questions = [
        {
            type: "text",
            name: "ipAddr",
            message: "What's the IP address of your Roku?",
            initial: existingConfig.ipAddr,
            format: (maybeIp) => maybeIp.trim(),
            validate: validateIpAddr
        },
        {
            type: "toggle",
            name: "environment",
            message: "Do you need a production or staging build?",
            initial: existingConfig.environment === "production",
            active: "Production",
            inactive: "Staging",
            format: (isProd) => isProd ? "production" : "staging"
        },
        {
            type: "toggle",
            name: "useProxy",
            message: "Should your Roku route its network calls through a proxy?",
            initial: existingConfig.useProxy,
            active: "Yes",
            inactive: "No"
        },
        {
            type: (isProxy) => isProxy ? "text" : null,
            name: "proxyIpAddr",
            message: "What's the IP address of the proxy? (Must listen on port 8888)",
            initial: existingConfig.proxyIpAddr,
            format: (maybeProxyIp) => maybeProxyIp.trim(),
            validate: validateIpAddr
        },
        {
            type: "toggle",
            name: "bsProfEnable",
            message: "Would you like to capture perfomance metrics with the BrightScript profiler?",
            initial: existingConfig.bsProfEnable,
            active: "Yes",
            inactive: "No"
        },
        {
            type: (isBsProfEnabled) => isBsProfEnabled ? "multiselect" : null,
            name: "bsProfSettings",
            message: "Configure your profile capture:",
            format: (values) => {
                return {
                    bsProfDataDest: values.includes(0) ? "network" : "local",
                    bsProfEnableLines: + values.includes(1),
                    bsProfEnableMem: + values.includes(2),
                    bsProfPauseOnStart: + values.includes(3)
                };
            },
            choices: [
                { title: 'streaming capture (faster)', selected: getBsProfSetting("bsProfDataDest", true) },
                { title: 'collect line level metrics (degrades perf)', selected: getBsProfSetting("bsProfEnableLines") },
                { title: 'collect memory usage and leak detection (degrades perf)', selected: getBsProfSetting("bsProfEnableMem") },
                { title: 'pause on start', selected: getBsProfSetting("bsProfPauseOnStart") }
            ]
        },
    ];
    let results = await prompts(questions);
    let configuration = {
        ...{
            version: constants.config.version,
            proxyIpAddr: existingConfig.proxyIpAddr
        },
        ...results
    };

    // await util.promisify(mkdirp)(constants.config.dir);
    await mkdirp(constants.config.dir);
    await util.promisify(fs.writeFile)(
        constants.config.path,
        JSON.stringify(configuration)
    );
};
