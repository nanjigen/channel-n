(define-module (channel-n packages japanese-xyz)
  #:use-module (ice-9 match)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix build-system)
  #:use-module (guix build-system python)
  #:use-module (gnu packages)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-xyz))


(define-public python-gyp-patch
  (let ((commit "d6c5dd51dc3a60bf4ff32a5256713690a1a10376")
        (revision "0"))
    (package
      (name "python-gyp")
      ;; Google does not release versions,
      ;; based on second most recent commit date.
      (version (git-version "0.0.0" revision commit))
      (source
       (origin
         ;; Google does not release tarballs,
         ;; git checkout is needed.
         (method git-fetch)
         (uri (git-reference
               (url "https://chromium.googlesource.com/external/gyp")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "0mphj2nb5660mh4cxv51ivjykzqjrqjrwsz8hpp9sw7c8yrw4qi1"))))
      (build-system python-build-system)
      (home-page "https://gyp.gsrc.io/")
      (synopsis "GYP is a Meta-Build system")
      (description
       "GYP builds build systems for large, cross platform applications.
It can be used to generate XCode projects, Visual Studio projects, Ninja build
files, and Makefiles.")
      (license license:bsd-3))))

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

;; python2-progressbar
python-gyp-patch
