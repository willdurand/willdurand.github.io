TAGS = [
    "PHP",
    "ai",
    "career",
    "mozilla",
    "side projects",
    "tech leadership",
    "thoughts",
]

TEMPLATE = """---
layout: tag
tag: %%TAG%%
title: Posts tagged with "%%TAG%%"
description: A list of posts tagged with "%%TAG%%", written by William Durand.
---
"""

for tag in TAGS:
    with open(f"tags/{tag.lower().replace(" ", "-")}.html", "w+") as file:
        file.write(TEMPLATE.replace("%%TAG%%", tag))
