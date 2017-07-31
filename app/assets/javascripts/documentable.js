$(function() {
  $('input#document_attachment[type=file]').fileupload({

    add: function(e, data) {
      data.progressBar = $('<div class="progress-bar"><div class="loading-bar uploading"></div></div>').insertAfter("#progress-bar");
      var options = {
        extension: data.files[0].name.match(/(\.\w+)?$/)[0], // set extension
        _: Date.now(),                                       // prevent caching
      }
      documentable_params = $(this).closest('form').data('direct-documentable_params');
      direct_upload_url = $(this).closest('form').data('direct-upload-url') + '/cache/presing?' + documentable_params;
      console.log(direct_upload_url);
      $.getJSON(direct_upload_url, options, function(result) {
        data.formData = result['fields'];
        data.url = result['url'];
        data.paramName = 'file';
        data.submit();
      });
    },

    progress: function (e, data) {
      var progress = parseInt(data.loaded / data.total * 100, 10);
      $('.loading-bar').css(
        'width',
        progress + '%'
      );
    },

    done: function(e, data) {
      $('.loading-bar').removeClass('uploading');
      $('.loading-bar').addClass('complete');
      var image = {
        id: data.formData.key,
        storage: 'cache',
        metadata: {
          size:      data.files[0].size,
          filename:  data.files[0].name.match(/[^\/\\]*$/)[0], // IE returns full path
          mime_type: data.files[0].type
        }
      }
      $('#cached_attachment_data').val(JSON.stringify(image));
    }
  });
});
