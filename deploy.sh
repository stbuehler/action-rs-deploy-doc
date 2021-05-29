#!/bin/bash

# License: CC0 1.0 Universal
# https://creativecommons.org/publicdomain/zero/1.0/legalcode

set -e

# not using /tmp or similar to make sure we're on the same filesystem
checkout_dir=__deploy_docs

if [ -n "${SSH_PRIVATE_KEY}" ]; then
	# don't care it it's actually an ed25519 key, should hopefully work anyway
	echo "Received SSH private key, storing in ~/.ssh/id_ed25519"
	mkdir -p ~/.ssh
	printf '%s' "${SSH_PRIVATE_KEY}" > ~/.ssh/id_ed25519
	chmod 600 ~/.ssh/id_ed25519
	ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
	echo "Public key is:"
	cat ~/.ssh/id_ed25519.pub
fi

# convert to absolute path
doc_dir=$(readlink -f "${DOC_DIR}")

git clone --branch "${TARGET_BRANCH}" "${TARGET}" "${checkout_dir}"

if [ -z "${TARGET_FOLDER}" -o "${TARGET_FOLDER}" = "." ]; then
	# instead of replacing all but .git in repo, just move .git to doc dir, and
	# use it as new "checkout"
	mv "${checkout_dir}"/.git "${doc_dir}/"
	cd "${doc_dir}"
	git add -A .
else
	cd "${checkout_dir}"
	# create hiearchy if needed
	mkdir -p "$(dirname "${TARGET_FOLDER}")"
	# delete old folder
	if [ -x "${TARGET_FOLDER}" ]; then
		rm -rf "${TARGET_FOLDER}"
	fi
	# move new docs to target folder
	mv ../target/doc "${TARGET_FOLDER}"
	git add -A "${TARGET_FOLDER}"
fi

git config user.name "${GIT_USER_NAME}"
git config user.email "${GIT_USER_EMAIL}"
git commit -qm "doc upload for ${SLUG}"
git push -q origin "${TARGET_BRANCH}"

# cleanup
rm -rf "${checkout_dir}" "${doc_dir}/.git"
