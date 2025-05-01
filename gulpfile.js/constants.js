const path = require("path");

const rootDir = path.join(__dirname, "..")
const outputDir = path.join(rootDir, "bin");
module.exports = {
    zip: {
        dir: outputDir,
        path: path.join(outputDir, "CodeChallenge.zip")
    },
    config: {
        version: 1,
        dir: outputDir,
        path: path.join(outputDir, ".configuration.json")
    },
    manifest: {
        dir: rootDir,
        path: path.join(rootDir, "manifest")
    }
};
