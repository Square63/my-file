# We need a simple hashing function to turn the filename into a
# numeric value for the nginx session ID. See:
#
#   http://pmav.eu/stuff/javascript-hashing-functions/index.html
hash = (s, tableSize) ->
  b = 27183
  h = 0
  a = 31415

  for i in [0...s.length]
    h = (a * h + s[i].charCodeAt()) % tableSize
    a = ((a % tableSize) * (b % tableSize)) % (tableSize)
  h

sessionId = (filename) ->
  hash(filename, 16384)

$(document).ready ->
  $('#restore-archive').fileupload
    # nginx's upload module responds to these requests with a simple
    # byte range value (like "0-2097152/3892384590"), so we shouldn't
    # try to parse that response as the default JSON dataType
    dataType: 'text',

    # upload 8 MB at a time
    maxChunkSize: 1 * 1024 * 1024,

    # very importantly, the nginx upload module *does not allow*
    # resumable uploads for a Content-Type of "multipart/form-data"
    multipart: false,

    # add the Session-Id header to the request when the user adds the
    # file and we know its filename

    add: (e, data) ->
      data.headers or= {}
      console.log sessionId(data.files[0].name)
      data.headers['Session-Id'] = sessionId(data.files[0].name)
      data.submit();

    # update the progress bar on the page during upload
    progress: (e, data) ->
      console.log [data.loaded, data.total]
