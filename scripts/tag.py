#!/usr/bin/env python3
"""
Tag a pandas release.
"""
import argparse
import subprocess
import sys

from packaging import version


def check_tag(tag):
    assert tag.startswith('v'), ("Invalid tag '{}', must "
                                 "start with 'v'".format(tag))
    ver = version.parse(tag.lstrip('v'))
    assert isinstance(ver, version.Version), "Invalid tag '{}'".format(tag)
    return tag


def commit(tag):
    subprocess.check_call(['git', 'clean', '-xdf'])
    print("Creating tag {}".format(tag))
    subprocess.check_call(['git', 'commit', '--allow-empty', '-m',
                           'RLS: {}'.format(tag[1:])])
    subprocess.check_call(['git', 'tag', '-a', tag, '-m',
                           'Version {}'.format(tag[1:])])


def parse_args(args=None):
    parser = argparse.ArgumentParser(__name__, usage=__doc__)
    parser.add_argument('tag', type=check_tag)

    return parser.parse_args(args)


def main(args=None):
    args = parse_args(args)
    commit(args.tag)


if __name__ == '__main__':
    sys.exit(main())
