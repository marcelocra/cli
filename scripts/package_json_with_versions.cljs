#!/usr/bin/env nbb
(ns package-json-with-versions
  (:require ["path" :as path]
            ["fs" :as fs]
            [clojure.string :as s]))

(def root-folder (path/dirname (path/dirname *file*)))
(def cli-folder (path/basename root-folder))

(if (not= cli-folder "cli")
  (do
    (println "Running from the wrong folder.")
    (js/process.exit 1))
  (println "Copying versions from `pnpm-workspace.yaml` to `package.json` and saving in `<cwd>/package.json`..."))

(def templates-folder (path/resolve root-folder "templates"))
(def package-json-without-versions
  (js->clj (js/JSON.parse (fs/readFileSync (path/resolve templates-folder "package.json")))))
(def pnpm-workspace-with-versions
  (-> (fs/readFileSync (path/resolve templates-folder "pnpm-workspace.yaml"))
      (.toString)
      #_(s/split "\n")))


(s/split pnpm-workspace-with-versions "\n")
