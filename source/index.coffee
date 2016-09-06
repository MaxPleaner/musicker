window.logFn = (x) -> console.log x 

window.UI = (() ->
  
  this.MediaBackend = (() ->
    
    this.hostUrl = "https://li1196-141.members.linode.com/media-backend"
  
    this.setMediaBackendToken = () ->
      this.mediaBackendToken ||= $("#media-backend-token").attr("value")  
      this.tokenParam = "media_backend_token=#{this.mediaBackendToken}"
    
    this.getAudioList = () ->
      url = "#{hostUrl}/audio_index?"
      $.get(url)
    
    this.sendBlob = (blobObj) ->
      fd = new FormData()
      fd.append("fname", "#{blobObj.name}.wav")
      fd.append("data", blobObj.blob)
      url = "#{this.hostUrl}/rtc_audio_upload?#{this.tokenParam}"
      ajaxArgs =
        type: "POST"
        url: url
        data: fd
        processData: false
        contentType: false
      $.ajax(ajaxArgs)
      
    this.deleteAudio = (name) ->
      url = "#{hostUrl}/delete_audio?#{this.tokenParam}&name=#{name}"
      $.ajax(
        type: "DELETE",
        url: url
      )
      
    this
    
  )()
  
  this.DomEvents = (() ->
    
    this.audioContainer = () -> $("#audio-index")
    
    this.attachAudio = (name, url) ->
      template = """
        <div class='audio-section section'>
          <b class='name'>#{name}</b>
          <span class='delete-btn'>x</span>
          <span class='loop-btn'>start loop</span>
          <br>
          <audio class='section' controls>
            <source type='audio/wav' src='#{url}'>
            </source>
          </audio>
        </div>
      """
      $template = $ template
      this.audioContainer().append $template
      this.addDeleteBtnListener($template)
      this.addLoopBtnListener($template)
    
    this.addLoopBtnListener = ($template) ->
      $btn = $template.find(".loop-btn")
      $btn.off("click").on "click", (e) ->
        $btn = $(e.currentTarget)
        $audio = $btn.parents(".audio-section").find("audio")
        $btn.toggleClass("btn-on")
        if $btn.hasClass("btn-on")
          $btn.text("stop loop")
          $audio.attr("loop", true)
        else
          $btn.text("start loop")
          $audio.removeAttr("loop")

    this.addRecordClickListener = () ->
      $("#record").off("click").on "click", (e) ->
        $el = $(e.currentTarget)
        if $el.attr("recording") == "true"
          UI.DomEvents.recordingDone($el)
          $("#recording-status").text("")
        else
          UI.DomEvents.recordingStarted($el)
          $("#recording-status").text("Recording")
          
    this.addDeleteBtnListener = ($template) ->
      $template.find(".delete-btn").off("click").on "click", (e) ->
        if confirm("sure you want to delete?")
         $audioSection = $(e.currentTarget).parents(".audio-section")
         name = $audioSection.find(".name").text()
         UI.MediaBackend.deleteAudio(name).then (response) ->
           $audioSection.remove()

    this.recordingDone = ($el) ->
      $el.attr("recording", "false")
      UI.audioUtil.stopRecording().then (blobUrl) ->
        blobObj = UI.DomEvents.getBlob(blobUrl)
        if blobObj.blob && (blobObj.name.length > 0)
          UI.MediaBackend.sendBlob(blobObj).then (response) ->
            UI.DomEvents.attachAudio(blobObj.name, response["url"])

    this.recordingStarted = ($el) ->
      $el.attr("recording", "true")
      UI.audioUtil.startRecording()
      
        
    this.getBlob = (blobUrl) ->
      name = prompt("name for blob?")
      blob = window.RTC && RTC.getBlob()
      { blob: blob, name: name }

    this
    
  )() 

  this.audioUtil = (() ->
    
    this.startRecording = () ->
      mediaOpts = audio: true
      navigator.getUserMedia(mediaOpts, (stream) ->
        rtcOpts =
          mimeType: 'audio/ogg'
          bitsPerSecond: 128000
        window.RTC ||= RecordRTC(stream, rtcOpts)
        RTC.startRecording()
      , logFn)
      
    this.stopRecording = () ->
      new Promise (resolve, reject) ->
        RTC.stopRecording resolve
        
    this
    
  )()


  this.init = () ->
    $(".audio-section").hide()
    this.MediaBackend.setMediaBackendToken()
    this.DomEvents.addRecordClickListener()
    this.MediaBackend.getAudioList().then (response) ->
      response.forEach (audioRef) ->
        UI.DomEvents.attachAudio(audioRef.name, audioRef.url)

  this

)()