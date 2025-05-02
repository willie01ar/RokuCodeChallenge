// gulpfile.js/deploy.js
const fs            = require('fs');
const path          = require('path');
const FormData      = require('form-data');
const { fetch }     = require('undici');
const digest        = require('digest-header');
const { URL }       = require('url');
const { getConfig } = require('./getConfig');
const constants     = require('./constants');

module.exports = async function deploy() {
  const config = await getConfig();
  const url        = `http://${config.ipAddr}/plugin_install`;
  const uri        = new URL(url).pathname;        // "/plugin_install"
  const creds      = 'rokudev:W2025';

  const headRes = await fetch(url, { method: 'HEAD' });
  const wwwAuth = headRes.headers.get('www-authenticate');
  if (!wwwAuth) {
    throw new Error('Digest authentication challenge not found');
  }

  const form = new FormData();
  form.append('mysubmit', 'Install');
  form.append(
    'archive',
    fs.readFileSync(constants.zip.path),
    { filename: path.basename(constants.zip.path), contentType: 'application/zip' }
  );

  const bodyBuffer = form.getBuffer();
  const headers    = form.getHeaders();
  headers['Content-Length'] = bodyBuffer.length;
  headers['Authorization']  = digest('POST', uri, wwwAuth, creds);

  const response = await fetch(url, {
    method:  'POST',
    headers,
    body:     bodyBuffer
  });

  // let users running a paused profiling build know they'll need to manually resume capture
  if (config.bsProfEnable && config.bsProfSettings && config.bsProfSettings.bsProfPauseOnStart) {
      console.warn(c.yellow("Profiling is paused until manually resumed with the 'bsprof-resume' command on the port 8080 debug console."));
  }

  if (response.status !== 200) {
      let msg = `Deploy failed: (status code ${response.status}) ${response.statusText}`;
      console.error(c.bgRed.black(msg));
      const responseText = await response.text()

      if (responseText.toLowerCase().includes("compilation failed")) {
          console.warn(c.yellow("Compile error detected!"));
          console.warn( `Run \`${c.yellow(`npm run logs`)}\` or \`${c.yellow(`telnet ${config.ipAddr} 8085`)}\` to view erorr messages.`);
      }

      throw new Error(msg);
  }
};
