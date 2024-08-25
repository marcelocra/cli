#!/usr/bin/env bb

(ns new-create-all
  (:require
    [babashka.fs :as fs]
    [clojure.string :as s]))

(def templates-for-new-projects [".gitattributes"
                                 ".gitignore"
                                 ".editorconfig"
                                 "CHANGELOG.md"
                                 "LICENSE.txt"
                                 "tsconfig.json"
                                 "package.json"])

(def files
  (let [{existing-files true
         new-files false} (group-by fs/exists? templates-for-new-projects)]
    {:existing existing-files
     :new new-files}))

(def prefix "\n  - ")

(if (:new files)
  (println (format "Files that exists in the current folder (%s):\n%s%s" (fs/cwd) prefix (s/join prefix (:new files))))
  nil)


(->> files
    :existing
    (map #(println (str  "File exists: '" % "'. Ignoring. If you want to overwrite, remove it first."))))




(comment

  (->>
    (filter #(if (fs/exists? %)
               (println "File exists... ignoring. Remove and try again.")
               (println "new file" %))))

  (comment fs/copy (fs/path *command-line-args* %) %)

  (System/exit 0)

  (babashka.fs/cwd)

  ; cp "$templates_dir/$template" "$template"
  )
