#/usr/bin/env bash

# helmlint.sh
# run `helm lint` on all helm charts that are found

set +e
echo "helmlint.sh, using helm version: $(helm version -c --short)"

fail_lint=0

for chart in $(find . -name Chart.yaml -print) ; do

  chartdir=$(dirname "${chart}")

  # lint with values.yaml if it exists
  if [ -f "${chartdir}/values.yaml" ]; then
    helm lint --strict --values "${chartdir}/values.yaml" "${chartdir}"
  else
    helm lint --strict "${chartdir}"
  fi

  rc=$?
  if [[ $rc != 0 ]]; then
    fail_lint=1
  fi
done

if [[ $fail_lint != 0 ]]; then
  exit 1
fi

exit 0
