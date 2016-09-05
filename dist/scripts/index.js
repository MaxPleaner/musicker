(function() {
  window.UI = (function() {
    this.setMediaBackendToken = function() {
      return this.mediaBackendToken = $("#media-backend-token").attr("value");
    };
    this.init = function() {
      $(".audio-section").hide();
      this.setMediaBackendToken();
      this.addRecordClickListener();
      return this.addSaveListener();
    };
    this.addSaveListener = function() {
      return $(".save").off("submit").on("submit", function(e) {
        var ajaxArgs, blob, fd, name;
        name = $(e.currentTarget).find("[name='name']").val() || "";
        blob = window.RTC && RTC.getBlob();
        if (blob && (name.length > 0)) {
          fd = new FormData();
          fd.append("fname", name + ".wav");
          fd.append("media_backend_token", UI.mediaBackendToken);
          fd.append("data", RTC.getBlob());
          ajaxArgs = {
            type: "POST",
            url: 'https://li1196-141.members.linode.com/media-backend/rtc_audio_upload',
            data: fd,
            processData: false,
            contentType: false
          };
          $.ajax(ajaxArgs).then(function(data) {
            return console.log(data);
          });
        }
        return false;
      });
    };
    this.addRecordClickListener = function() {
      return $("#record").off("click").on("click", function(e) {
        var $el;
        $el = $(e.currentTarget);
        if ($el.attr("recording") === "true") {
          $el.attr("recording", "false");
          return audioUtil.stopRecording();
        } else {
          $el.attr("recording", "true");
          audioUtil.record().then(audioUtil.processAudio);
          return $(".audio-section .save").hide();
        }
      });
    };
    this.attachAudio = function(selector, url) {
      return $.each($(selector), function(idx, el) {
        var $el;
        el.src = url;
        $(".save").attr("href", url).attr("download", url);
        $el = $(el);
        $el.parent("audio")[0].load();
        return $el.parents(".audio-section").show().find(".save").show();
      });
    };
    return this;
  })();

  window.audioUtil = (function() {
    this.record = function() {
      var mediaOpts;
      mediaOpts = {
        audio: true
      };
      return new Promise(function(resolve, reject) {
        return navigator.getUserMedia(mediaOpts, resolve, reject);
      });
    };
    this.processAudio = function(stream) {
      var rtcOpts;
      rtcOpts = {
        mimeType: 'audio/ogg',
        bitsPerSecond: 128000
      };
      window.RTC || (window.RTC = RecordRTC(stream, rtcOpts));
      return RTC.startRecording();
    };
    this.stopRecording = function() {
      if (!window.RTC) {
        return null;
      }
      return RTC.stopRecording(function(url) {
        return UI.attachAudio("#audio-src", url);
      });
    };
    return this;
  })();

}).call(this);
