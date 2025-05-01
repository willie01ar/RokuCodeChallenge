/** Updates the on-disk representation of the packaged Unified Error Messaging (EMU) map. */
module.exports = async function fetchEmu() { 
    const request = require("request");
    const c = require("ansi-colors");
    const stableStringify = require("json-stable-stringify");

    const fs = require("fs");
    const path = require("path");
    const util = require("util");

    const constants = require("./constants");

    let current = await util.promisify(fs.readFile)(constants.emu.destination, "utf8");

    let response = await util.promisify(request.get)(constants.emu.source);
    if (response.statusCode !== 200) {
        let msg = `${c.red("ERROR:")} Unable to fetch new EMU map. (${response.statusCode}) ${response.statusMessage}`;
        console.error(msg);
        throw new Error(c.unstyle(msg));
    }

    let emuParsed = JSON.parse(response.body);
    let emuSorted = stableStringify(emuParsed, { space: 1 }) + "\n";

    if (current !== emuSorted) {
        await util.promisify(fs.writeFile)(constants.emu.destination, emuSorted);
        console.log("EMU map updated in filesystem");
    } else {
        console.log(c.dim("EMU already up-to-date"));
    }
};
