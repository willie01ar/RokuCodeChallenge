// gulpfile.js/deploy.js

const { spawn }    = require('child_process');
const { getConfig }= require('./getConfig');
const constants    = require('./constants');

module.exports = async function deploy() {
  const { ipAddr } = await getConfig();
  const zipPath    = constants.zip.path;
  const url        = `http://${ipAddr}/plugin_install`;

  const args = [
    '--digest',
    '-u', 'rokudev:W2025',
    '-F', 'mysubmit=Install',
    '-F', `archive=@${zipPath}`,
    '--silent',                 // don’t show progress meter
    '--show-error',             // but do show error messages
    '--fail',                   // treat 4xx/5xx as errors (no body on stdout)
    '--connect-timeout', '5',   // give up if curl can’t connect in 5s
    '--max-time',        '30',  // give up entirely after 30s
    url
  ];

  return new Promise((resolve, reject) => {
    // spawn but silence all output:
    const c = spawn('curl', args, {
      stdio: ['ignore', 'ignore', 'pipe']  // ignore stdin/stdout, capture stderr
    });

    let errBuf = '';
    c.stderr.on('data', chunk => errBuf += chunk);

    c.on('error', err => {
      reject(err);
    });

    c.on('close', code => {
      if (code !== 0) {
        // include any curl-side error text if you like:
        return reject(new Error(
            `curl exited ${code}` + (errBuf ? `: ${errBuf.trim()}` : '')
        ));
      }
      // success! nothing was printed
      resolve();
    });
  });
};
