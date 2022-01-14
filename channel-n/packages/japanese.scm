(define-module (channel-n packages japanese)
  #:use-module (ice-9 match)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix build-system)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system qt)
  #:use-module (guix build-system python)
  #:use-module (gnu packages)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages libreoffice)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages education)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages image)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages video)
  #:use-module (gnu packages xiph)
  #:use-module (gnu packages xorg)
  #:use-module (channel-n packages japanese-xyz)
  #:use-module (srfi srfi-1))

(define-public goldendict
  (let ((commit "0e888db8746766984a4422af9972de8753d4d6c4"))
    (package
     (name "goldendict")
     (version "2021-12-30")
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/goldendict/goldendict")
             (commit commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0fa1mrn8861gdlqq8a5w8wsylh56d8byj0p8zf025fa8s5n7ih7d"))))
     (build-system gnu-build-system)
     (inputs
      (list ao
            ffmpeg
            bzip2
            git
            hunspell
            libeb
            libtiff
            libvorbis
            libxtst
            libiconv
            lzo
            qtbase-5
            qtmultimedia
            qtsvg
            qtwebkit
            qtx11extras
            xz
            zlib))
     (native-inputs
      `(("pkg-config" ,pkg-config)
        ("qmake" ,qtbase-5)
        ;; ("liconv" ,libiconv)
        ;; ("glibc-utf8-locales" ,glibc-utf8-locales)
        ("qttools" ,qttools)))
     (arguments
      `(#:phases
        (modify-phases %standard-phases
                       (replace 'configure
                                (lambda* (#:key inputs outputs #:allow-other-keys)
                                  (let ((iconv (assoc-ref inputs "libiconv")))
                                    ;; qmake needs to find lrelease
                                    (invoke "qmake" "goldendict.pro"
                                            "CONFIG+=\"x86_64\""
                                            (string-append "PREFIX="
                                                           (assoc-ref outputs "out"))
                                            (string-append "LIBS+=-L" iconv "/lib")
                                            "LIBS+=-liconv"
                                            "QMAKE_LRELEASE=lrelease"))))
                       (replace 'build
                                (lambda* (#:key outputs #:allow-other-keys)
                                  (invoke "make")))
                       (replace 'install
                                (lambda* (#:key outputs #:allow-other-keys)
                                  (invoke "make" "install"))))))
     (home-page "http://www.goldendict.org/")
     (synopsis "Goldendict: a feature-rich dictionary lookup program")
     (description
      "GoldenDict is a feature-rich dictionary lookup program, supporting multiple dictionary formats (StarDict/Babylon/Lingvo/Dictd/AARD/MDict/SDict) and online dictionaries, featuring perfect article rendering with the complete markup, illustrations and other content retained, and allowing you to type in words without any accents or correct case.")
     (license license:gpl3+))))

goldendict

(define-public python-autosub
  (package
    (name "python-autosub")
    (version "0.3.12")
    (source (origin
              (method url-fetch)
              (uri (pypi-uri "autosub" version))
              (sha256
               (base32
                "01v0rkn8i2p8aqqnrrdhs8531zradydbgxd8mpdpdyjfgiybj6hj"))))
    (build-system python-build-system)
    (arguments
    `(#:tests? #f                             ;no "test" target
      #:python ,python-2))                    ;not compatible with Python 3
    (native-inputs
     `(("python2-progressbar" ,python2-progressbar)))
    ;; (native-inputs (list ffmpeg))
    (home-page "https://github.com/agermanidis/autosub")
    (synopsis "Auto-generated subtitles for any video")
    (description
     "Autosub is a utility for automatic speech recognition and subtitle generation. It takes a video or an audio file as input, performs voice activity detection to find speech regions, makes parallel requests to Google Web Speech API to generate transcriptions for those regions, (optionally) translates them to a different language, and finally saves the resulting subtitles to disk. It supports a variety of input and output languages (to see which, run the utility with the argument --list-languages) and can currently produce subtitles in either the SRT format or simple JSON.")
    (license license:x11)))

python-autosub
