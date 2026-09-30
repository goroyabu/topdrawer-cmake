# Third-Party Notices and Provenance

This repository maintains the build, compatibility, install, test, and
documentation workflow for legacy Topdrawer. This document records provenance
and notices verified in the pinned upstream source archive. It does not infer
permissions that the examined material does not state.

## License Boundary

The repository's [MIT License](LICENSE) applies to repository-maintained work
to the extent that its authors can license that work. It does not relicense the
downloaded Topdrawer sources, files derived from them, embedded third-party
components, the installed help file, or the executable compiled from those
sources. The separately supplied f2c and UGS dependencies have their own
provenance and terms.

## Pinned Upstream Input

The build obtains `topdrawer_20071207.tar.gz` from the
[RIKEN `iris` mirror](http://ftp.riken.go.jp/iris/OLD/topdrawer/topdrawer_20071207.tar.gz)
unless the user supplies the same archive locally. `CMakeLists.txt` pins its
SHA256 to:

```text
a3c00ee7b4265bfe56040fa6640f1f2bf9fc2e594117bc84464f26b000c8539f
```

The archive's `topdrawer/README` identifies the program as Topdrawer 5.12 on
Linux, release 1.4e. That upstream identifier is distinct from this
repository's wrapper release version. The archive contains no top-level
`LICENSE`, `COPYING`, or equivalent comprehensive license grant. Its
`topdrawer/doc/html/notice.html` records manual provenance, not distribution
terms.

## Verified Lineage

The archive's `topdrawer/README` and `topdrawer/README-j` describe the
following history:

- R. B. Chaffee developed the original Topdrawer at SLAC.
- J. Clement extended it at Rice University's Bonner Laboratory.
- A. E. Kreymer ported Topdrawer 5.12 to Unix at Fermilab.
- H. Okamura produced this Linux release at Osaka University's Research
  Center for Nuclear Physics (RCNP). The README calls it a private release,
  not officially supported by Tohoku University or RIKEN.

The archive's `topdrawer/doc/html/notice.html` identifies the Rice Bonner Lab
Topdrawer 5.12 reference manual as Fermilab Document PP0005.1, dated July
1993 and authored by John Clement. The [RIKEN `iris` mirror](https://ftp.riken.jp/iris/)
identifies its source as an RCNP distribution site. These records establish
provenance, not a license for the complete program.

## Notices in the Pinned Archive

### Topdrawer release notes

Section 0 of `topdrawer/README-j` says Topdrawer is not described there as
free software, that documentation governing modification and redistribution
was not found by the author, and that the terms for this Linux release were
unclear. It also describes an earlier registration request for the FNAL port.
This is the upstream author's account; it is not an independent legal
determination or a grant of permission.

### Gnuplot-derived source files

The build compiles `topdrawer/src/help_.c` and `topdrawer/src/readpr_.c` into
`td`. Both files carry the following historical Gnuplot copyright and
permission text (whitespace normalized):

```text
Copyright (C) 1986 - 1993   Thomas Williams, Colin Kelley

Permission to use, copy, and distribute this software and its
documentation for any purpose with or without fee is hereby granted,
provided that the above copyright notice appear in all copies and
that both that copyright notice and this permission notice appear
in supporting documentation.

Permission to modify the software is granted, but not the right to
distribute the modified code. Modifications are to be distributed
as patches to released version.

This software is provided "as is" without express or implied warranty.
```

The build applies local compatibility changes to both files through
`cmake/TdPatchSources.cmake`. The terms above belong to these embedded files;
they do not establish the terms for Topdrawer as a whole. Consult the notices
in the pinned archive for the complete source-file headers and attribution.

### TD2SCS routine

The archive's `topdrawer/mor_src/txline.mor` identifies `TD2SCS` as a routine
copied from a plot package for Trendata terminals. It credits Copyright (C)
1978 Roger B. Chaffee, Kiloword Computing, and says it was "used by
permission." The build compiles the corresponding routine in
`topdrawer/src/txline.f`. That attribution does not state general reuse or
redistribution terms for third parties.

## Current Distribution and Install

This repository tracks the build wrapper, not the unpacked Topdrawer source
tree or the upstream archive. Its releases contain the repository source and
do not attach the upstream archive or a prebuilt `td` executable. During a
local build, the archive is obtained and patched in the build tree. A local
`cmake --install` installs the resulting `td` executable and the
upstream-derived `topdrawer.gih` help file; it does not install this document
or the repository's MIT License. Installation is distinct from a release of
prebuilt artifacts.

## Unresolved Upstream Terms

No comprehensive modification or redistribution grant for the Topdrawer core
and this Linux release was found in the pinned archive. The embedded notices
above have separate scopes and do not resolve that gap. Availability on a
public mirror is not treated as permission to relicense or redistribute the
whole upstream program. Anyone planning to redistribute upstream source or
derived artifacts should independently establish the applicable terms and
preserve relevant notices.
