repository-local-path := `while r=$(ghq list --full-path "${repository_remote}") && [[ -z "${r}" ]] ; do ghq get --update "${repository_remote}" >/dev/null; done; echo "${r}"`

repository-local-path:
    echo "${repository_remote}"
    echo "{{ repository-local-path }}"
