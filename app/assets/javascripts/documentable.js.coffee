App.Documentable =

  initialize: ->
    console.log 'Documentable initialize'

    uploaders = $('.document-uploader')
    $.each uploaders, (index, uploader) ->
      App.Documentable.initialize_uploader(uploader)

  initialize_uploader: (uploader)->
    console.log 'Initializing uploader component'
    new (qq.FineUploader)(
      debug: true,
      element: uploader
      request: endpoint: '/attachments'
      deleteFile:
        enabled: true
        endpoint: '/attachments')
    return
