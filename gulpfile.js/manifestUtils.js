const fs = require('fs');
const path = require('path');
const util_1 = require("util");
const readFile = util_1.promisify(fs.readFile);

/**
 * Converts a parsed representation of a Roku `manifest` file back into a single string,
 * suitable for use in place of a `manifest` file found on-disk.
 * @param {Map<string,(string|integer|boolean)>} manifest - the parsed manifest
 * @returns {string} the manifest but as a string
 */
function stringify(manifest) {
    if (manifest == null) { return ""; }

    return Array.from(manifest.entries(), ([key, value]) => {
        if (key === "bs_const" && value instanceof Map) {
            let rightHandSide = Array.from(value.entries(), ([constName, constValue]) => {
                return `${constName}=${constValue}`
            }).join(";");

            return `${key}=${rightHandSide}`;
        } else {
            return `${key}=${value}`;
        }
    }).join("\n");
};

async function getManifest(rootDir) {

    let manifestPath = path.join(rootDir, "manifest");
    let contents;
    try {
        contents = await readFile(manifestPath, "utf-8");
    }
    catch (err) {
        return new Map();
    }
    return parseManifest(contents);
};

/**
 * Attempts to parse a `manifest` file's contents into a map of string to JavaScript
 * number, string, or boolean.
 * @param contents the text contents of a manifest file.
 * @returns a Promise that resolves to a map of string to JavaScript number, string, or boolean,
 *          representing the manifest file's contents
 */
function parseManifest(contents) {
    let keyValuePairs = contents
        // for each line
        .split("\n")
        // remove leading/trailing whitespace
        .map((line) => line.trim())
        // separate keys and values
        .map((line, index) => {
        // skip empty lines and comments
        if (line === "" || line.startsWith("#")) {
            return ["", ""];
        }
        let equals = line.indexOf("=");
        if (equals === -1) {
            throw new Error(`[manifest:${index + 1}] No '=' detected.  Manifest attributes must be of the form 'key=value'.`);
        }
        return [line.slice(0, equals), line.slice(equals + 1)];
    })
        // keep only non-empty keys and values
        .filter(([key, value]) => key && value)
        // remove leading/trailing whitespace from keys and values
        .map(([key, value]) => [key.trim(), value.trim()])
        // convert value to boolean, integer, or leave as string
        .map(([key, value]) => {
        if (value.toLowerCase() === "true") {
            return [key, true];
        }
        if (value.toLowerCase() === "false") {
            return [key, false];
        }
        return [key, value];
    });
    return new Map(keyValuePairs);
}

/**
 * Parses a 'manifest' file's `bs_const` property into a map of key to boolean value.
 * @param manifest the internal representation of the 'manifest' file to extract `bs_const` from
 * @returns a map of key to boolean value representing the `bs_const` attribute, or an empty map if
 *          no `bs_const` attribute is found.
 */
function getBsConst(manifest) {
    if (!manifest.has("bs_const")) {
        return new Map();
    }
    let bsConstString = manifest.get("bs_const");
    if (typeof bsConstString !== "string") {
        throw new Error("Invalid bs_const right-hand side.  bs_const must be a string of ';'-separated 'key=value' pairs");
    }
    let keyValuePairs = bsConstString
        // for each key-value pair
        .split(";")
        // ignore empty key-value pairs
        .filter((keyValuePair) => !!keyValuePair)
        // separate keys and values
        .map((keyValuePair) => {
        let equals = keyValuePair.indexOf("=");
        if (equals === -1) {
            throw new Error(`No '=' detected for key ${keyValuePair}.  bs_const constants must be of the form 'key=value'.`);
        }
        return [keyValuePair.slice(0, equals), keyValuePair.slice(equals + 1)];
    })
        // remove leading/trailing whitespace from keys and values
        .map(([key, value]) => [key.trim(), value.trim()])
        // convert value to boolean or throw
        .map(([key, value]) => {
        if (value.toLowerCase() === "true") {
            return [key, true];
        }
        if (value.toLowerCase() === "false") {
            return [key, false];
        }
        throw new Error(`Invalid value for bs_const key '${key}'.  Values must be either 'true' or 'false'.`);
    });
    return new Map(keyValuePairs);
}

module.exports = {
    stringify,
    getManifest,
    getBsConst
}