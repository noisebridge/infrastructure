#!/usr/bin/env python3
"""Strip excluded pages from a MediaWiki XML dump before it is published.

Reads a gzipped MediaWiki export, removes any <page> whose title matches an
excluded base title -- the base itself, its subpages (``Base/...``), and the
corresponding Talk pages (``Talk:Base`` and ``Talk:Base/...``) -- and writes a
gzipped, filtered dump.

Usage: dump_filter.py SRC.xml.gz DST.xml.gz [EXCLUDE_TITLES]
       EXCLUDE_TITLES is a comma-separated list of base titles (default "86").

Exits non-zero on any error so the caller can refuse to publish an unfiltered
dump (better to publish nothing than to leak an excluded page).
"""
import gzip
import sys
import xml.etree.ElementTree as ET

XSI = "http://www.w3.org/2001/XMLSchema-instance"


def excluded_matcher(bases):
    variants = set()
    for base in bases:
        base = base.strip()
        if not base:
            continue
        variants.add(base)
        variants.add(f"Talk:{base}")

    def is_excluded(title):
        if title is None:
            return False
        for v in variants:
            if title == v or title.startswith(v + "/"):
                return True
        return False

    return is_excluded


def main():
    if len(sys.argv) < 3:
        sys.exit(f"usage: {sys.argv[0]} SRC.xml.gz DST.xml.gz [EXCLUDE_TITLES]")
    src, dst = sys.argv[1], sys.argv[2]
    bases = (sys.argv[3] if len(sys.argv) > 3 else "86").split(",")
    is_excluded = excluded_matcher(bases)

    with gzip.open(src, "rb") as fh:
        tree = ET.parse(fh)
    root = tree.getroot()

    # Preserve the export namespace (version varies: 0.10, 0.11, ...) as the
    # default so the output stays byte-clean rather than gaining ns0: prefixes.
    ns_uri = root.tag[root.tag.find("{") + 1:root.tag.find("}")]
    ET.register_namespace("", ns_uri)
    ET.register_namespace("xsi", XSI)

    def title_of(page):
        node = page.find(f"{{{ns_uri}}}title")
        return node.text if node is not None else None

    removed = []
    for page in list(root.findall(f"{{{ns_uri}}}page")):
        title = title_of(page)
        if is_excluded(title):
            root.remove(page)
            removed.append(title)

    with gzip.open(dst, "wb") as fh:
        tree.write(fh, encoding="utf-8", xml_declaration=True)

    if removed:
        sys.stderr.write(f"dump_filter: removed {len(removed)} page(s): "
                         f"{', '.join(removed)}\n")
    else:
        sys.stderr.write("dump_filter: no excluded pages found\n")


if __name__ == "__main__":
    main()
