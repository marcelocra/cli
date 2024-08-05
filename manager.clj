#!/usr/bin/env bb

(ns manager
  (:require
    [babashka.process :refer [process shell]]
    [clojure.string :as s]))

(defn npm-install
  [{:keys [dev packages] :or {dev true} :as opts}]
  (-> (process {:out :string}
        "npm"
        "install"
        (if dev "--save-dev" "--save")
        (if (string? packages) packages (s/join " " packages)))
      deref
      :out))


(comment
  (-> (shell {:out :string
              :dir "/home/marcelocra/projects"} "pwd")
      :out
      )

  ;; Run a simple command.
  (-> (process "ls" "-la")
      (process {:out :string} "grep man")
      deref
      :out)

  ; -rwxrwxr-x   1 user user   184 jul 27 02:19 manager.clj
  ; -rwxrwxr-x   1 user user  4000 jul 26 16:21 manage.sh

  ;; playground
  )
