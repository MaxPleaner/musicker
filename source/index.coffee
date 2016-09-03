
window.UI = (() ->

  this.init = () ->
    $(".audio-section").hide()
    this.addRecordClickListener()
    this.addSaveListener()
  
  this.addRecordClickListener = () ->
    $("#record").off("click").on "click", (e) ->
      $el = $(e.currentTarget)
      if $el.attr("recording") == "true"
        $el.attr("recording", "false")
        UI.stopRecording()
      else
        $el.attr("recording", "true")
        record().then(processAudio).catch(processError)
        $(".audio-section .save").hide()
  
  this.addSaveListener = () ->
    $(".save").off("submit").on "submit", (e) ->
      return unless window.RTC
      $el = $(e.currentTarget)
      name = $el.find(".name").val()
      if name.length < 1
        name = "musicker-download-#{Date.now()}"
      RTC.save(name)
      false
      
  this.record = () ->
    mediaOpts = audio: true
    return new Promise (resolve, reject) ->
      navigator.getUserMedia(mediaOpts, resolve, reject)

  this.processAudio = (stream) ->
    rtcOpts =
      mimeType: 'audio/ogg'
      bitsPerSecond: 128000
    this.RTC ||= RecordRTC(stream, rtcOpts)
    this.RTC.startRecording()
  
  this.stopRecording = () ->
    return null unless this.RTC
    this.RTC.stopRecording (url) ->
      UI.attachAudio("#audio-src", url)

  this.attachAudio = (selector, url) ->
    $.each $(selector), (idx, el) ->
      el.src = url
      $el = $(el)
      $el.parent("audio")[0].load()
      $el.parents(".audio-section").show().find(".save").show()

  this.processError = (error) ->
    console.log(error)
  
  this
)()
