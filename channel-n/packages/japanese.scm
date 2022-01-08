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
  #:use-module (gnu packages)
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
                       ;; (delete 'configure)
                       ;; (add-before 'configure 'call-lrelease
                       ;;   (lambda _
                       ;;                              (invoke "lrelease"
                       ;;                                      "-project"
                       ;;                                      "goldendict.pro")
                       ;;                            #t))

                       ;; (add-after 'unpack 'patch-libiconv-libs
                       ;;   (lambda* (#:key inputs #:allow-other-keys)
                       ;;     (substitute* "goldendict.pro"
                       ;;       (("liconv")
                       ;;        "libiconv"))))
                       ;; (string-append "\"" (which "iconv") "\"")))
                       (replace 'configure
                                (lambda* (#:key inputs outputs #:allow-other-keys)
                                  (let ((iconv (assoc-ref inputs "libiconv")))
                                    ;; qmake needs to find lrelease
                                    (invoke "qmake"
                                            "CONFIG+=\"x86_64\""
                                            (string-append "PREFIX="
                                                           (assoc-ref outputs "out"))
                                            (string-append "LIBS+=-L" iconv "/lib")
                                            ;; linker issues during build for libiconv:
                                            ;; (string-append "LIBS+=-libiconv")
                                            ;; (string-append "QMAKE_LIBS=" iconv "/lib")
                                            "LIBS+=-liconv"
                                            "QMAKE_LRELEASE=lrelease"
                                            "goldendict.pro"))))
                       (replace 'build
                                (lambda* (#:key outputs #:allow-other-keys)
                                  (invoke "make")))
                       (replace 'install
                                (lambda* (#:key outputs #:allow-other-keys)
                                  (invoke "make" "install")))
                       ;; (add-after 'configure 'run-qmake
                       ;;            (lambda* (#:key outputs #:allow-other-keys)
                       ;;              (invoke "qmake")
                       ;;              #t))
                       )))
     (home-page "http://www.goldendict.org/")
     (synopsis "Goldendict: a feature-rich dictionary lookup program")
     (description
      "GoldenDict is a feature-rich dictionary lookup program, supporting multiple dictionary formats (StarDict/Babylon/Lingvo/Dictd/AARD/MDict/SDict) and online dictionaries, featuring perfect article rendering with the complete markup, illustrations and other content retained, and allowing you to type in words without any accents or correct case.")
     (license license:gpl3+))))

goldendict
