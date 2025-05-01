const clean = require("./clean");
const closeApp = require("./closeApp");
const configure = require("./configure");
const deploy = require("./deploy");
const logs = require("./logs");
const zip = require("./zip");

const { series, parallel } = require("gulp");

let build = series(clean, zip);
module.exports = {
    build,
    clean,
    configure,
    deploy: series(
        parallel(closeApp, build),
        deploy
    ),
    logs
};
