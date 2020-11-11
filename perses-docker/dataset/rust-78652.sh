#!/usr/bin/env bash
set -o nounset
set -o pipefail

readonly OUTPUT="temp_compilation_output.tmp.txt"

if timeout -s 9 30 rustc --crate-type=staticlib -C debuginfo=2 -C opt-level=1 -C target-cpu=skylake mutant.rs &> "${OUTPUT}" ; then 
  exit 1
fi

if ! grep --quiet --fixed-strings "error: internal compiler error: stable const functions must have either \`rustc_const_stable\` or \`rustc_const_unstable\` attribute" "${OUTPUT}" ; then
  exit 1
fi

if ! grep --quiet --fixed-strings "thread 'rustc' panicked at 'no errors encountered even though \`delay_span_bug\` issued'" "${OUTPUT}" ; then
  exit 1
fi

if ! grep --quiet --fixed-strings "error: internal compiler error: unexpected panic" "${OUTPUT}" ; then
  exit 1
fi

if ! grep --quiet --fixed-strings "note: the compiler unexpectedly panicked. this is a bug." "${OUTPUT}" ; then
  exit 1
fi
exit 0