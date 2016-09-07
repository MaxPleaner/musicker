window.logFn = (x) -> console.log x 

window.UI = (() ->
  
  this.MediaBackend = (() ->
    
    this.hostUrl = "https://li1196-141.members.linode.com/media-backend"
  
    this.setMediaBackendToken = () ->
      this.mediaBackendToken ||= $("#media-backend-token").attr("value")  
      this.tokenParam = "media_backend_token=#{this.mediaBackendToken}"
    
    this.getAudioList = () ->
      url = "#{this.hostUrl}/audio_index?"
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
      url = "#{this.hostUrl}/delete_audio?#{this.tokenParam}&name=#{name}"
      $.ajax(
        type: "DELETE",
        url: url
      )
    
    this.trimAudio = (name, startTime, endTime) ->
      url = "#{this.hostUrl}/trim_audio?#{this.tokenParam}&name=#{name}&startTime=#{startTime}&endTime=#{endTime}"      
      $.ajax(
        type: "PUT",
        url: url
      ).then (response) -> response.url

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
          <span class="current-time"></span>
          <audio class='section' controls>
            <source type='audio/wav' src='#{url}'>
            </source>
          </audio> <br>
          <div class='slider-section'>
            <b> start time: </b> <span class="start-time-val"></span>
            <br>
            <input type="range" class="time-slider start-time" min="0" value="0" max='0' step="0.01">
          </div>
          <div class='slider-section'>
            <b> end time </b>: <span class="end-time-val"></span>
            <br>
            <input type="range" class="time-slider end-time" min="0" value="0" max='0' step="0.01">
          </div>
          <div class='slider-section'>
            <button class='save'>save</button>
          </div>
        </div>
      """
      $template = $ template
      this.audioContainer().append $template
      this.addDeleteBtnListener($template)
      this.addLoopBtnListener($template)
      this.addSliderListeners($template)
      this.setPlaybackBounds($template)
      this.addSaveListener($template)

    this.addSaveListener = ($template) ->
      $saveBtn = $template.find(".save")
      $saveBtn.off("click").on "click", (e) ->
        $btn = $(e.currentTarget)
        $audioSection = $btn.parents(".audio-section")
        startTime = $audioSection.find(".start-time-val").text()
        endTime = $audioSection.find(".end-time-val").text()
        name = $audioSection.find(".name").text()
        UI.MediaBackend.trimAudio(name, startTime, endTime).then (newUrl) ->
          $audioSection.find("audio source")[0].src = newUrl
          $audioSection.find("audio")[0].load()
      
    this.addSliderListeners = ($template) ->
      audio = $template.find("audio")[0]
      $(audio).off("canplaythrough").on "canplaythrough", (e) ->
        audio = e.currentTarget
        maxTime = audio.duration
        $.each $template.find(".time-slider"), (idx, el) ->
          $slider = $ el
          $slider.attr("max", maxTime)
        $template.find(".end-time").attr("value", maxTime)
        $startTime = $template.find(".start-time")
        $endTime = $template.find(".end-time")
        $startTime.off("change").on "change", (e) ->
          $slider = $(e.currentTarget)
          sliderVal = $slider.val()
          $audioSection = $slider.parents(".audio-section")
          $audio = $audioSection.find("audio")
          $audio.attr("start-time", sliderVal)
          $startTimeVal = $audioSection.find(".start-time-val")
          $startTimeVal.text(sliderVal)
        $endTime.off("change").on "change", (e) ->
          $slider = $(e.currentTarget)
          sliderVal = $slider.val()
          $audioSection = $slider.parents(".audio-section")
          $audio = $audioSection.find("audio")
          $audio.attr("end-time", $slider.val())
          $endTimeVal = $audioSection.find(".end-time-val")
          $endTimeVal.text(sliderVal)
        $endTime.trigger("change")
        $startTime.trigger("change")
          
    this.setPlaybackBounds = ($template) ->
      $audio = $template.find("audio")
      $audio.off("pause").on "pause", (e) ->
        $audio = $(e.currentTarget)
        $audio.off("timeupdate")
        
      $audio.off("play").on "play", (e) ->
        $audio = $(e.currentTarget)
        $audio.off("timeupdate").on "timeupdate", (e) ->
          audio = e.currentTarget
          $audio = $ audio
          startTime = Number audio.getAttribute("start-time")
          endTime = Number audio.getAttribute("end-time")
          timeElapsed = audio.currentTime          
          $audio.parents(".audio-section").find(".current-time").text(timeElapsed)
          if timeElapsed <  startTime
            audio.currentTime = endTime
          else if timeElapsed > endTime
            audio.currentTime = startTime
            unless $audio.attr("loop") == "loop"
              audio.pause()
          true
      
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
