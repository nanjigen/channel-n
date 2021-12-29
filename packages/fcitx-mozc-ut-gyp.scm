(define-module (gnu packages fcitx5-mozc-ut-gyp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages ninja)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
  #:use-module (guix git-download)
  #:use-module (guix build-system python))

(define-public mozc
  ;; (let ((commit "d0d8a87c1ef19b7bd1d2c040e4ef38951b07fbd0")))
  (package
   (name "mozc")
   (version "2.26.4520.102")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/google/mozc")
                  (commit "d0d8a87c1ef19b7bd1d2c040e4ef38951b07fbd0")))
            (sha256
             (base32 "0xzjfrn0m8mc6k8vrggrf50x0ssbb9yq9c5qnval8gk8v78rpyl5"))))
   ;; (file-name (git-file-name name version))
   (build-system python-build-system)
   (arguments
    `(#:use-setuptools? #f
      #:configure-flags
      #~(list (string-append "--with-gypdir="))
      #:phases
      (modify-phases %standard-phases
          (replace 'build 'bootstrap
            (lambda _
          ;;     ;; (substitute* "setup.py" (("build_mozc.py") ""))
            ;; (let* ())
             (with-directory-excursion "src"
              (invoke "python" "build_mozc.py" "gyp" (string-append "--gypdir=" (getenv "PYTHONPATH"))))
              ;; (invoke "python" "build_mozc.py" "gyp" "--gypdir=/gnu/store/x1d86yblmfx3545rwlkl84qjynw56ksd-python-gyp-0.0.0-0.5e2b3dd/bin" "--target_platform=Linux"))
              #t))
          (replace 'install
                      (lambda _
             (with-directory-excursion "src"
                        (invoke "python" "build_mozc.py" "build" "-c" "Release"
                                "server/server.gyp:mozc_server"
                                "gui/gui.gyp:mozc_tool"
                                "unix/fcitx5/fcitx5.gyp:fcitx5-mozc"))
               ;; (setenv "HOME" (getcwd))
                        #t))
          )))
  (inputs
   `(("qtbase" ,qtbase-5)))
  (propagated-inputs
   `(("python-six" ,python-six)))
  (native-inputs
   `(("python-gyp" ,python-gyp)
     ("python" ,python)
     ("ninja" ,ninja)
     ("pkg-config" ,pkg-config)))
  (synopsis "A Japanese Input Method Editor designed for multi-platform")
  (description
   "Mozc is a Japanese Input Method Editor (IME) designed for multi-platform such as Android OS, Apple OS X, Chromium OS, GNU/Linux and Microsoft Windows. This OpenSource project originates from Google Japanese Input.")
  (home-page "https://github.com/google/mozc")
  (license bsd-3)))
mozc
