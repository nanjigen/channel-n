(define-module (channel-n packages japanese-xyz)
  #:use-module (ice-9 match)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix build-system)
  #:use-module (guix build-system python)
  #:use-module (gnu packages)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz))

(define-public python2-progressbar
  (package
    (name "python2-progressbar")
    (version "2.5")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "progressbar" version))
       (sha256
        (base32
         "0qvckfpkdk7a35r9lc201rkwc18grb4ddbv276sj7qm2km9cp0ax"))))
    (build-system python-build-system)
    (home-page "https://github.com/niltonvolpato/python-progressbar")
    (synopsis "Text progress bar library for Python")
    (description
     "A text progress bar is typically used to display the progress of a long
running operation, providing a visual cue that processing is underway.")
    ;; Either or both of these licenses may be selected.
    (license (list license:lgpl2.1+ license:bsd-3))))

python2-progressbar
