(define-module (channel-n packages fcitx5-mozc-ut)
  ;; #:use-module (ice-9 match)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix licenses)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  ;; #:use-module (guix utils)
  #:use-module (gnu packages fcitx5)
  ;; #:use-module (gnu packages gtk)
  #:use-module (gnu packages ninja)
  ;; #:use-module (gnu packages ocr)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages protobuf)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages qt)
  #:use-module (channel-n packages)
  #:use-module (channel-n packages channel-n-xyz)
  #:use-module (guix git-download)
  #:use-module (guix build-system python)
  ;; #:export (python-gyp-latest)
  ;; #:use-module (srfi srfi-1)
  )

(define-public fcitx5-mozc-ut
  (package
    (name "fcitx5-mozc-ut")
    (version "2.26.4520.102")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/fcitx/mozc")
                    (commit "1485c1f60ae444f62a304b252ee384d10f06e614")))
              (sha256
               (base32 "0xzjfrn0m8mc6k8vrggrf50x0ssbb9yq9c5qnval8gk8v78rpyl5"))))
    (build-system python-build-system)
    (arguments
     `(#:use-setuptools? #f
       #:tests? #f
       #:phases
       (modify-phases %standard-phases
    ;;      ;; (add-after 'unpack 'symlink
    ;;      ;;   (lambda* (#:key inputs #:allow-other-keys)
    ;;      ;;     (let ((gyp (assoc-ref inputs "python-gyp")))
    ;;      ;;       (rmdir "src/third_party/gyp/")
    ;;      ;;       (symlink gyp "src/third_party/gyp"))))
         (replace 'configure
           (lambda* (#:key inputs ouputs #:allow-other-keys)
             (let ((gyp (assoc-ref inputs "python-gyp-latest")))
               ;; (chdir "src")
               ;; (setenv (string-append "GYP_DEFINES=" "\""
               ;;                        "document_dir=" (assoc-ref ouputs "outs") "/share/doc/mozc"
               ;;                        "use_libzinnia=1"
               ;;                        "use_libprotobuf=1"
               ;;                        "use_libabseil=1"
               ;;                        "\""))
               (invoke "python" "build_mozc.py" "gyp"
                       (string-append "--gypdir=" gyp "/bin")
                       (string-append "--server_dir="
                                      (assoc-ref ouputs "outs") "/lib/mozc")
                       "--target_platform=Linux")
               )))
    ;;      (replace 'build
    ;;        (lambda* (#:key outputs #:allow-other-keys)
    ;;          (invoke "python" "build_mozc.py" "build" "-c" "Release"
    ;;                  "server/server.gyp:mozc_server"
    ;;                  "gui/gui.gyp:mozc_tool"
    ;;                  "unix/fcitx5/fcitx5.gyp:fcitx5-mozc")))
    ;;      ;; (delete 'check)
    ;;      ;; (replace 'install
    ;;      ;;   (lambda* (#:key outputs #:allow-other-keys)
    ;;      ;;     (add-installed-pythonpath inputs outputs)
    ;;      ;;     (setenv (string-append "PREFIX=" (assoc-ref outputs "out")))
    ;;      ;;     (setenv "_bldtype=Release")
    ;;      ;;     (invoke "scripts/install_server")
    ;;      ;;     (invoke "install" "-d"
    ;;      ;;             (string-append (assoc-ref outputs "out")
    ;;      ;;                            "/share/licenses/fcitx5-mozc"))))
         )))
    (inputs
     `(("python-gyp" ,python-gyp-latest)))
    (propagated-inputs
     `(("six" ,python-six)))
    (native-inputs
     `(("python" ,python)
       ("qtbase" ,qtbase-5)
       ("ninja" ,ninja)
       ("fcitx5" ,fcitx5)
       ("pkg-config" ,pkg-config)))
    (synopsis "A Japanese Input Method Editor designed for multi-platform")
    (description
     "Mozc is a Japanese Input Method Editor (IME) designed for multi-platform
 such as Android OS, Apple OS X, Chromium OS, GNU/Linux and Microsoft Windows.
 This OpenSource project originates from Google Japanese Input.")
    (home-page "https://github.com/google/mozc")
    (license bsd-3)))
fcitx5-mozc-ut
