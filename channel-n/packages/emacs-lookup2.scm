(define-module (channel-n packages emacs-lookup2)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system emacs)
  #:use-module (gnu packages)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (guix utils)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match))

(define-public emacs-lookup2
  ;; From July 25, 2020
  ;; No releases available
  (let ((commit "06f827d92d59cf679e7340247d9eeaa23ec0ffe5")
        (revision "0"))
    (package
     (name "emacs-lookup2")
     (version (git-version "1.99.0" revision commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/lookup2/lookup2")
             (commit commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "19xbpsdvapvffpnmhdkxa74159dfc2r2d1s0nyb9b3armqzkahpj"))))
     (build-system gnu-build-system)
     (native-inputs `(("makeinfo" ,texinfo)
                      ("automake" ,automake)
                      ("autoconf" ,autoconf)
                      ("emacs" ,emacs)))
     (arguments
      (list
       #:modules '((guix build gnu-build-system)
                   ((guix build emacs-build-system) #:prefix emacs:)
                   (guix build utils)
                   (guix build emacs-utils))
       #:imported-modules `(,@%gnu-build-system-modules
                            (guix build emacs-build-system)
                            (guix build emacs-utils))
       #:configure-flags
       #~(list "--with-emacs=emacs"
               (string-append "--with-lispdir=" (emacs:elpa-directory #$output))
               (string-append "--infodir="
                              #$output "/share/info"))
       #:tests? #f                       ; no check target
       #:phases
       #~(modify-phases %standard-phases
                        ;; (delete 'unpack)
                        (add-after 'unpack 'autoreconf
                                   (lambda _
                                     (invoke "autoreconf" "-i"))))
       ;;                (add-after 'build 'build-lookup
       ;;                           (lambda* (#:key outputs #:allow-other-keys)
       ;;                             (invoke "make" "install"))))
       ))
     (home-page "https://lookup2.github.io/")
     (synopsis "Lookup2 package for emacs")
     (description
      "Lookup is an integrated user interface for various dictionaries. You can search various on-line and off-line dictionaries simultaneously with lookup.")
     (license license:gpl2+))))

emacs-lookup2
