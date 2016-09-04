window.UI = (() ->

  # UI.init is the only thing in this file that needs to be called
  this.init = () ->
    $(".audio-section").hide()
    this.addRecordClickListener()
    this.addSaveListener()
  
  this.addSaveListener = () ->
    $(".save").off("submit").on "submit", (e) ->
      name = $(e.currentTarget).find("[name='name']").val() || ""
      blob = window.RTC && RTC.getBlob()
      if blob && (name.length > 0)
        fd = new FormData()
        fd.append("fname", "#{name}.wav")
        fd.append("data", RTC.getBlob())
        ajaxArgs =
          type: "POST"
          url: 'http://localhost:4567/rtc_audio_upload'
          data: fd,
          processData: false,
          contentType: false
        $.ajax(ajaxArgs).then (data) -> console.log(data)
      false

  this.addRecordClickListener = () ->
    $("#record").off("click").on "click", (e) ->
      $el = $(e.currentTarget)
      if $el.attr("recording") == "true"
        $el.attr("recording", "false")
        audioUtil.stopRecording()
      else
        $el.attr("recording", "true")
        audioUtil.record().then(audioUtil.processAudio)
        $(".audio-section .save").hide()
      
  this.attachAudio = (selector, url) ->
    $.each $(selector), (idx, el) ->
      el.src = url
      $(".save").attr("href", url).attr("download", url)
      $el = $(el)
      $el.parent("audio")[0].load()
      $el.parents(".audio-section").show().find(".save").show()
  this
  
)()

window.audioUtil = (() ->

  this.record = () ->
    mediaOpts = audio: true
    return new Promise (resolve, reject) ->
      navigator.getUserMedia(mediaOpts, resolve, reject)

  this.processAudio = (stream) ->
    rtcOpts =
      mimeType: 'audio/ogg'
      bitsPerSecond: 128000
    window.RTC ||= RecordRTC(stream, rtcOpts)
    RTC.startRecording()
  
  this.stopRecording = () ->
    return null unless window.RTC
    RTC.stopRecording (url) ->
      UI.attachAudio("#audio-src", url)
  this
)()
