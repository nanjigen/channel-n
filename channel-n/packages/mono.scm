(define-module (channel-n packages mono)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages python)
  #:use-module (gnu packages mono)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages xml)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix download))

(define-public mono-6.4
    (package
    (inherit mono)
    (version "6.12.0.122")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://download.mono-project.com/sources/mono/mono"
                    "-" version
                    ".tar.xz"))
              (sha256
               (base32 "08wxv236kgl1qwpxmzndliq96z05qpwcpqdf0wqm3ry51xk7ghi9"))
              ;; (patches (search-patches "mono-mdoc-timestamping.patch"))
              ))
    (inputs
     (list cmake git which))
    (native-inputs
     `(("gettext" ,gettext-minimal)
       ("glib" ,glib)
       ("libxslt" ,libxslt)
       ("perl" ,perl)
       ("python" ,python)))
    (arguments
     '(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (delete 'fix-includes))))
    ))
