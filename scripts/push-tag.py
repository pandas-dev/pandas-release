#!/usr/bin/env python3
"""
Push a pandas release to GitHub.
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


def get_branch(tag):
    """
    >>> get_branch("v0.24.0rc0")
    'main'
    >>> get_branch("v0.24.0")
    '0.24.x'
    >>> get_branch("v0.24.1")
    '0.24.x'
    """
    ver = version.parse(tag.lstrip('v'))
    if 'rc0' in tag:
        # off main
        base = 'main'
    else:
        base = '.'.join([tag[1:].rsplit('.', 1)[0], 'x'])

    return base


def push(tag):
    branch = get_branch(tag)
    subprocess.check_call(['git', 'push', 'upstream', branch, '--follow-tags'])


def parse_args(args=None):
    parser = argparse.ArgumentParser(__name__, usage=__doc__)
    parser.add_argument('tag', type=check_tag)

    return parser.parse_args(args)


def main(args=None):
    args = parse_args(args)
    push(args.tag)


if __name__ == '__main__':
    sys.exit(main())
