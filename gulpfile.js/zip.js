/** Creates a .zip file (and writes it to disk) containing the required application sources. */
module.exports = async function makeZip() {
    const fg = require("fast-glob");
    const yazl = require("yazl");
    const { mkdirp } = require("mkdirp");
    const { getLastCommit } = require("git-last-commit");

    const fs = require("fs");
    const util = require("util");

    const constants = require("./constants");
    const { getConfig } = require("./getConfig");
    const { stringify, getManifest, getBsConst } = require("./manifestUtils.js");

    await mkdirp(constants.zip.dir);
    let config = await getConfig();

    let files = await fg([
        "source/**",
        "components/**",
        "images/**",
        "fonts/**",
        "locale/**"
    ]);

    let zip = new yazl.ZipFile();
    zip.outputStream.pipe(fs.createWriteStream(constants.zip.path));
    let zipWritten = new Promise(function(resolve, reject) {
        zip.outputStream.on("end", resolve);
    });

    files.forEach(file => zip.addFile(file, file));

    //read the manifest file
    let manifest = await getManifest(process.cwd());
    if (manifest.has("bs_const")) {
        manifest.set("bs_const", getBsConst(manifest));
    }

    // override hard-coded values with ones from configuration
    if (config.environment === "staging") {
        manifest.set("is_staging_server", true);
    } else {
        manifest.set("is_staging_server", false);
    }

    if (config.useProxy) {
        manifest.get("bs_const").set("IS_CHARLES", true);
        manifest.set("charles_ip", config.proxyIpAddr);
    }

    if (config.bsProfEnable) {
        bsProfSettings = config.bsProfSettings
        manifest.set("bsprof_enable", 1);
        manifest.set("bsprof_data_dest", bsProfSettings.bsProfDataDest);
        manifest.set("bsprof_enable_lines", bsProfSettings.bsProfEnableLines);
        manifest.set("bsprof_enable_mem", bsProfSettings.bsProfEnableMem);
        manifest.set("bsprof_pause_on_start", bsProfSettings.bsProfPauseOnStart);
    }

    let gitInfo = await util.promisify(getLastCommit)();

    if (gitInfo) {
        manifest.set("git_branch", gitInfo.branch);
        manifest.set("git_commit_hash", gitInfo.hash);
    }

    // write it back to a string, then inject it into the .zip file
    let manifestString = stringify(manifest);
    zip.addBuffer(Buffer.from(manifestString), "manifest");

    zip.end();
    await zipWritten;
};
