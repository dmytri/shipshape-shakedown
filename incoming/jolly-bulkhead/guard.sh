    # Result-set custody, not mention custody. The notecheck above guards a
    # command that NAMES the notes; a routine search that names neither the
    # file nor any token still reads its content. The .ignore artifact covers
    # ripgrep and ag TRAVERSAL only, so deny the vectors that escape it and
    # leave the covered forms alone: GNU grep never reads .ignore at all, an
    # rg ignore-override flag outranks it, and a shell glob in the path list
    # expands to explicit paths that no ignore file can exclude.
    searchfault=$(printf '%s' "$norm" | awk '{
      for (i = 1; i <= NF; i++) {
        t = $i
        sub(/^["'\'']/, "", t); sub(/["'\'']+$/, "", t)
        if (t != "grep" && t !~ /\/grep$/ && t != "egrep" && t != "fgrep" &&
            t != "rg" && t !~ /\/rg$/ && t != "ag" && t != "ack") continue
        isgrep = (t ~ /grep$/)
        rec = 0; ovr = 0; glb = 0
        for (j = i + 1; j <= NF; j++) {
          a = $j
          if (a ~ /^[;&|]/) break
          sub(/^["'\'']/, "", a); sub(/["'\'']+$/, "", a)
          if (a !~ /^--/ && a ~ /^-[a-zA-Z]*[rR]/) rec = 1
          if (a == "--recursive" || a == "--dereference-recursive") rec = 1
          if (a == "-g" || a == "--glob" || a == "--no-ignore" ||
              a == "--no-ignore-vcs" || a == "-u" || a == "--unrestricted") ovr = 1
          if (a !~ /^-/ && a ~ /[*?[]/) glb = 1
        }
        if (isgrep && rec) { print "recursive grep, which never reads the ignore artifact"; exit }
        if (!isgrep && ovr) { print "an ignore-override flag, which outranks the ignore artifact"; exit }
        if (glb) { print "a shell glob in the path list, which expands to explicit paths the ignore artifact cannot exclude"; exit }
      }
    }')
    if [ -n "$searchfault" ]; then
      deny "That search can surface the Captain-only notes through $searchfault. Use \`rg <pattern>\`, \`rg -t md <pattern>\`, or \`rg --hidden <pattern>\`, which honour the ignore artifact."
    fi
