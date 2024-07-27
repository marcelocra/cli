#!/usr/bin/env bb

(ns manager
  (:require
    [babashka.process :refer [process]]))

(-> (process "ls" "-la")
    (process {:out :string} "grep man")
    deref
    :out)

; -rwxrwxr-x   1 user user   184 jul 27 02:19 manager.clj
; -rwxrwxr-x   1 user user  4000 jul 26 16:21 manage.sh

