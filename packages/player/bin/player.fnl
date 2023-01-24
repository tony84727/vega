(local s (peripheral.find "speaker"))
(local buffer-size (* 16 1024))

(let [args [...]
      dfpwm (require "cc.audio.dfpwm")
      decoder (dfpwm.make_decoder)
      url (.. "https://vega.catcatlog.com/music/" (. args 1))
      response (http.get url [] true)
]
  (if (= nil response)
      (print "failed to download file")
      (do
	(var buffer (response.read buffer-size))
	(while (not (= nil buffer))
	  (let [samples (decoder buffer)]
	    (while (not (s.playAudio samples))
		(os.pullEvent "speaker_audio_empty")
            )
	    (set buffer (response.read buffer-size)))))))
