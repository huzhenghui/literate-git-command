#!/usr/bin/env just --justfile

repository-local-path := `while r=$(ghq list --full-path "${repository_remote}") && [[ -z "${r}" ]] ; do ghq get --update "${repository_remote}" >/dev/null; done; echo "${r}"`

repository-local-path:
    echo "${repository_remote}"
    echo "{{ repository-local-path }}"

show-commit-message:
    echo "{{ repository-local-path }}"
    echo "${commit_message_path}"
    cd "{{ repository-local-path }}" && \
        cd "${commit_message_path}" && \
        pwd && \
        find . -type f | sort --numeric-sort | while read line ; do \
            echo "${line}" | pastel paint --bold red --no-newline && \
            branch_name="$(echo "${line}" | sed 's/^\.[/][^/]*[/]\(.*\)\.[^.]*$/\1/')" && \
            echo "${branch_name}" && \
            if git --git-dir "{{ repository-local-path }}/.git" show-branch --sha1-name "${branch_name}" ; then \
                commit_content="$(cat "${line}")" && \
                echo "${commit_content}" ; \
            fi \
        done
