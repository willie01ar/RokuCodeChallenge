/** Closes the active application by launching app ID 31012 (the Roku home screen). */
module.exports = async function closeApp() {
   // const fetch = require('node-fetch');
    const util = require("util");

    const { getConfig } = require("./getConfig");
    let config = await getConfig();

    try {
        const {default: fetch} = await import("node-fetch");
        //await util.promisify(request.post)(`http://${config.ipAddr}:8060/launch/31012`);
        await fetch(
            `http://${config.ipAddr}:8060/launch/31012`, 
            {
                method: 'POST'
            }
        )
    } catch (e) {
        console.error(e);
    }
};
