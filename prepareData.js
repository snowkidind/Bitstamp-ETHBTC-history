const crypto = require('crypto');

const file = require('./utils/file.js')
const files = __dirname + '/data'

// Load in historical bitstamp data and create sql files with it.
const enabled = false; // set this to true in order to execute. 

const addContents = async (filename, rand) => {
  const data = await file.readFile(files + '/' + filename)
  const entries = data.split('\n')
  let count = 0;
  const header = 'INSERT INTO price_index_history ("date", "f", "t", "open", "high", "low", "close", "volume") VALUES\n'
  let acc = header
  for (let i = 2, len = entries.length; i < len; i++) {
    count += 1;
    if (typeof entries[i] === 'undefined') continue
    const transform = entries[i].split(',')
    if (typeof transform[2] === 'undefined') continue
    const ft = transform[2].split('/')
    // build a giant string and send it
    acc += '( \'' + transform[1] + '\', \'' + ft[0] + '\', \'' + ft[1] + '\', \'' + transform[3] + '\', \'' + transform[4] + '\', \'' + transform[5] + '\', \'' + transform[6] + '\', \'' + transform[8] + '\'),\n'
    // send it every 1k lines
    if (count % 1000 === 0 || i === len - 1) {
      acc = acc.substring(0, acc.length - 2);
      acc += ';'
      await file.appendFile(files + '/price_' + rand + '.sql', acc)
      count = 0
      acc = header
    }
  }
}

const randomHex = (bytes) => {
  return new Promise(async (resolve) => {
    let hex = '';
    await crypto.randomBytes(bytes, function (err, buffer) {
      hex = buffer.toString('hex')
      resolve(hex)
    });
  });
}

;(async () => {
  try {
    const ls = await file.readDir(files)
    if (typeof ls === 'undefined') {
      return;
    }
    for (let i = 0; i < ls.length; i++) {
      console.log("adding: " + ls[i])
      const bytes = await randomHex(4)
      if (!enabled) {
        console.log('Cannot proceed, enabled is set to false.')
        process.exit(1)
      }
      await addContents(ls[i], bytes)
    }
  } catch (error) {
    console.log(error)
  }
  console.log('Process Completed')
  process.exit(0)
})()