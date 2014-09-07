# Synclenote

A synchronization tool for GFM (GitHub Flavored Markdown) files and Evernote.

[![License X11](https://img.shields.io/badge/license-X11-brightgreen.svg)](https://raw.githubusercontent.com/nishidayuya/synclenote/master/LICENSE.txt)
[![Build Status](https://travis-ci.org/nishidayuya/synclenote.svg?branch=master)](https://travis-ci.org/nishidayuya/synclenote)

## Installation

1. Install Ruby interpreter.
2. Clone and install this software.
```sh
$ git clone https://github.com/nishidayuya/synclenote.git
$ cd synclenote
$ bundle exec rake install
```

## Usage

1. Create configuration directory.
```sh
$ synclenote init
```
2. Open "~/.synclenote/config" by your favorite text editor and edit "TODO:" section.
3. Sync your GFM files and Evernote.
```sh
$ synclenote sync
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/synclenote/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
