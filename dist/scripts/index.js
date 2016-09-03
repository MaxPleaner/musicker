(function() {
  window.UI = (function() {
    this.init = function() {
      $(".audio-section").hide();
      this.addRecordClickListener();
      return this.addSaveListener();
    };
    this.addRecordClickListener = function() {
      return $("#record").off("click").on("click", function(e) {
        var $el;
        $el = $(e.currentTarget);
        if ($el.attr("recording") === "true") {
          $el.attr("recording", "false");
          return UI.stopRecording();
        } else {
          $el.attr("recording", "true");
          record().then(processAudio)["catch"](processError);
          return $(".audio-section .save").hide();
        }
      });
    };
    this.addSaveListener = function() {
      return $(".save").off("submit").on("submit", function(e) {
        var $el, name;
        if (!window.RTC) {
          return;
        }
        $el = $(e.currentTarget);
        name = $el.find(".name").val();
        if (name.length < 1) {
          name = "musicker-download-" + (Date.now());
        }
        RTC.save(name);
        return false;
      });
    };
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
      this.RTC || (this.RTC = RecordRTC(stream, rtcOpts));
      return this.RTC.startRecording();
    };
    this.stopRecording = function() {
      if (!this.RTC) {
        return null;
      }
      return this.RTC.stopRecording(function(url) {
        return UI.attachAudio("#audio-src", url);
      });
    };
    this.attachAudio = function(selector, url) {
      return $.each($(selector), function(idx, el) {
        var $el;
        el.src = url;
        $el = $(el);
        $el.parent("audio")[0].load();
        return $el.parents(".audio-section").show().find(".save").show();
      });
    };
    this.processError = function(error) {
      return console.log(error);
    };
    return this;
  })();

}).call(this);
