/** Deletes all build artifacts from previous runs. */
module.exports = async function clean() {
    const util = require("util");
    const { rimraf } = await import("rimraf");

    const constants = require("./constants");

    // await util.promisify(rimraf.default)(constants.zip.path);
    await rimraf(constants.zip.path);
};
