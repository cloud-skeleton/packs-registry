[[- define "extra_pack_meta" -]]
[[- $max_var_name_length := 0 -]]
[[- range $name, $_ := vars . -]]
[[- $max_var_name_length = max $max_var_name_length (len $name) -]]
[[- end ]]
        // Nomad pack source URL
        [[ printf "\"pack.src\" = \"%v\"" (meta "app.url" .) ]]

        // Nomad pack variables used during deployment
[[- range $name, $value := vars . ]]
        [[ printf "\"pack.vars.%s\"%*s= \"%v\"" $name (add 1 (sub $max_var_name_length (len $name))) "" $value -]]
[[- end -]]
[[- end -]]

[[- define "job_name" -]]
[[- $root := index . 0 -]]
[[- $name  := index . 1 -]]
[[ printf "%s-%s-%s" (meta "pack.name" $root) $name (var "id" $root) ]]
[[- end -]]

[[- define "service_name" -]]
[[- $root := index . 0 -]]
[[- $name  := index . 1 -]]
[[ printf "%s-%s-%s" (meta "pack.name" $root) $name (var "id" $root) | replace "_" "-" | trunc 63 ]]
[[- end -]]
