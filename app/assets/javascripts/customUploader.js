/*
 * This is a very customized implementation of the jQuery File Upload plugin 
 * configured to work with nginx.
 */

$(function() {
  var calculateProgress, cancelAllUploads, cancelUpload, createProgressBar, 
  fileName, files, maxChunkSize, startAllUploads, startUpload, uploadedFilePath;

  // A container to hold all of the upload data objects.
  files = {};

  /*
   * A simple method to calculate the progress for an individual file upload.
   */
  calculateProgress = function(data) {
    var value;
    value = parseInt(data.loaded / data.total * 100, 10) || 0;
    return value;
  };

  /*
   * Get the name of the file from the upload data.
   */
  fileName = function(data) {
    return data.files[0].name;
  };

  fileType = function(data) {
    return data.files[0].type;
  };

  fileSize = function(data) {
    return data.files[0].size;
  };

  /*
   * Returns the path to the uploaded file on the server. 
   */
  uploadedFilePath = function(data) {
    var response;
    response = JSON.parse(data.result);
    return response["url"];
  };

  /*
   * Cancels the upload for a file found at 'index' in the 'files' container.
   */
  cancelUpload = function(index) {
    if (files[index]) {
      files[index].abort();
    }
  };

  /*
   * Starts the upload for a file found at 'index' in the 'files' container.
   * If the file upload was interrupted, the 'uploadedBytes' attribute will be
   * reset to continue from where it left off.
   */
  startUpload = function(index) {
    var context, data;
    data = files[index];
    context = data.context;
    data.uploadedBytes = parseInt($(context).attr("uploadedBytes"), 10);
    data.data = null;
    $(data).submit();
  };

  cancelAllUploads = function() {
    $(files).each(function(index, file) {
      cancelUpload(index);
    });
  };

  startAllUploads = function() {
    $(files).each(function(index, data) {
      startUpload(index);
    });
  };

  createProgressBar = function(progress) {
    return '<div class="progress-bar progress-bar-striped active progress-bar-success" role="progressbar" aria-valuenow="' + progress + '" aria-valuemin="0" aria-valuemax="100" style="width: ' + progress + '%"><span class="sr-only">' + progress + '% Complete</span></div>';
  };

  humanFileSize = function(size) {
    var i = Math.floor( Math.log(size) / Math.log(1024) );
    return ( size / Math.pow(1024, i) ).toFixed(2) * 1 + ' ' + ['Bytes', 'KB', 'MB', 'GB', 'TB'][i];
  };

  /*
   * IMPORTANT: There are some very important settings to mention:
   *
   * maxChunkSize:
   * Nginx and this plugin require a very specific setting for chunk sizes. 
   * Changing this may affect the performance and reliability of your upload. 
   *
   * For a more in-depth explanation of the settings or the benchmarks performed
   * to get this setting, read this document: https://gist.github.com/3920385.
   *
   * multipart:
   * This must be set to 'false'. If set to 'true', then the upload will send
   * in a single chunk, rather than multiple chunks.
   *
   * dataType:
   * This cannot be set for chunked uploads! Setting this option to 'json' 
   * resulted in failed chunked uploads. 
   *
   */
  $("#fileupload").fileupload({
    maxChunkSize: 1024 * 256,
    maxRetries: 5,
    retryTimeout: 10000,
    multipart: false,
    add: function(e, data) {
      // Collect some basic information about the file.
      var progress = calculateProgress(data);
      var filename = fileName(data);
      var filetype = fileType(data);
      var filesize = fileSize(data);

      // A count of the number of rows (current file uploads)
      var sessionID = new Date().getTime() + '_' 
        + $.base64.encode(filename).replace(/\+|=|\//g, '');

      var index = sessionID;

      // Create a start and stop button for this specific upload. The 'data-file' 
      // attribute is used to pass the index of this upload to the cancelUpload
      // and startUpload methods.
      var cancelButton = $('<a href="#" class="delete" type="button" data-file="' + index + '"><span class="glyphicon glyphicon-remove item-delete"></span></a>');
      var startButton = $('<button type="button" data-file="' + index + '">Start</button>');

      // Cancel this specific upload when this button is clicked
      cancelButton.click(function() {
        item = $(this).parents(".item");
        item.addClass("cancelled");
        cancelUpload($(this).attr("data-file"));
        item.fadeOut(function() {
          $(this).remove();
        });
        return false;
      });

      // Start/Resume this specific upload when this button is clicked
      startButton.click(function() {
        startUpload($(this).attr("data-file"));
      });

      // Create a new, empty row that will serve as the context for this file
      // upload.
      var row = $("#data-container .item").clone();

      // nginx requires us to specify a session id so that it can handle chunked
      // uploads. Here, we're using the current time and the file's encoded name 
      // to generate this token.
      //
      // Note: This will require you to use the jQuery base64 plugin.

      // Set all the information for this upload on the context (row) for easier
      // access
      $(row).find(".type").text(filetype);
      $(row).find(".name").text(filename);
      $(row).find(".progress").html(createProgressBar(progress));
      $(row).find(".start").append(startButton);
      $(row).find(".item-controls").html(cancelButton);
      $(row).attr("sessionID", sessionID);

      // Add the new file upload row to our list (table) of file uploads
      $(row).appendTo("#items");

      // Assign this row to this upload's context
      data.context = row;

      // Add this upload data to our files container
      files[index] = data;

      startUpload(index);
    },

    /* 
     * Do something when the upload is done. This example replaces the progress
     * bar we've been using with the path to the uploaded file on the server.
     */
    done: function(e, data) {
      file = $(data.result)
      data.context.replaceWith(file);
      MyFile.apply_js_item(file);

    },

    /*
     * This method is called whenever progress is reported back from nginx.
     * Here, we're simply updating our progress bar to show the current progress.
     * We're also clearing out any previous retry attempts once progress has
     * been made.
     */
    progress: function(e, data) {
      var progress;
      data.context.removeData("retries");
      progress = calculateProgress(data);
      data.context.find(".progress").html(createProgressBar(progress));
    },
    
    /*
     * This callback keeps track of the combined progress for all active uploads.
     */
    progressall: function (e, data) {
      var progress = calculateProgress(data);
      $("#total_progress").text(progress);
    },


    /*
     * This method prepares the chunk that is about to be uploaded.
     */
    beforeSend: function(e, files, index, xhr, handler, callback) {
      var chrome, context, device, file, filename, filesize, ios, sessionID;

      // Retrieve the file that is about to be sent to nginx
      file = files.files[0];

      // Collect some basic file information
      filename = file.name;
      filesize = file.size;

      // Grab the context (table row) for this upload
      context = files.context[0];

      // Get the generated sessionID for this upload
      sessionID = $(context).attr("sessionID");

      // Set uploadedBytes on the context to ensure that if this upload was
      // resumed, it will continue from where it left off.
      $(context).attr("uploadedBytes", files.uploadedBytes);

      // Set the required headers for the nginx upload module
      e.setRequestHeader("Session-ID", sessionID);
      e.setRequestHeader("X-Requested-With", "XMLHttpRequest");

      device = navigator.userAgent.toLowerCase();
      ios = device.match(/(iphone|ipod|ipad)/);
      chrome = device.match(/crios/);

      if (ios && !chrome) {
        e.setRequestHeader("Cache-Control", "no-cache");
      }
    },

    /*
     * This method will be called whenever an upload (or a single chunk) fails
     * to complete. In this case, we're setting up an auto-resume feature to
     * attempt the upload again (respecting our retry and timeout settings).
     */
    fail: function(e, data) {
      var maxRetries, retryCount, retryTimeout, row;
      
      // Get the context for this upload
      row = $(data.context[0]);

      if(row.hasClass("cancelled"))
        return;

      // Grab its current retry count
      retryCount = row.data("retries") || 1;

      // Get our maxRetries and retryTimeout settings
      maxRetries = $(this).data("blueimpFileupload").options.maxRetries + 1;
      retryTimeout = $(this).data("blueimpFileupload").options.retryTimeout;

      // If we can still attempt a retry
      if (retryCount < maxRetries) {
        window.setTimeout(function() {
          // Set the row's progress bar section to display that we are trying again
          row.find(".progress").html("<label>Retry #" + retryCount + "</label>");

          // Increment the retry count and set it back on the row
          row.data("retries", retryCount += 1);

          // Reassign the uploadedBytes, then submit to start the upload again.
          data.uploadedBytes = parseInt(row.attr("uploadedBytes"), 10);
          data.data = null;
          $(data).submit();
        }, retryCount * retryTimeout);

      } else {
        // We've met our retry limit. Indicate that this upload has failed.
        row.find(".progress").html("<label>Upload failed</label>");
      }
    }
  });

  /*
   * A convenient method for triggering the upload of multiple files from the 
   * click of a button.
   */
  $("#start_upload").click(function() {
    startAllUploads();
  });

  /*
   * A convenient method for triggering the cancellation of multiple files from 
   * the click of a button.
   */
  $("#stop_uploads").click(function() {
    cancelAllUploads();
  });
});

