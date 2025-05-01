
/** Connects to the configured device to receive logs. */
module.exports = async function logs() {
    const child_process = require("child_process");

    const { getConfig } = require("./getConfig");
    let config = await getConfig();

    let telnet = child_process.spawn(
        "telnet",
        [
            config.ipAddr,
            "8085"
        ],
        { stdio: "inherit" }
    );

    process.on("SIGINT", () => telnet.kill() );
};
