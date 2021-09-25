# Synclenote

A synchronization tool for GFM (GitHub Flavored Markdown) files and Evernote.

[![License X11](https://img.shields.io/badge/license-X11-brightgreen.svg)](https://raw.githubusercontent.com/nishidayuya/synclenote/master/LICENSE.txt)
[![Build Status](https://travis-ci.org/nishidayuya/synclenote.svg?branch=master)](https://travis-ci.org/nishidayuya/synclenote)

## Requirements

- Ruby

## Installation

```console
$ gem install synclenote
```

## Usage

Create configuration directory:

```console
$ synclenote init
```

Open "~/.synclenote/config" by your favorite text editor and edit "TODO:" section.

Sync your GFM files and Evernote:

```console
$ synclenote sync
```

## Contributing

1. Fork it ( https://github.com/nishidayuya/synclenote/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
