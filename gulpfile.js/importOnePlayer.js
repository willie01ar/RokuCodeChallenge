/**
 * Prerequisite: You need to have the OnePlayer-Roku Repo as a sibling folder to the cube-roku repo https://github.prod.hulu.com/oneplayer/oneplayer-roku
 * 
 * This will:
 * 1) zip the current state of the OnePlayer-Roku repo and copy it to Cube-Roku's components/onePlayer folder.
 * 2) extract out the OnePlayer version number and saves it to the manifest of the cube-roku repo
 */
module.exports = async function importOnePlayer() {
    const fg = require("fast-glob");
    const yazl = require("yazl");
    const fs = require("fs");
    const brs = require("brs");
    const path = require("path");

    const constants = require("./constants");

    let files = await fg([
        "source/**",
        "components/**",
        "manifest"
    ].map(function(dir){
        return path.join(constants.onePlayerImport.source, dir);
    }));

    let zip = new yazl.ZipFile();
    zip.outputStream.pipe(fs.createWriteStream(constants.onePlayerImport.destination));
    let zipWritten = new Promise(function(resolve, reject) {
        zip.outputStream.on("end", resolve);
    });

    files.forEach(file => zip.addFile(file, path.relative(constants.onePlayerImport.source, file)));

    // read OnePlayer-Roku's manifest to extract the version
    let opManifest = await brs.preprocessor.getManifest(constants.onePlayerImport.source);

    let opVersion = [
        opManifest.get("major_version"),
        opManifest.get("minor_version"),
        opManifest.get("build_version")
    ].join(".");

    // read cube-roku's manifest and add/replace the oneplayer sdk version
    fs.readFile(process.cwd() + "/manifest", "utf8", function(err, data){
        if(err) {
            console.log("can't read manifest file");
        } else {
            let opRegex = /(oneplayer_sdk_version=)(\d+.\d+.\d+)/;
            let match = data.match(opRegex);
            if (match === null) {
                data += "oneplayer_sdk_version=" + opVersion + "\n";
            } else {
                data = data.replace(opRegex, "$1" + opVersion);
            }

            fs.writeFile("manifest", data, function(err){
                if(err) {
                    console.log(err);
                }
            });
        }
    });

    zip.end();
    await zipWritten;

}
