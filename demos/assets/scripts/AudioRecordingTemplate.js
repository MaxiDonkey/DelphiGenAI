(() => {

  /*
    audioRecordingTemplate
    ----------------------
    Browser-side microphone capture driven by the Delphi host.

    Inbound  (Delphi -> JS, via PostWebMessageAsJson, dispatched by "type"):
      { "type": "audio-recording-start"  }  -> begins capture
      { "type": "audio-recording-stop"   }  -> finalizes capture
      { "type": "audio-recording-switch" }  -> toggles capture (start if idle,
                                               stop if currently recording)

    Outbound (JS -> Delphi, via postMessage, dispatched by "event"):
      { "event": "audio-record", "data": "<base64>" }

    The audio is recorded with MediaRecorder using a natively supported,
    OpenAI-transcription-compatible container (webm/opus). The host decodes
    the base64 payload and persists it to a temporary file. Microphone
    permission is granted host-side (see DoPermissionRequested).
  */

  const MSG_RECORDING_START = "audio-recording-start";
  const MSG_RECORDING_STOP = "audio-recording-stop";
  const MSG_RECORDING_SWITCH = "audio-recording-switch";
  const RECORD_EVENT = "audio-record";

  /*--- Preference order: opus in a webm/ogg container. All entries are
        accepted by the OpenAI transcription endpoint and playable by
        DisplayAudioTemplate.js. */
  const PREFERRED_MIME_TYPES = [
    "audio/webm;codecs=opus",
    "audio/webm",
    "audio/ogg;codecs=opus",
    "audio/ogg"
  ];

  const state = {
    stream: null,
    recorder: null,
    chunks: [],
    recording: false,
    starting: false
  };

  function postToHost(eventName, payload) {
    if (!window.chrome || !window.chrome.webview) {
      return;
    }

    window.chrome.webview.postMessage(
      Object.assign({ event: eventName }, payload || {})
    );
  }

  function emitRecord(base64, error) {
    const payload = { data: base64 || "" };

    if (error) {
      payload.error = String(error);
    }

    postToHost(RECORD_EVENT, payload);
  }

  function setRecordingIndicator(active) {
    /*--- Reflect the live recorder state on the input-bubble microphone button
          (red + bold while recording). The function is exposed by
          InputBubbleTemplate; guard in case it is not present. */
    if (typeof window.setInputAudioRecording === "function") {
      window.setInputAudioRecording(!!active);
    }
  }

  function pickSupportedMimeType() {
    if (
      typeof MediaRecorder === "undefined" ||
      typeof MediaRecorder.isTypeSupported !== "function"
    ) {
      return "";
    }

    for (const candidate of PREFERRED_MIME_TYPES) {
      if (MediaRecorder.isTypeSupported(candidate)) {
        return candidate;
      }
    }

    return "";
  }

  function releaseStream() {
    if (state.stream) {
      state.stream.getTracks().forEach(function (track) {
        try {
          track.stop();
        } catch (e) {
        }
      });
    }

    state.stream = null;
    state.recorder = null;
    state.chunks = [];
    state.recording = false;
    state.starting = false;

    setRecordingIndicator(false);
  }

  function blobToBase64(blob) {
    return new Promise(function (resolve, reject) {
      const reader = new FileReader();

      reader.onerror = function () {
        reject(reader.error || new Error("FileReader failure"));
      };

      reader.onload = function () {
        /*--- readAsDataURL yields "data:<mime>;base64,<payload>"; keep the
              payload only, the host rebuilds the file from raw base64. */
        const result = String(reader.result || "");
        const comma = result.indexOf(",");
        resolve(comma >= 0 ? result.slice(comma + 1) : result);
      };

      reader.readAsDataURL(blob);
    });
  }

  async function startRecording() {
    /*--- Guard against re-entrancy while getUserMedia is still pending
          (the recording flag only flips once the stream is acquired). */
    if (state.recording || state.starting) {
      return;
    }

    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      emitRecord("", "getUserMedia is not available");
      return;
    }

    state.starting = true;

    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const mimeType = pickSupportedMimeType();
      const recorder = mimeType
        ? new MediaRecorder(stream, { mimeType: mimeType })
        : new MediaRecorder(stream);

      state.stream = stream;
      state.recorder = recorder;
      state.chunks = [];
      state.recording = true;
      state.starting = false;

      setRecordingIndicator(true);

      recorder.ondataavailable = function (event) {
        if (event.data && event.data.size > 0) {
          state.chunks.push(event.data);
        }
      };

      recorder.onstop = async function () {
        const type = recorder.mimeType || mimeType || "audio/webm";
        const blob = new Blob(state.chunks, { type: type });

        try {
          const base64 = await blobToBase64(blob);
          emitRecord(base64);
        } catch (e) {
          emitRecord("", e);
        } finally {
          releaseStream();
        }
      };

      recorder.start();
    } catch (e) {
      releaseStream();
      emitRecord("", e);
    }
  }

  function stopRecording() {
    if (!state.recording || !state.recorder) {
      return;
    }

    try {
      /*--- The encoded payload is emitted from the recorder "onstop" handler. */
      state.recorder.stop();
    } catch (e) {
      releaseStream();
      emitRecord("", e);
    }
  }

  function switchRecording() {
    /*--- Host-driven toggle: the host stays stateless and lets the browser
          decide based on the live recorder state. */
    if (state.recording || state.starting) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  window.chrome.webview.addEventListener("message", function (event) {
    const msg = event.data;

    if (!msg || typeof msg.type !== "string") {
      return;
    }

    if (msg.type === MSG_RECORDING_START) {
      startRecording();
      return;
    }

    if (msg.type === MSG_RECORDING_STOP) {
      stopRecording();
      return;
    }

    if (msg.type === MSG_RECORDING_SWITCH) {
      switchRecording();
      return;
    }
  });

})();
