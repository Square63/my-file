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
  $('#upload-input-file').fileupload
    dataType: 'text',

    maxChunkSize: 1 * 1024 * 1024,

    multipart: false,

    add: (e, data) ->
      data.headers or= {}
      data.headers['Session-Id'] = sessionId(data.files[0].name)
      data.submit();

    progress: (e, data) ->
      $element = $("#progress-bar")
      percent = data.loaded / data.total * 100
      width = percent * $element.width() / 100;
      $element.find('.bar').animate({ width: width }, 500).html(percent + "%&nbsp;")
