catalan-pos-dict
===============

A Catalan part-of-speech dictionary that can be used from Java. This repo contains no code
but [Morfologik](https://github.com/morfologik/) binary files to look up part-of-speech data.
As a developer, consider using [LanguageTool](https://github.com/languagetool-org) instead
of this. If you really want to use this directly, please check out the unit tests for examples.

Also use LanguageTool to export the data in these dictionaries, [as documented here](http://wiki.languagetool.org/developing-a-tagger-dictionary#toc2).

## Internal

To make a release:

* set the version to not include `SNAPSHOT`
* `mvn clean deploy -P release`
* go to https://central.sonatype.com/publishing/deployments
* select the deployment, and click `Publish`
