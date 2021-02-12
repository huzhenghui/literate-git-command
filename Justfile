#!/usr/bin/env just --justfile

repository-local-path := `while r=$(ghq list --full-path "${repository_remote}") && [[ -z "${r}" ]] ; do ghq get --update "${repository_remote}" >/dev/null; done; echo "${r}"`
literate-git-branch-prefix := 'literate-git-'
literate-git-linear-branch-prefix := literate-git-branch-prefix + 'linear-'
literate-git-linear-branch := literate-git-linear-branch-prefix + `echo "${linear_branch_postfix}"`

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

regenerate-linear-branch:
    echo "{{ repository-local-path }}"
    echo "${base_branch}"
    echo "{{ literate-git-linear-branch }}"
    echo "${commit_message_path}"
    if git --git-dir "{{ repository-local-path }}/.git" show-branch "{{ literate-git-linear-branch }}" ; then \
        git --git-dir "{{ repository-local-path }}/.git" branch --delete --force "{{ literate-git-linear-branch }}" ; \
    fi
    git --git-dir "{{ repository-local-path }}/.git" branch --copy "${base_branch}" "{{ literate-git-linear-branch }}"
    cd "{{ repository-local-path }}" && \
        cd "${commit_message_path}" && \
        pwd && \
        find . -type f | sort --numeric-sort | while read line ; do \
            echo "${line}" | pastel paint --bold red --no-newline && \
            branch_name="$(echo "${line}" | sed 's/^\.[/][^/]*[/]\(.*\)\.[^.]*$/\1/')" && \
            echo "${branch_name}" && \
            if git --git-dir "{{ repository-local-path }}/.git" show-branch --sha1-name "${branch_name}" ; then \
                cd "{{ repository-local-path }}" && \
                commit_content="$(cd "${commit_message_path}"; cat "${line}")" && \
                echo "${commit_content}" && \
                current_branch="$(git --git-dir "{{ repository-local-path }}/.git" --work-tree "{{ repository-local-path }}" branch --show-current)" && \
                echo "${current_branch}" && \
                git --git-dir "{{ repository-local-path }}/.git" --work-tree "{{ repository-local-path }}" checkout "{{ literate-git-linear-branch }}" && \
                git --git-dir "{{ repository-local-path }}/.git" --work-tree "{{ repository-local-path }}" merge --squash --strategy-option=theirs "${branch_name}" && \
                git --git-dir "{{ repository-local-path }}/.git" --work-tree "{{ repository-local-path }}" commit --allow-empty -m "${commit_content}" && \
                git --git-dir "{{ repository-local-path }}/.git" --work-tree "{{ repository-local-path }}" checkout "${current_branch}" ; \
            fi \
        done
